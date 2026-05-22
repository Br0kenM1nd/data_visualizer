# Dart Architecture Diagrams Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a portable Dart CLI that analyzes Dart/Flutter projects and generates deterministic Mermaid dependency, class, and static sequence diagrams.

**Architecture:** The implementation uses `package:analyzer` to parse Dart ASTs into a small internal project graph. Mermaid emitters render that graph into `.mmd` files, and a thin CLI wires path validation, scanning, entrypoint selection, and output writing.

**Tech Stack:** Dart 3.12, Flutter test, `package:analyzer`, `package:args`, Mermaid.

---

## File Structure

- Modify `pubspec.yaml`: add explicit dev dependencies for `analyzer` and `args`.
- Create `tool/architecture_diagrams.dart`: CLI entrypoint.
- Create `lib/tooling/architecture_diagrams/file_scanner.dart`: discover analyzable Dart files.
- Create `lib/tooling/architecture_diagrams/model.dart`: graph model classes.
- Create `lib/tooling/architecture_diagrams/dart_graph_builder.dart`: AST parsing and model construction.
- Create `lib/tooling/architecture_diagrams/mermaid_emitters.dart`: dependency, class, and sequence Mermaid renderers.
- Create `lib/tooling/architecture_diagrams/cli.dart`: argument parsing, validation, and orchestration.
- Create `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/...`: small fixture Dart project.
- Create `test/tooling/architecture_diagrams/file_scanner_test.dart`.
- Create `test/tooling/architecture_diagrams/dart_graph_builder_test.dart`.
- Create `test/tooling/architecture_diagrams/mermaid_emitters_test.dart`.
- Create `test/tooling/architecture_diagrams/cli_test.dart`.

## Task 1: Dependencies and Fixture

**Files:**
- Modify: `pubspec.yaml`
- Create: `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/core/logger.dart`
- Create: `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/domain/repository.dart`
- Create: `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/data/repository_impl.dart`
- Create: `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/presentation/controller.dart`

- [ ] **Step 1: Add dev dependencies**

Run:

```bash
flutter pub add --dev analyzer args
```

Expected: `pubspec.yaml` includes explicit `analyzer` and `args` entries under `dev_dependencies`, and `pubspec.lock` is updated.

- [ ] **Step 2: Create fixture source files**

Create `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/core/logger.dart`:

```dart
class AppLogger {
  const AppLogger();

  void info(String message) {}
}
```

Create `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/domain/repository.dart`:

```dart
abstract class TermRepository {
  Future<List<String>> loadTerms();
}
```

Create `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/data/repository_impl.dart`:

```dart
import '../core/logger.dart';
import '../domain/repository.dart';

mixin CachedRepositoryMixin {
  void clearCache() {}
}

class TermRepositoryImpl with CachedRepositoryMixin implements TermRepository {
  const TermRepositoryImpl(this.logger);

  final AppLogger logger;

  @override
  Future<List<String>> loadTerms() async {
    logger.info('load');
    return const <String>['term'];
  }
}
```

Create `test/tooling/architecture_diagrams/fixtures/diagram_project/lib/presentation/controller.dart`:

```dart
import '../domain/repository.dart';

class TermController {
  const TermController(this.repository);

  final TermRepository repository;

  Future<List<String>> load() {
    return repository.loadTerms();
  }
}
```

- [ ] **Step 3: Commit**

Run:

```bash
git add pubspec.yaml pubspec.lock test/tooling/architecture_diagrams/fixtures
git commit -m "test: add architecture diagram fixture"
```

Expected: commit succeeds and contains only dependency and fixture setup.

## Task 2: File Scanner

**Files:**
- Create: `lib/tooling/architecture_diagrams/file_scanner.dart`
- Create: `test/tooling/architecture_diagrams/file_scanner_test.dart`

- [ ] **Step 1: Write failing scanner tests**

Create `test/tooling/architecture_diagrams/file_scanner_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/file_scanner.dart';

void main() {
  test('finds lib dart files and ignores generated files by default', () {
    final scanner = ProjectFileScanner(
      projectRoot: Directory('test/tooling/architecture_diagrams/fixtures/diagram_project'),
    );

    final files = scanner.findDartFiles().map((file) => file.path.replaceAll('\\', '/')).toList();

    expect(files, contains(endsWith('lib/presentation/controller.dart')));
    expect(files, isNot(contains(endsWith('.g.dart'))));
  });

  test('throws when project root does not exist', () {
    final scanner = ProjectFileScanner(projectRoot: Directory('missing_project_root'));

    expect(scanner.findDartFiles, throwsA(isA<FileSystemException>()));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/tooling/architecture_diagrams/file_scanner_test.dart
```

