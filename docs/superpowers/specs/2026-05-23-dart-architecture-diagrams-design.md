# Dart Architecture Diagrams Design

## Context

The codebase is a Flutter/Dart project, and most target projects for this tool are also Dart or Flutter. The tool should still be portable across repositories: it must accept a project path instead of being hardcoded to the current repository.

The first implementation will generate Mermaid `.mmd` files. Mermaid is the primary output format because it is easy to review in GitHub, GitLab, Markdown tooling, and documentation folders without requiring a PlantUML renderer.

## Goals

- Generate readable dependency diagrams for Dart/Flutter projects.
- Show class relationships: inheritance, interfaces, mixins, fields, constructors, and methods.
- Generate static UML sequence diagrams for selected entrypoint methods.
- Keep the tool runnable from different project roots.
- Make output deterministic so diagram diffs are reviewable.

## Non-Goals

- Runtime tracing is out of scope for the first stage.
- PlantUML output is out of scope for the first stage.
- Non-Dart adapters are out of scope for the first stage.
- Full dynamic dispatch resolution is out of scope for the first stage.

## Recommended Approach

Build a Dart CLI backed by `package:analyzer`.

The CLI will parse Dart source files through AST APIs instead of regular expressions. This is the best fit for Dart 3 syntax, Flutter code, constructors, mixins, generics, multiline declarations, comments, and nested members.

The implementation should keep a small internal graph model, but it does not need a full plugin or adapter system yet. That preserves a path toward future TypeScript or Python adapters without adding first-stage complexity.

## CLI

Initial command shape:

```bash
dart run tool/architecture_diagrams.dart --project . --out docs/diagrams
```

Supported first-stage options:

- `--project <path>`: root of the project to analyze.
- `--out <path>`: output directory for generated `.mmd` files.
- `--include-tests`: include `test/` in addition to `lib/`.
- `--entrypoint <Class.method>`: generate a sequence diagram from an entrypoint. This option may be repeated.
- `--max-depth <n>`: maximum call depth for sequence diagrams.
- `--format mermaid`: accepted for forward compatibility; Mermaid is the only first-stage format.

## File Scanning

The scanner reads Dart files from:

- `lib/`
- `test/` only when `--include-tests` is provided

It ignores generated and cache/build artifacts:

- `.dart_tool/`
- `build/`
- `.g.dart`
- `.freezed.dart`
- `.mocks.dart`
- generated Flutter registrants

## Internal Model

The analyzer step produces a project graph with:

- files and package-relative paths
- imports, exports, and parts where useful
- classes, enums, mixins, extensions, and abstract classes
- `extends`, `implements`, and `with` relationships
- constructors
- fields
- methods and getters/setters
- direct method invocation expressions where the receiver can be resolved statically enough for a useful sequence diagram

The model should sort all output by stable keys: path, class name, member name, then relationship type.

## Mermaid Outputs

### Dependency Graph

Output file:

```text
dependency_graph.mmd
```

This diagram uses Mermaid flowchart syntax. It shows file or folder dependencies through imports. For Flutter projects, the emitter should group common layers when paths make that clear:

- `core`
- `features/*/domain`
- `features/*/data`
- `features/*/presentation`
- `widgets`
- `pages`

The graph should prefer readability over completeness. When a project is large, the first implementation may aggregate dependencies by folder instead of listing every file edge.

### Class Diagram

Output file:

```text
class_diagram.mmd
```

This diagram uses Mermaid class diagram syntax. It includes:

- classes and interfaces
- inheritance and implementation edges
- mixin usage edges
- fields
- constructors
- public methods by default

Private members may be omitted by default to keep diagrams readable.

### Sequence Diagrams

Output files:

```text
sequence_<entrypoint>.mmd
```

Sequence diagrams are generated only for explicit entrypoints. Example:

```bash
dart run tool/architecture_diagrams.dart \
  --project . \
  --out docs/diagrams \
  --entrypoint TermController.loadTermsWithInitialDateFilter
```

The sequence diagram follows static calls from the entrypoint up to `--max-depth`. It should show actor/class participants and direct call edges.

This is a static approximation. It can show flows such as controller to use case to repository to datasource/parser, but it cannot guarantee full runtime behavior for callbacks, dependency injection containers, GetX reactivity, reflection-like behavior, or polymorphic dispatch.

## Error Handling

The CLI should fail with a clear message when:

- `--project` does not exist
- no analyzable Dart files are found
- an `--entrypoint` cannot be found
- `--max-depth` is not a positive integer
- the output directory cannot be created or written

Parse errors in individual files should be reported with path context. The first implementation can fail the run on analyzer parse errors instead of producing partial diagrams.

## Testing

Add a small fixture project under:

```text
test/fixtures/diagram_project/
```

Tests should cover:

- class extraction
- fields, constructors, and methods
- `extends`, `implements`, and `with`
- import-based dependency graph extraction
- static sequence call flow from a simple entrypoint
- deterministic Mermaid output ordering
- CLI validation for missing project path and missing entrypoint

Tests should compare structured model data where possible. Mermaid snapshot-style expectations are acceptable for the emitters as long as the output is small and deterministic.

## First Implementation Boundary

The first stage is complete when:

- `dart run tool/architecture_diagrams.dart --project . --out docs/diagrams` generates `dependency_graph.mmd` and `class_diagram.mmd`.
- At least one explicit `--entrypoint` generates a sequence diagram.
- Unit tests cover the scanner, analyzer graph builder, Mermaid emitters, and CLI validation.
- The generated diagrams are stable across repeated runs without source changes.
