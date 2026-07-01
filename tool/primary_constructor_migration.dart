import 'dart:io';

class PrimaryConstructorMigrationResult {
  const PrimaryConstructorMigrationResult({
    required this.source,
    required this.migratedClasses,
    required this.skippedClasses,
  });

  final String source;
  final List<String> migratedClasses;
  final List<String> skippedClasses;

  bool get hasChanges => migratedClasses.isNotEmpty;
}

PrimaryConstructorMigrationResult migratePrimaryConstructorsInSource(
  String source, {
  required String path,
}) {
  final classes = _findClasses(source);
  var migratedSource = source;
  final migratedClasses = <String>[];
  final skippedClasses = <String>[];

  for (final classInfo in classes.reversed) {
    final migration = _migrateClass(migratedSource, classInfo);
    if (migration == null) {
      continue;
    }
    if (migration.skipped) {
      skippedClasses.add(classInfo.name);
      continue;
    }

    migratedClasses.add(classInfo.name);
    migratedSource = migratedSource.replaceRange(
      classInfo.start,
      classInfo.bodyClose + 1,
      migration.source,
    );
  }

  return PrimaryConstructorMigrationResult(
    source: migratedSource,
    migratedClasses: migratedClasses.reversed.toList(growable: false),
    skippedClasses: skippedClasses.reversed.toList(growable: false),
  );
}

Future<void> main(List<String> args) async {
  final config = _CliConfig.parse(args);
  if (config.help) {
    stdout.writeln('''
Usage: dart run tool/primary_constructor_migration.dart [--check|--write] [roots...]

Migrates conservative unnamed constructors to Dart primary constructors.

Options:
  --check   Exit with code 1 when migratable classes are found.
  --write   Rewrite files in place.
  --help    Print this help.

Defaults to a dry run over lib/.
''');
    return;
  }

  final files = _dartFiles(config.roots);
  var changedFiles = 0;
  final skipped = <String>[];

  for (final file in files) {
    final source = file.readAsStringSync();
    final result = migratePrimaryConstructorsInSource(source, path: file.path);
    skipped.addAll(result.skippedClasses.map((className) => '${file.path}: $className'));

    if (!result.hasChanges) {
      continue;
    }

    changedFiles++;
    stdout.writeln(
      '${config.write ? 'migrated' : 'would migrate'} ${file.path}: '
      '${result.migratedClasses.join(', ')}',
    );
    if (config.write) {
      file.writeAsStringSync(result.source);
    }
  }

  if (skipped.isNotEmpty) {
    stdout.writeln('\nskipped conservative cases:');
    for (final item in skipped) {
      stdout.writeln('  $item');
    }
  }

  if (config.check && changedFiles > 0) {
    exitCode = 1;
  }
}

_ClassMigration? _migrateClass(String source, _ClassInfo classInfo) {
  final headerTail = source.substring(classInfo.nameEnd, classInfo.bodyOpen);
  if (headerTail.trimLeft().startsWith('(')) {
    return null;
  }

  var body = source.substring(classInfo.bodyOpen + 1, classInfo.bodyClose);
  final constructor = _findUnnamedConstructor(body, classInfo.name);
  var head = source.substring(classInfo.start, classInfo.nameEnd);
  String? primaryParams;
  var primarySkipped = false;

  if (constructor != null) {
    if (constructor.skipped) {
      primarySkipped = true;
    } else {
      final fields = _findSimpleFinalFields(body);
      final transformedParams = constructor.params.trim().isEmpty
          ? const _TransformedParams('', <String>{})
          : _transformParameters(constructor.params, fields: fields);

      if (transformedParams == null) {
        primarySkipped = true;
      } else {
        final removalSpans = <_Span>[constructor.span];
        for (final fieldName in transformedParams.fieldNames) {
          final field = fields[fieldName];
          if (field == null) {
            primarySkipped = true;
            break;
          }
          removalSpans.add(field.span);
        }

        if (!primarySkipped) {
          removalSpans.sort((a, b) => b.start.compareTo(a.start));
          for (final span in removalSpans) {
            body = body.replaceRange(span.start, span.end, '');
          }
          body = _cleanClassBody(body);
          primaryParams = _formatPrimaryParams(transformedParams.params);

          if (constructor.isConst && !RegExp(r'\bclass\s+const\s+').hasMatch(head)) {
            head = head.replaceFirst(RegExp(r'\bclass\s+'), 'class const ');
          }
        }
      }
    }
  }

  final conciseResult = _migrateConciseConstructors(body, classInfo.name);
  body = conciseResult.body;

  if (primaryParams == null && !conciseResult.changed) {
    return primarySkipped ? const _ClassMigration.skipped() : null;
  }

  final tail = source.substring(classInfo.nameEnd, classInfo.bodyOpen).trimRight();
  return _ClassMigration('$head${primaryParams ?? ''}$tail {$body}');
}