Expected: FAIL because `ProjectFileScanner` does not exist.

- [ ] **Step 3: Implement scanner**

Create `lib/tooling/architecture_diagrams/file_scanner.dart`:

```dart
import 'dart:io';

class ProjectFileScanner {
  const ProjectFileScanner({
    required this.projectRoot,
    this.includeTests = false,
  });

  final Directory projectRoot;
  final bool includeTests;

  List<File> findDartFiles() {
    if (!projectRoot.existsSync()) {
      throw FileSystemException('Project root does not exist', projectRoot.path);
    }

    final roots = <Directory>[Directory('${projectRoot.path}/lib')];
    if (includeTests) {
      roots.add(Directory('${projectRoot.path}/test'));
    }

    final files = <File>[];
    for (final root in roots) {
      if (!root.existsSync()) {
        continue;
      }
      files.addAll(
        root
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .where((file) => !_isIgnored(file.path)),
      );
    }

    files.sort((a, b) => a.path.compareTo(b.path));
    return files;
  }

  bool _isIgnored(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.contains('/.dart_tool/') ||
        normalized.contains('/build/') ||
        normalized.endsWith('.g.dart') ||
        normalized.endsWith('.freezed.dart') ||
        normalized.endsWith('.mocks.dart') ||
        normalized.endsWith('generated_plugin_registrant.dart');
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
flutter test test/tooling/architecture_diagrams/file_scanner_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
git add lib/tooling/architecture_diagrams/file_scanner.dart test/tooling/architecture_diagrams/file_scanner_test.dart
git commit -m "feat: scan Dart project files for diagrams"
```

Expected: commit succeeds.

## Task 3: Graph Model and Dart Analyzer Builder

**Files:**
- Create: `lib/tooling/architecture_diagrams/model.dart`
- Create: `lib/tooling/architecture_diagrams/dart_graph_builder.dart`
- Create: `test/tooling/architecture_diagrams/dart_graph_builder_test.dart`

- [ ] **Step 1: Write failing graph builder tests**

Create `test/tooling/architecture_diagrams/dart_graph_builder_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/dart_graph_builder.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/file_scanner.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/model.dart';

void main() {
  test('extracts classes, members, inheritance, mixins, and imports', () {
    final root = Directory('test/tooling/architecture_diagrams/fixtures/diagram_project');
    final files = ProjectFileScanner(projectRoot: root).findDartFiles();

    final graph = DartGraphBuilder(projectRoot: root).build(files);

    final repositoryImpl = graph.classes.singleWhere((type) => type.name == 'TermRepositoryImpl');
    expect(repositoryImpl.interfaces, contains('TermRepository'));
    expect(repositoryImpl.mixins, contains('CachedRepositoryMixin'));
    expect(repositoryImpl.fields.map((field) => field.name), contains('logger'));
    expect(repositoryImpl.methods.map((method) => method.name), contains('loadTerms'));
    expect(graph.imports.map((edge) => '${edge.from}->${edge.to}'), contains(contains('repository_impl.dart->')));
  });

  test('extracts direct method calls for sequence diagrams', () {
    final root = Directory('test/tooling/architecture_diagrams/fixtures/diagram_project');
    final files = ProjectFileScanner(projectRoot: root).findDartFiles();

    final graph = DartGraphBuilder(projectRoot: root).build(files);

    final controllerLoad = graph.methods.singleWhere(
      (method) => method.owner == 'TermController' && method.name == 'load',
    );
    expect(controllerLoad.calls.map((call) => call.methodName), contains('loadTerms'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/tooling/architecture_diagrams/dart_graph_builder_test.dart
```

Expected: FAIL because `DartGraphBuilder` and model classes do not exist.

- [ ] **Step 3: Implement model**

Create `lib/tooling/architecture_diagrams/model.dart`:

