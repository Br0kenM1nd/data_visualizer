import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _widgetBaseClasses = {
  'StatelessWidget',
  'StatefulWidget',
  'InheritedWidget',
  'PreferredSizeWidget',
  'SingleChildRenderObjectWidget',
  'MultiChildRenderObjectWidget',
  'RenderObjectWidget',
  'AnimatedWidget',
  'Flex',
};

const _publicConstructorFormalAllowlist = {
  // Add intentionally public widget API classes here.
  'BottomSheetController',
};

void main() {
  test('use case constructors use private named parameters', () {
    final violations = <String>[];

    for (final file in _dartFiles(roots: const ['lib/features/term/domain/use_cases'])) {
      final source = file.readAsStringSync();
      final classes = RegExp(r'class\s+([A-Za-z_][A-Za-z0-9_]*UseCase)\b').allMatches(source);

      for (final match in classes) {
        final className = match.group(1)!;
        final bodyOpen = _findClassBodyOpen(source, match.end);
        if (bodyOpen == -1) {
          continue;
        }

        final primaryParamsOpen = source.indexOf('(', match.end);
        if (primaryParamsOpen != -1 && primaryParamsOpen < bodyOpen) {
          final primaryParamsClose = _findMatching(source, primaryParamsOpen, '(', ')');
          if (primaryParamsClose != -1 && primaryParamsClose < bodyOpen) {
            violations.addAll(
              _publicNamedParams(
                source: source.substring(primaryParamsOpen + 1, primaryParamsClose),
                filePath: file.path,
                className: className,
              ),
            );
          }
        }

        final bodyStart = bodyOpen + 1;
        final bodyEnd = _findMatching(source, bodyOpen, '{', '}');
        if (bodyEnd == -1) {
          continue;
        }

        final body = source.substring(bodyStart, bodyEnd);
        final constructorPattern = RegExp(
          '^\\s*(?:const\\s+)?${RegExp.escape(className)}'
          r'(?:\.[A-Za-z_][A-Za-z0-9_]*)?\s*\(',
          multiLine: true,
        );

        for (final constructor in constructorPattern.allMatches(body)) {
          final openParen = body.indexOf('(', constructor.start);
          final closeParen = _findMatching(body, openParen, '(', ')');
          if (closeParen == -1) {
            continue;
          }

          final params = _stripLineComments(body.substring(openParen + 1, closeParen));
          violations.addAll(
            _publicNamedParams(source: params, filePath: file.path, className: className),
          );
        }
      }
    }

    expect(violations, isEmpty);
  });

  test('widget constructor-backed fields use private initializing formals', () {
    final violations = <String>[];

    for (final file in _dartFiles(roots: const ['lib'])) {
      final source = file.readAsStringSync();
      for (final widgetClass in _widgetClasses(source)) {
        if (_publicConstructorFormalAllowlist.contains(widgetClass.name)) {
          continue;
        }

        final body = source.substring(widgetClass.bodyStart, widgetClass.bodyEnd);
        final constructorPattern = RegExp(
          '^\\s*(?:const\\s+)?${RegExp.escape(widgetClass.name)}'
          r'(?:\.[A-Za-z_][A-Za-z0-9_]*)?\s*\(',
          multiLine: true,
        );

        for (final constructor in constructorPattern.allMatches(body)) {
          final openParen = body.indexOf('(', constructor.start);
          final closeParen = _findMatching(body, openParen, '(', ')');
          if (closeParen == -1) {
            continue;
          }

          final params = _stripLineComments(body.substring(openParen + 1, closeParen));
          final publicFormals = RegExp(r'\bthis\.([A-Za-z][A-Za-z0-9_]*)\b').allMatches(params);

          for (final formal in publicFormals) {
            violations.add('${file.path}: ${widgetClass.name}.this.${formal.group(1)}');
          }
        }
      }
    }

    expect(violations, isEmpty);
  });

  test('widget constructors and fields are separated by a blank line', () {
    final violations = <String>[];

    for (final file in _dartFiles(roots: const ['lib'])) {
      final source = file.readAsStringSync();
      for (final widgetClass in _widgetClasses(source)) {
        final body = source.substring(widgetClass.bodyStart, widgetClass.bodyEnd);
        final lines = body.split('\n');

        for (var i = 0; i + 1 < lines.length; i++) {
          if (!_looksLikeConstructorEnd(lines, i, widgetClass.name)) {
            continue;
          }
          if (_looksLikeField(lines[i + 1])) {
            violations.add('${file.path}: ${widgetClass.name}');
          }
        }
      }
    }

    expect(violations, isEmpty);
  });
}