List<_ClassInfo> _findClasses(String source) {
  final classes = <_ClassInfo>[];
  final matches = RegExp(r'\bclass\s+(?:const\s+)?([A-Za-z_][A-Za-z0-9_]*)').allMatches(source);

  for (final match in matches) {
    final name = match.group(1)!;
    var nameEnd = match.end;
    if (nameEnd < source.length && source[nameEnd] == '<') {
      final genericEnd = _findMatching(source, nameEnd, '<', '>');
      if (genericEnd != -1) {
        nameEnd = genericEnd + 1;
      }
    }

    final bodyOpen = _findTopLevelChar(source, nameEnd, '{');
    if (bodyOpen == -1) {
      continue;
    }
    final bodyClose = _findMatching(source, bodyOpen, '{', '}');
    if (bodyClose == -1) {
      continue;
    }

    classes.add(
      _ClassInfo(
        start: match.start,
        name: name,
        nameEnd: nameEnd,
        bodyOpen: bodyOpen,
        bodyClose: bodyClose,
      ),
    );
  }

  return classes;
}

_ConstructorInfo? _findUnnamedConstructor(String body, String className) {
  final pattern = RegExp(
    '(^|\\n)([ \\t]*)(?:const\\s+)?${RegExp.escape(className)}\\s*\\(',
    multiLine: true,
  );
  final matches = pattern
      .allMatches(body)
      .where((match) => _isTopLevel(body, match.start))
      .toList();
  if (matches.isEmpty) {
    return null;
  }
  if (matches.length > 1) {
    return const _ConstructorInfo.skipped();
  }

  final match = matches.single;
  final start = match.start + (match.group(1) == '\n' ? 1 : 0);
  final openParen = body.indexOf('(', start);
  final closeParen = _findMatching(body, openParen, '(', ')');
  if (closeParen == -1) {
    return const _ConstructorInfo.skipped();
  }

  final afterParams = _skipWhitespace(body, closeParen + 1);
  if (afterParams >= body.length || body[afterParams] != ';') {
    return const _ConstructorInfo.skipped();
  }

  final declaration = body.substring(start, openParen);
  return _ConstructorInfo(
    span: _Span(start, _includeTrailingNewline(body, afterParams + 1)),
    params: body.substring(openParen + 1, closeParen),
    isConst: declaration.trimLeft().startsWith('const '),
  );
}

_ConciseConstructorMigration _migrateConciseConstructors(String body, String className) {
  final replacements = <_Replacement>[];
  final generativePattern = RegExp(
    '(^|\\n)([ \\t]*)(const\\s+)?${RegExp.escape(className)}'
    r'(?:\.([A-Za-z_][A-Za-z0-9_]*))?\s*\(',
    multiLine: true,
  );
  final factoryPattern = RegExp(
    '(^|\\n)([ \\t]*)factory\\s+${RegExp.escape(className)}'
    r'(?:\.([A-Za-z_][A-Za-z0-9_]*))?\s*\(',
    multiLine: true,
  );

  for (final match in generativePattern.allMatches(body)) {
    final replacementStart = _constructorReplacementStart(match);
    if (!_isTopLevel(body, replacementStart)) {
      continue;
    }

    final constructorName = match.group(4);
    final constPrefix = match.group(3) ?? '';
    replacements.add(
      _Replacement(
        replacementStart,
        match.end - 1,
        '$constPrefix${_conciseNewName(constructorName)}',
      ),
    );
  }

  for (final match in factoryPattern.allMatches(body)) {
    final replacementStart = _constructorReplacementStart(match);
    if (!_isTopLevel(body, replacementStart)) {
      continue;
    }

    final constructorName = match.group(3);
    replacements.add(
      _Replacement(replacementStart, match.end - 1, _conciseFactoryName(constructorName)),
    );
  }

  if (replacements.isEmpty) {
    return _ConciseConstructorMigration(body, changed: false);
  }

  replacements.sort((a, b) => b.start.compareTo(a.start));
  var migratedBody = body;
  for (final replacement in replacements) {
    migratedBody = migratedBody.replaceRange(replacement.start, replacement.end, replacement.value);
  }

  return _ConciseConstructorMigration(migratedBody, changed: true);
}