```dart
class ProjectGraph {
  const ProjectGraph({
    required this.files,
    required this.imports,
    required this.classes,
    required this.methods,
  });

  final List<DartFileNode> files;
  final List<ImportEdge> imports;
  final List<DartClassNode> classes;
  final List<DartMethodNode> methods;
}

class DartFileNode {
  const DartFileNode({required this.path});

  final String path;
}

class ImportEdge {
  const ImportEdge({required this.from, required this.to});

  final String from;
  final String to;
}

class DartClassNode {
  const DartClassNode({
    required this.name,
    required this.path,
    required this.isAbstract,
    required this.extendsName,
    required this.interfaces,
    required this.mixins,
    required this.fields,
    required this.constructors,
    required this.methods,
  });

  final String name;
  final String path;
  final bool isAbstract;
  final String? extendsName;
  final List<String> interfaces;
  final List<String> mixins;
  final List<DartFieldNode> fields;
  final List<DartConstructorNode> constructors;
  final List<DartMethodNode> methods;
}

class DartFieldNode {
  const DartFieldNode({required this.name, required this.type, required this.isPrivate});

  final String name;
  final String type;
  final bool isPrivate;
}

class DartConstructorNode {
  const DartConstructorNode({required this.name});

  final String name;
}

class DartMethodNode {
  const DartMethodNode({
    required this.owner,
    required this.name,
    required this.returnType,
    required this.isPrivate,
    required this.calls,
  });

  final String owner;
  final String name;
  final String returnType;
  final bool isPrivate;
  final List<MethodCallNode> calls;
}

class MethodCallNode {
  const MethodCallNode({required this.receiverName, required this.methodName});

  final String? receiverName;
  final String methodName;
}
```

- [ ] **Step 4: Implement analyzer graph builder**

Create `lib/tooling/architecture_diagrams/dart_graph_builder.dart`:

```dart
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'model.dart';

class DartGraphBuilder {
  const DartGraphBuilder({required this.projectRoot});

  final Directory projectRoot;

  ProjectGraph build(List<File> files) {
    final fileNodes = <DartFileNode>[];
    final imports = <ImportEdge>[];
    final classes = <DartClassNode>[];
    final methods = <DartMethodNode>[];

    for (final file in files) {
      final relativePath = _relativePath(file);
      fileNodes.add(DartFileNode(path: relativePath));

      final result = parseFile(path: file.path);
      final unit = result.unit;

      for (final directive in unit.directives.whereType<ImportDirective>()) {
        imports.add(ImportEdge(from: relativePath, to: directive.uri.stringValue ?? ''));
      }

      for (final declaration in unit.declarations.whereType<ClassDeclaration>()) {
        final classMethods = _methodsFor(declaration);
        methods.addAll(classMethods);
        classes.add(
          DartClassNode(
            name: declaration.namePart.typeName.lexeme,
            path: relativePath,
            isAbstract: declaration.abstractKeyword != null,
            extendsName: declaration.extendsClause?.superclass.name.lexeme,
            interfaces: declaration.implementsClause?.interfaces.map((type) => type.name.lexeme).toList() ?? const <String>[],
            mixins: declaration.withClause?.mixinTypes.map((type) => type.name.lexeme).toList() ?? const <String>[],
            fields: _fieldsFor(declaration),
            constructors: _constructorsFor(declaration),
            methods: classMethods,
          ),
        );
      }
    }

    imports.sort((a, b) => '${a.from}:${a.to}'.compareTo('${b.from}:${b.to}'));
    classes.sort((a, b) => a.name.compareTo(b.name));
    methods.sort((a, b) => '${a.owner}.${a.name}'.compareTo('${b.owner}.${b.name}'));

    return ProjectGraph(files: fileNodes, imports: imports, classes: classes, methods: methods);
  }

  List<DartFieldNode> _fieldsFor(ClassDeclaration declaration) {
    final fields = <DartFieldNode>[];
    for (final member in declaration.members.whereType<FieldDeclaration>()) {
      final type = member.fields.type?.toSource() ?? 'dynamic';
      for (final variable in member.fields.variables) {
        fields.add(DartFieldNode(name: variable.name.lexeme, type: type, isPrivate: variable.name.lexeme.startsWith('_')));
      }
    }
    fields.sort((a, b) => a.name.compareTo(b.name));
    return fields;
  }

  List<DartConstructorNode> _constructorsFor(ClassDeclaration declaration) {
    final constructors = declaration.members.whereType<ConstructorDeclaration>().map((constructor) {
      final className = declaration.namePart.typeName.lexeme;
      final suffix = constructor.name == null ? '' : '.${constructor.name!.lexeme}';
      return DartConstructorNode(name: '$className$suffix');
    }).toList();
    constructors.sort((a, b) => a.name.compareTo(b.name));
    return constructors;
  }

  List<DartMethodNode> _methodsFor(ClassDeclaration declaration) {
    final methods = declaration.members.whereType<MethodDeclaration>().map((method) {
      final visitor = _MethodCallVisitor();
      method.body.accept(visitor);
      final name = method.name.lexeme;
      return DartMethodNode(
        owner: declaration.namePart.typeName.lexeme,
        name: name,
        returnType: method.returnType?.toSource() ?? 'dynamic',
        isPrivate: name.startsWith('_'),
        calls: visitor.calls,
      );
    }).toList();
    methods.sort((a, b) => a.name.compareTo(b.name));
    return methods;
  }

  String _relativePath(File file) {
    final root = projectRoot.absolute.path.replaceAll('\\', '/');
    final path = file.absolute.path.replaceAll('\\', '/');
    return path.startsWith('$root/') ? path.substring(root.length + 1) : path;
  }
}

class _MethodCallVisitor extends RecursiveAstVisitor<void> {
  final calls = <MethodCallNode>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    calls.add(MethodCallNode(receiverName: node.target?.toSource(), methodName: node.methodName.lexeme));
    super.visitMethodInvocation(node);
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```bash
flutter test test/tooling/architecture_diagrams/dart_graph_builder_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

