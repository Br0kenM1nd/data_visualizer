import 'dart:io';
import 'dart:math';

import 'package:data_visualizer/features/term/data/datasources/data_source.dart';
import 'package:data_visualizer/features/term/data/parsers/parser.dart';
import 'package:data_visualizer/features/term/data/repositories/term_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TermRepositoryImpl', () {
    test(
      'loads terms, persists selected directory and filters by date/range',
      () async {
        final fakeSource = _FakeDataSource(
          pickedSelection: DirectorySelection(
            path: '/mock/path',
            files: <File>[
              File('a.las'),
              File('b.las'),
              File('c.las'),
              File('d.las'),
            ],
          ),
        );
        final fakeParser = _FakeParser(
          names: <String>['a.las', 'b.las', 'c.las', 'd.las'],
          times: <DateTime>[
            DateTime(2026, 2, 17, 11),
            DateTime(2026, 2, 18, 11),
            DateTime(2026, 2, 19, 11),
            DateTime(2025, 2, 18, 11),
          ],
          points: <List<Point<double>>>[
            <Point<double>>[const Point<double>(0, 20)],
            <Point<double>>[const Point<double>(0, 21)],
            <Point<double>>[const Point<double>(0, 22)],
            <Point<double>>[const Point<double>(0, 23)],
          ],
        );

        final repository = TermRepositoryImpl(
          source: fakeSource,
          parser: fakeParser,
        );

        final loaded = await repository.loadAllTerms();

        expect(loaded, hasLength(4));
        expect(fakeSource.savedDirectoryPath, equals('/mock/path'));
        expect(repository.getTermsByDate(DateTime(2026, 2, 18)), hasLength(1));
        expect(
          repository.getTermsByRange(
            DateTime(2026, 2, 17),
            DateTime(2026, 2, 19),
          ),
          hasLength(2),
        );
        expect(
          repository.getTermsByRange(
            DateTime(2026, 2, 17),
            DateTime(2026, 2, 20),
          ),
          hasLength(3),
        );
      },
    );

    test('returns empty list when source selection is canceled', () async {
      final repository = TermRepositoryImpl(
        source: _FakeDataSource(pickedSelection: null),
        parser: const _FakeParser(
          names: <String>[],
          times: <DateTime>[],
          points: <List<Point<double>>>[],
        ),
      );

      final loaded = await repository.loadAllTerms();

      expect(loaded, isEmpty);
      expect(repository.getTermsByDate(DateTime(2026, 2, 18)), isEmpty);
    });

    test('restores terms from last directory on startup', () async {
      final fakeSource = _FakeDataSource(
        pickedSelection: null,
        lastDirectoryPath: '/mock/last',
        filesByDirectoryPath: <String, List<File>>{
          '/mock/last': <File>[File('a.las')],
        },
      );
      final repository = TermRepositoryImpl(
        source: fakeSource,
        parser: _FakeParser(
          names: <String>['a.las'],
          times: <DateTime>[DateTime(2026, 2, 18, 11)],
          points: <List<Point<double>>>[
            <Point<double>>[const Point<double>(0, 20)],
          ],
        ),
      );

      final loaded = await repository.loadTermsFromLastDirectory();

      expect(loaded, hasLength(1));
      expect(fakeSource.clearLastDirectoryCalled, isFalse);
    });

    test('clears last directory when startup load is invalid', () async {
      final fakeSource = _FakeDataSource(
        pickedSelection: null,
        lastDirectoryPath: '/mock/invalid',
        filesByDirectoryPath: <String, List<File>>{
          '/mock/invalid': <File>[File('broken.las')],
        },
      );
      final repository = TermRepositoryImpl(
        source: fakeSource,
        parser: _FakeParser(
          names: <String>['broken.las'],
          times: <DateTime>[DateTime.fromMillisecondsSinceEpoch(0)],
          points: <List<Point<double>>>[
            <Point<double>>[const Point<double>(0, 20)],
          ],
        ),
      );

      final loaded = await repository.loadTermsFromLastDirectory();

      expect(loaded, isEmpty);
      expect(fakeSource.clearLastDirectoryCalled, isTrue);
      expect(fakeSource.lastDirectoryPath, isNull);
    });
  });
}

class _FakeDataSource extends DataSource {
  _FakeDataSource({
    required this.pickedSelection,
    this.lastDirectoryPath,
    Map<String, List<File>>? filesByDirectoryPath,
  }) : filesByDirectoryPath = filesByDirectoryPath ?? <String, List<File>>{};

  final DirectorySelection? pickedSelection;
  String? lastDirectoryPath;
  final Map<String, List<File>> filesByDirectoryPath;
  String? savedDirectoryPath;
  bool clearLastDirectoryCalled = false;

  @override
  Future<DirectorySelection?> pickDirectorySelection() async => pickedSelection;

  @override
  Future<List<File>> getLasFilesFromDirectory(String directoryPath) async {
    return filesByDirectoryPath[directoryPath] ?? <File>[];
  }

  @override
  Future<void> saveLastDirectory(String directoryPath) async {
    savedDirectoryPath = directoryPath;
    lastDirectoryPath = directoryPath;
  }

  @override
  Future<String?> getLastDirectory() async => lastDirectoryPath;

  @override
  Future<void> clearLastDirectory() async {
    clearLastDirectoryCalled = true;
    lastDirectoryPath = null;
  }
}

class _FakeParser implements Parser {
  const _FakeParser({
    required this.names,
    required this.times,
    required this.points,
  });

  final List<String> names;
  final List<DateTime> times;
  final List<List<Point<double>>> points;

  @override
  List<String> getNames(List<File> _) => names;

  @override
  List<DateTime> getTimes(List<File> _) => times;

  @override
  Future<List<List<Point<double>>>> getPoints(List<File> _) async => points;
}