int _constructorReplacementStart(RegExpMatch match) {
  return match.start + (match.group(1) == '\n' ? 1 : 0) + match.group(2)!.length;
}

String _conciseNewName(String? constructorName) {
  return constructorName == null ? 'new' : 'new $constructorName';
}

String _conciseFactoryName(String? constructorName) {
  return constructorName == null ? 'factory' : 'factory $constructorName';
}

Map<String, _FieldInfo> _findSimpleFinalFields(String body) {
  final fields = <String, _FieldInfo>{};
  final pattern = RegExp(
    r'^[ \t]*final\s+(.+?)\s+([A-Za-z_][A-Za-z0-9_]*)\s*;\r?\n?',
    multiLine: true,
  );

  for (final match in pattern.allMatches(body)) {
    if (!_isTopLevel(body, match.start)) {
      continue;
    }
    if (_hasLeadingAnnotation(body, match.start)) {
      continue;
    }
    final type = match.group(1)!.trim();
    final name = match.group(2)!;
    fields[name] = _FieldInfo(type: type, span: _Span(match.start, match.end));
  }

  return fields;
}

bool _hasLeadingAnnotation(String source, int offset) {
  final lineEnd = source.lastIndexOf('\n', offset - 1);
  if (lineEnd == -1) {
    return false;
  }

  while (lineEnd > 0) {
    final lineStart = source.lastIndexOf('\n', lineEnd - 1) + 1;
    final previousLine = source.substring(lineStart, lineEnd).trim();
    if (previousLine.isEmpty) {
      return false;
    }
    return previousLine.startsWith('@');
  }

  return false;
}

_TransformedParams? _transformParameters(String params, {required Map<String, _FieldInfo> fields}) {
  final fieldNames = <String>{};
  final items = _splitTopLevelParameters(params);
  if (items.isEmpty) {
    return null;
  }

  final transformedItems = <String>[];
  for (final item in items) {
    final transformed = _transformParameterItem(item, fields: fields, fieldNames: fieldNames);
    if (transformed == null) {
      return null;
    }
    transformedItems.add(transformed);
  }

  if (fieldNames.isEmpty && !transformedItems.any((item) => item.contains('super.'))) {
    return null;
  }

  return _TransformedParams(transformedItems.join(', '), fieldNames);
}

String? _transformParameterItem(
  String rawItem, {
  required Map<String, _FieldInfo> fields,
  required Set<String> fieldNames,
}) {
  var item = rawItem.trim();
  if (item.isEmpty) {
    return null;
  }

  final prefix = item[0];
  final suffix = item[item.length - 1];
  if ((prefix == '{' && suffix == '}') || (prefix == '[' && suffix == ']')) {
    final inner = item.substring(1, item.length - 1);
    final innerItems = _splitTopLevelParameters(inner);
    final transformedInner = <String>[];
    for (final innerItem in innerItems) {
      final transformed = _transformParameterItem(
        innerItem,
        fields: fields,
        fieldNames: fieldNames,
      );
      if (transformed == null) {
        return null;
      }
      transformedInner.add(transformed);
    }
    return '$prefix${transformedInner.join(', ')}$suffix';
  }

  final thisMatches = RegExp(r'\bthis\.([A-Za-z_][A-Za-z0-9_]*)\b').allMatches(item).toList();
  if (thisMatches.length > 1) {
    return null;
  }

  if (thisMatches.length == 1) {
    final fieldName = thisMatches.single.group(1)!;
    final field = fields[fieldName];
    if (field == null) {
      return null;
    }
    fieldNames.add(fieldName);
    item = item.replaceFirst('this.$fieldName', 'final ${field.type} $fieldName');
  } else if (!item.contains('super.')) {
    return null;
  }

  return item;
}