Run:

```bash
git add lib/tooling/architecture_diagrams/model.dart lib/tooling/architecture_diagrams/dart_graph_builder.dart test/tooling/architecture_diagrams/dart_graph_builder_test.dart
git commit -m "feat: build Dart architecture graph"
```

Expected: commit succeeds.

## Task 4: Mermaid Emitters

**Files:**
- Create: `lib/tooling/architecture_diagrams/mermaid_emitters.dart`
- Create: `test/tooling/architecture_diagrams/mermaid_emitters_test.dart`

- [ ] **Step 1: Write failing emitter tests**

Create `test/tooling/architecture_diagrams/mermaid_emitters_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/dart_graph_builder.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/file_scanner.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/mermaid_emitters.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/model.dart';

void main() {
  test('emits deterministic class diagram', () {
    final graph = _fixtureGraph();

    final output = MermaidClassEmitter().emit(graph);

    expect(output, contains('classDiagram'));
    expect(output, contains('TermRepository <|.. TermRepositoryImpl'));
    expect(output, contains('CachedRepositoryMixin <|-- TermRepositoryImpl'));
    expect(output, contains('class TermRepositoryImpl'));
    expect(output, contains('+Future<List<String>> loadTerms()'));
  });

  test('emits dependency graph', () {
    final graph = _fixtureGraph();

    final output = MermaidDependencyEmitter().emit(graph);

    expect(output, contains('flowchart LR'));
    expect(output, contains('data_repository_impl_dart'));
    expect(output, contains('domain_repository_dart'));
  });

  test('emits sequence diagram for explicit entrypoint', () {
    final graph = _fixtureGraph();

    final output = MermaidSequenceEmitter(maxDepth: 3).emit(graph, 'TermController.load');

    expect(output, contains('sequenceDiagram'));
    expect(output, contains('participant TermController'));
    expect(output, contains('TermController->>repository: loadTerms()'));
  });
}

ProjectGraph _fixtureGraph() {
  final root = Directory('test/tooling/architecture_diagrams/fixtures/diagram_project');
  final files = ProjectFileScanner(projectRoot: root).findDartFiles();
  return DartGraphBuilder(projectRoot: root).build(files);
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/tooling/architecture_diagrams/mermaid_emitters_test.dart
```

Expected: FAIL because `mermaid_emitters.dart` does not exist.

- [ ] **Step 3: Implement Mermaid emitters**

Create `lib/tooling/architecture_diagrams/mermaid_emitters.dart`:

