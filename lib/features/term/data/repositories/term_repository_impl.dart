import 'dart:io';

import '../../../../core/logger/logger.dart';
import '../../domain/entities/las.dart';
import '../../domain/entities/term.dart';
import '../../domain/repositories/term_repository_contract.dart';
import '../datasources/data_source.dart';
import '../parsers/las_parser.dart';
import '../parsers/parser.dart';

class TermRepositoryImpl implements TermRepositoryContract {
  const TermRepositoryImpl({
    this.source = const DataSource(),
    this.parser = const LasParser(),
  });

  final DataSource source;
  final Parser parser;

  static List<Term> _terms = <Term>[];

  @override
  Future<List<Term>> loadAllTerms() async {
    final selection = await source.pickDirectorySelection();
    if (selection == null) {
      _terms = <Term>[];
      return const <Term>[];
    }

    return _loadFromFiles(
      files: selection.files,
      selectedDirectory: selection.path,
      persistDirectoryOnSuccess: true,
      clearDirectoryOnFailure: false,
    );
  }

  @override
  Future<List<Term>> loadTermsFromLastDirectory() async {
    final lastDirectory = await source.getLastDirectory();
    if (lastDirectory == null || lastDirectory.isEmpty) {
      return const <Term>[];
    }

    final files = await source.getLasFilesFromDirectory(lastDirectory);
    return _loadFromFiles(
      files: files,
      selectedDirectory: lastDirectory,
      persistDirectoryOnSuccess: false,
      clearDirectoryOnFailure: true,
    );
  }

  @override
  List<Term> getTermsByRange(DateTime start, DateTime end) {
    if (_terms.isEmpty) {
      return <Term>[];
    }

    return _terms
        .where((term) {
          if (term is! Las) {
            return false;
          }

          return term.dateTime.isAfter(start) && term.dateTime.isBefore(end);
        })
        .toList(growable: false);
  }

  @override
  List<Term> getTermsByDate(DateTime date) {
    if (_terms.isEmpty) {
      return <Term>[];
    }

    return _terms
        .where((term) {
          if (term is! Las) {
            return false;
          }

          return term.dateTime.day == date.day &&
              term.dateTime.month == date.month &&
              term.dateTime.year == date.year;
        })
        .toList(growable: false);
  }

  Future<List<Term>> _buildData(List<File> files) async {
    final names = parser.getNames(files);
    final times = parser.getTimes(files);
    final points = await parser.getPoints(files);

    if (names.length != points.length || names.length != times.length) {
      throw const FormatException(
        'LAS parsing produced inconsistent array sizes',
      );
    }

    if (times.any((time) => time.millisecondsSinceEpoch == 0)) {
      throw const FormatException(
        'One or more LAS filenames have invalid datetime',
      );
    }

    return List<Term>.generate(names.length, (i) {
      return Las(name: names[i], points: points[i], dateTime: times[i]);
    }, growable: false);
  }

  Future<List<Term>> _loadFromFiles({
    required List<File> files,
    required String selectedDirectory,
    required bool persistDirectoryOnSuccess,
    required bool clearDirectoryOnFailure,
  }) async {
    if (files.isEmpty) {
      _terms = <Term>[];
      if (clearDirectoryOnFailure) {
        await source.clearLastDirectory();
      }
      return const <Term>[];
    }

    try {
      _terms = await _buildData(files);
      if (persistDirectoryOnSuccess) {
        await source.saveLastDirectory(selectedDirectory);
      }
      return List<Term>.unmodifiable(_terms);
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Failed to load terms from directory: $selectedDirectory',
        error: error,
        stackTrace: stackTrace,
      );
      _terms = <Term>[];
      if (clearDirectoryOnFailure) {
        await source.clearLastDirectory();
      }
      return const <Term>[];
    }
  }
}