List<String> _splitTopLevelParameters(String source) {
  final items = <String>[];
  var start = 0;
  var paren = 0;
  var bracket = 0;
  var brace = 0;
  var angle = 0;
  String? quote;

  for (var i = 0; i < source.length; i++) {
    final char = source[i];
    if (quote != null) {
      if (char == r'\' && i + 1 < source.length) {
        i++;
        continue;
      }
      if (char == quote) {
        quote = null;
      }
      continue;
    }

    if (char == "'" || char == '"') {
      quote = char;
      continue;
    }

    switch (char) {
      case '(':
        paren++;
      case ')':
        paren--;
      case '[':
        bracket++;
      case ']':
        bracket--;
      case '{':
        brace++;
      case '}':
        brace--;
      case '<':
        angle++;
      case '>':
        if (angle > 0) {
          angle--;
        }
      case ',':
        if (paren == 0 && bracket == 0 && brace == 0 && angle == 0) {
          final item = source.substring(start, i).trim();
          if (item.isNotEmpty) {
            items.add(item);
          }
          start = i + 1;
        }
    }
  }

  final item = source.substring(start).trim();
  if (item.isNotEmpty) {
    items.add(item);
  }
  return items;
}

String _formatPrimaryParams(String params) {
  final trimmed = params.trim();
  if (trimmed.isEmpty) {
    return '()';
  }

  if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
    final inner = trimmed.substring(1, trimmed.length - 1);
    final items = _splitTopLevelParameters(inner);
    if (items.length == 1 && items.single.length <= 72) {
      return '({${items.single}})';
    }
    return '({\n  ${items.join(',\n  ')},\n})';
  }

  if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
    final inner = trimmed.substring(1, trimmed.length - 1);
    final items = _splitTopLevelParameters(inner);
    if (items.length == 1 && items.single.length <= 72) {
      return '([${items.single}])';
    }
    return '([\n  ${items.join(',\n  ')},\n])';
  }

  final items = _splitTopLevelParameters(trimmed);
  if (items.length == 1 && items.single.length <= 72) {
    return '(${items.single})';
  }
  return '(\n  ${items.join(',\n  ')},\n)';
}

String _cleanClassBody(String body) {
  var cleaned = body.replaceAll(RegExp(r'\n[ \t]*\n[ \t]*\n+'), '\n\n');
  while (cleaned.startsWith('\n\n')) {
    cleaned = cleaned.substring(1);
  }
  cleaned = cleaned.replaceFirst(RegExp(r'\n[ \t]*\n$'), '\n');
  if (cleaned.trim().isEmpty) {
    return '\n';
  }
  if (!cleaned.startsWith('\n')) {
    cleaned = '\n$cleaned';
  }
  if (!cleaned.endsWith('\n')) {
    cleaned = '$cleaned\n';
  }
  return cleaned;
}