```dart
import 'model.dart';

class MermaidClassEmitter {
  String emit(ProjectGraph graph) {
    final buffer = StringBuffer('classDiagram\n');
    for (final type in graph.classes) {
      buffer.writeln('  class ${type.name} {');
      for (final field in type.fields.where((field) => !field.isPrivate)) {
        buffer.writeln('    +${field.type} ${field.name}');
      }
      for (final constructor in type.constructors) {
        buffer.writeln('    +${constructor.name}()');
      }
      for (final method in type.methods.where((method) => !method.isPrivate)) {
        buffer.writeln('    +${method.returnType} ${method.name}()');
      }
      buffer.writeln('  }');
      if (type.extendsName != null) {
        buffer.writeln('  ${type.extendsName} <|-- ${type.name}');
      }
      for (final interface in type.interfaces) {
        buffer.writeln('  $interface <|.. ${type.name}');
      }
      for (final mixin in type.mixins) {
        buffer.writeln('  $mixin <|-- ${type.name}');
      }
    }
    return buffer.toString();
  }
}

class MermaidDependencyEmitter {
  String emit(ProjectGraph graph) {
    final buffer = StringBuffer('flowchart LR\n');
    for (final edge in graph.imports) {
      final from = _nodeId(edge.from);
      final to = _nodeId(edge.to);
      buffer.writeln('  $from["${edge.from}"] --> $to["${edge.to}"]');
    }
    return buffer.toString();
  }
}

class MermaidSequenceEmitter {
  const MermaidSequenceEmitter({required this.maxDepth});

  final int maxDepth;

  String emit(ProjectGraph graph, String entrypoint) {
    final parts = entrypoint.split('.');
    if (parts.length != 2) {
      throw ArgumentError.value(entrypoint, 'entrypoint', 'Use Class.method format');
    }

    final method = graph.methods.where((method) => method.owner == parts[0] && method.name == parts[1]).singleOrNull;
    if (method == null) {
      throw ArgumentError.value(entrypoint, 'entrypoint', 'Entrypoint was not found');
    }

    final buffer = StringBuffer('sequenceDiagram\n');
    buffer.writeln('  participant ${method.owner}');
    for (final call in method.calls.take(maxDepth)) {
      final target = call.receiverName ?? call.methodName;
      buffer.writeln('  participant $target');
      buffer.writeln('  ${method.owner}->>$target: ${call.methodName}()');
    }
    return buffer.toString();
  }
}

String _nodeId(String value) {
  return value.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
flutter test test/tooling/architecture_diagrams/mermaid_emitters_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
git add lib/tooling/architecture_diagrams/mermaid_emitters.dart test/tooling/architecture_diagrams/mermaid_emitters_test.dart
git commit -m "feat: emit Mermaid architecture diagrams"
```

Expected: commit succeeds.

## Task 5: CLI Orchestration

**Files:**
- Create: `lib/tooling/architecture_diagrams/cli.dart`
- Create: `tool/architecture_diagrams.dart`
- Create: `test/tooling/architecture_diagrams/cli_test.dart`

- [ ] **Step 1: Write failing CLI tests**

Create `test/tooling/architecture_diagrams/cli_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:data_visualizer/tooling/architecture_diagrams/cli.dart';

void main() {
  test('writes dependency and class diagrams', () async {
    final output = Directory.systemTemp.createTempSync('diagram_cli_test_');
    addTearDown(() => output.deleteSync(recursive: true));

    final exitCode = await ArchitectureDiagramCli().run([
      '--project',
      'test/tooling/architecture_diagrams/fixtures/diagram_project',
      '--out',
      output.path,
    ]);

    expect(exitCode, 0);
    expect(File('${output.path}/dependency_graph.mmd').existsSync(), isTrue);
    expect(File('${output.path}/class_diagram.mmd').existsSync(), isTrue);
  });

  test('writes sequence diagram for entrypoint', () async {
    final output = Directory.systemTemp.createTempSync('diagram_cli_sequence_test_');
    addTearDown(() => output.deleteSync(recursive: true));

    final exitCode = await ArchitectureDiagramCli().run([
      '--project',
      'test/tooling/architecture_diagrams/fixtures/diagram_project',
      '--out',
      output.path,
      '--entrypoint',
      'TermController.load',
    ]);

    expect(exitCode, 0);
    expect(File('${output.path}/sequence_TermController_load.mmd').existsSync(), isTrue);
  });

  test('returns non-zero for missing entrypoint', () async {
    final output = Directory.systemTemp.createTempSync('diagram_cli_missing_entrypoint_test_');
    addTearDown(() => output.deleteSync(recursive: true));

    final exitCode = await ArchitectureDiagramCli().run([
      '--project',
      'test/tooling/architecture_diagrams/fixtures/diagram_project',
      '--out',
      output.path,
      '--entrypoint',
      'Missing.entrypoint',
    ]);

    expect(exitCode, 1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/tooling/architecture_diagrams/cli_test.dart
```