List<File> _dartFiles({required List<String> roots}) {
  return roots
      .expand((root) => Directory(root).listSync(recursive: true))
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .where((file) => !file.path.endsWith('.freezed.dart'))
      .toList();
}

List<_WidgetClass> _widgetClasses(String source) {
  final classes = <_WidgetClass>[];
  final matches = RegExp(
    r'class\s+([A-Za-z_][A-Za-z0-9_]*)[^{]*(?:extends|implements)\s+([A-Za-z_][A-Za-z0-9_]*)[^{]*\{',
  ).allMatches(source);

  for (final match in matches) {
    final baseClass = match.group(2);
    if (!_widgetBaseClasses.contains(baseClass)) {
      continue;
    }

    final bodyStart = match.end;
    final bodyEnd = _findMatching(source, match.end - 1, '{', '}');
    if (bodyEnd == -1) {
      continue;
    }

    classes.add(_WidgetClass(match.group(1)!, bodyStart, bodyEnd));
  }

  return classes;
}

bool _looksLikeConstructorEnd(List<String> lines, int index, String className) {
  final line = lines[index].trimRight();
  if (!line.endsWith(';')) {
    return false;
  }

  final constructorStartPattern = RegExp(
    '^(?:const\\s+)?${RegExp.escape(className)}'
    r'(?:\.[A-Za-z_][A-Za-z0-9_]*)?\s*\(',
  );

  if (constructorStartPattern.hasMatch(line.trimLeft())) {
    return true;
  }
  if (!line.trimLeft().startsWith(')') && !line.trimLeft().startsWith('});')) {
    return false;
  }

  for (var i = index - 1; i >= 0 && i >= index - 30; i--) {
    final candidate = lines[i].trimLeft();
    if (constructorStartPattern.hasMatch(candidate)) {
      return true;
    }
    if (candidate.endsWith(';') || candidate.endsWith('{') || candidate.endsWith('}')) {
      return false;
    }
  }

  return false;
}

bool _looksLikeField(String line) {
  final trimmed = line.trimLeft();
  return trimmed.startsWith('final ') ||
      trimmed.startsWith('late ') ||
      trimmed.startsWith('static ') ||
      trimmed.startsWith('var ');
}

String _stripLineComments(String source) {
  return source.split('\n').map((line) => line.split('//').first).join('\n');
}

List<String> _publicNamedParams({
  required String source,
  required String filePath,
  required String className,
}) {
  final publicNamedParams = RegExp(
    r'\{[^}]*\b(?!_)([A-Za-z][A-Za-z0-9_]*)\b(?=\s*(?:,|\}))',
    dotAll: true,
  ).allMatches(_stripLineComments(source));

  return [
    for (final namedParam in publicNamedParams) '$filePath: $className.${namedParam.group(1)}',
  ];
}

int _findClassBodyOpen(String source, int start) {
  var index = start;
  while (index < source.length) {
    if (source.startsWith('(', index)) {
      final close = _findMatching(source, index, '(', ')');
      if (close == -1) {
        return -1;
      }
      index = close + 1;
      continue;
    }

    if (source.startsWith('{', index)) {
      return index;
    }

    index++;
  }

  return -1;
}

int _findMatching(String source, int openIndex, String open, String close) {
  var depth = 0;

  for (var i = openIndex; i < source.length; i++) {
    if (source.startsWith(open, i)) {
      depth++;
    }
    if (source.startsWith(close, i)) {
      depth--;
      if (depth == 0) {
        return i;
      }
    }
  }

  return -1;
}

class _WidgetClass {
  const _WidgetClass(this.name, this.bodyStart, this.bodyEnd);

  final String name;
  final int bodyStart;
  final int bodyEnd;
}