List<File> _dartFiles(List<String> roots) {
  final files = <File>[];
  for (final root in roots) {
    if (FileSystemEntity.typeSync(root) == FileSystemEntityType.file) {
      final entity = File(root);
      if (_isMigratableDartFile(entity.path)) {
        files.add(entity);
      }
      continue;
    }
    final entity = Directory(root);
    if (!entity.existsSync()) {
      continue;
    }
    files.addAll(
      entity
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => _isMigratableDartFile(file.path)),
    );
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

bool _isMigratableDartFile(String path) {
  return path.endsWith('.dart') &&
      !path.endsWith('.g.dart') &&
      !path.endsWith('.freezed.dart') &&
      !path.endsWith('.gr.dart');
}

int _findTopLevelChar(String source, int start, String target) {
  var paren = 0;
  var bracket = 0;
  var angle = 0;
  for (var i = start; i < source.length; i++) {
    final char = source[i];
    if (char == target && paren == 0 && bracket == 0 && angle == 0) {
      return i;
    }
    switch (char) {
      case '(':
        paren++;
      case ')':
        paren--;
      case '[':
        bracket++;
      case ']':
        bracket--;
      case '<':
        angle++;
      case '>':
        if (angle > 0) {
          angle--;
        }
    }
  }
  return -1;
}

int _findMatching(String source, int openIndex, String open, String close) {
  var depth = 0;
  String? quote;
  for (var i = openIndex; i < source.length; i++) {
    final char = source[i];
    if (quote != null) {
      if (char == r'\' && i + 1 < source.length) {
        i++;
        continue;
      }
      if (char == quote) {
        quote = null;
      }
      continue;
    }

    if (char == "'" || char == '"') {
      quote = char;
      continue;
    }
    if (char == open) {
      depth++;
    } else if (char == close) {
      depth--;
      if (depth == 0) {
        return i;
      }
    }
  }
  return -1;
}

bool _isTopLevel(String source, int offset) {
  var paren = 0;
  var brace = 0;
  var bracket = 0;
  for (var i = 0; i < offset; i++) {
    switch (source[i]) {
      case '(':
        paren++;
      case ')':
        paren--;
      case '{':
        brace++;
      case '}':
        brace--;
      case '[':
        bracket++;
      case ']':
        bracket--;
    }
  }
  return paren == 0 && brace == 0 && bracket == 0;
}

int _skipWhitespace(String source, int start) {
  var index = start;
  while (index < source.length && source[index].trim().isEmpty) {
    index++;
  }
  return index;
}

int _includeTrailingNewline(String source, int end) {
  if (end < source.length && source[end] == '\r') {
    end++;
  }
  if (end < source.length && source[end] == '\n') {
    end++;
  }
  return end;
}

class _CliConfig {
  const _CliConfig({
    required this.roots,
    required this.check,
    required this.write,
    required this.help,
  });

  factory _CliConfig.parse(List<String> args) {
    final roots = <String>[];
    var check = false;
    var write = false;
    var help = false;

    for (final arg in args) {
      switch (arg) {
        case '--check':
          check = true;
        case '--write':
          write = true;
        case '--help':
        case '-h':
          help = true;
        default:
          roots.add(arg);
      }
    }

    return _CliConfig(
      roots: roots.isEmpty ? const ['lib'] : roots,
      check: check,
      write: write,
      help: help,
    );
  }

  final List<String> roots;
  final bool check;
  final bool write;
  final bool help;
}

class _ClassInfo {
  const _ClassInfo({
    required this.start,
    required this.name,
    required this.nameEnd,
    required this.bodyOpen,
    required this.bodyClose,
  });

  final int start;
  final String name;
  final int nameEnd;
  final int bodyOpen;
  final int bodyClose;
}

class _ConstructorInfo {
  const _ConstructorInfo({required this.span, required this.params, required this.isConst})
    : skipped = false;

  const _ConstructorInfo.skipped()
    : span = const _Span(0, 0),
      params = '',
      isConst = false,
      skipped = true;

  final _Span span;
  final String params;
  final bool isConst;
  final bool skipped;
}

class _FieldInfo {
  const _FieldInfo({required this.type, required this.span});

  final String type;
  final _Span span;
}

class _TransformedParams {
  const _TransformedParams(this.params, this.fieldNames);

  final String params;
  final Set<String> fieldNames;
}

class _ClassMigration {
  const _ClassMigration(this.source) : skipped = false;

  const _ClassMigration.skipped() : source = '', skipped = true;

  final String source;
  final bool skipped;
}

class _ConciseConstructorMigration {
  const _ConciseConstructorMigration(this.body, {required this.changed});

  final String body;
  final bool changed;
}

class _Replacement {
  const _Replacement(this.start, this.end, this.value);

  final int start;
  final int end;
  final String value;
}

class _Span {
  const _Span(this.start, this.end);

  final int start;
  final int end;
}