Expected: FAIL because `ArchitectureDiagramCli` does not exist.

- [ ] **Step 3: Implement CLI**

Create `lib/tooling/architecture_diagrams/cli.dart`:

```dart
import 'dart:io';

import 'package:args/args.dart';

import 'dart_graph_builder.dart';
import 'file_scanner.dart';
import 'mermaid_emitters.dart';

class ArchitectureDiagramCli {
  Future<int> run(List<String> args) async {
    final parser = ArgParser()
      ..addOption('project', defaultsTo: '.')
      ..addOption('out', defaultsTo: 'docs/diagrams')
      ..addFlag('include-tests', defaultsTo: false)
      ..addMultiOption('entrypoint')
      ..addOption('max-depth', defaultsTo: '4')
      ..addOption('format', defaultsTo: 'mermaid', allowed: const ['mermaid']);

    try {
      final result = parser.parse(args);
      final maxDepth = int.parse(result.option('max-depth')!);
      if (maxDepth <= 0) {
        throw const FormatException('max-depth must be positive');
      }

      final projectRoot = Directory(result.option('project')!);
      final output = Directory(result.option('out')!);
      output.createSync(recursive: true);

      final files = ProjectFileScanner(
        projectRoot: projectRoot,
        includeTests: result.flag('include-tests'),
      ).findDartFiles();
      if (files.isEmpty) {
        stderr.writeln('No analyzable Dart files found.');
        return 1;
      }

      final graph = DartGraphBuilder(projectRoot: projectRoot).build(files);
      File('${output.path}/dependency_graph.mmd').writeAsStringSync(MermaidDependencyEmitter().emit(graph));
      File('${output.path}/class_diagram.mmd').writeAsStringSync(MermaidClassEmitter().emit(graph));

      for (final entrypoint in result.multiOption('entrypoint')) {
        final fileName = 'sequence_${entrypoint.replaceAll('.', '_')}.mmd';
        File('${output.path}/$fileName').writeAsStringSync(
          MermaidSequenceEmitter(maxDepth: maxDepth).emit(graph, entrypoint),
        );
      }

      return 0;
    } on Object catch (error) {
      stderr.writeln(error);
      return 1;
    }
  }
}
```

Create `tool/architecture_diagrams.dart`:

```dart
import 'dart:io';

import 'package:data_visualizer/tooling/architecture_diagrams/cli.dart';

Future<void> main(List<String> args) async {
  final exitCode = await ArchitectureDiagramCli().run(args);
  if (exitCode != 0) {
    exit(exitCode);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
flutter test test/tooling/architecture_diagrams/cli_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
git add lib/tooling/architecture_diagrams/cli.dart tool/architecture_diagrams.dart test/tooling/architecture_diagrams/cli_test.dart
git commit -m "feat: add architecture diagram CLI"
```

Expected: commit succeeds.

## Task 6: Final Verification and Generated Example

**Files:**
- Generated: `docs/diagrams/dependency_graph.mmd`
- Generated: `docs/diagrams/class_diagram.mmd`
- Generated: `docs/diagrams/sequence_TermController_loadTermsWithInitialDateFilter.mmd`

- [ ] **Step 1: Format source**

Run:

```bash
dart format lib/tooling tool test/tooling
```

Expected: formatter completes successfully.

- [ ] **Step 2: Run focused tests**

Run:

```bash
flutter test test/tooling/architecture_diagrams
```

Expected: all architecture diagram tests pass.

- [ ] **Step 3: Run full tests**

Run:

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 4: Run static analysis**

Run:

```bash
flutter analyze
```

Expected: no errors.

- [ ] **Step 5: Generate diagrams for current project**

Run:

```bash
dart run tool/architecture_diagrams.dart \
  --project . \
  --out docs/diagrams \
  --entrypoint TermController.loadTermsWithInitialDateFilter
```

Expected: `docs/diagrams/dependency_graph.mmd`, `docs/diagrams/class_diagram.mmd`, and `docs/diagrams/sequence_TermController_loadTermsWithInitialDateFilter.mmd` are written.

- [ ] **Step 6: Commit final verified result**

Run:

```bash
git add lib/tooling tool test/tooling docs/diagrams pubspec.yaml pubspec.lock
git commit -m "feat: generate Dart architecture diagrams"
```

Expected: commit succeeds.
