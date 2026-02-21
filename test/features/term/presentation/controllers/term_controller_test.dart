import 'dart:math';

import 'package:data_visualizer/features/term/domain/entities/las.dart';
import 'package:data_visualizer/features/term/domain/entities/term.dart';
import 'package:data_visualizer/features/term/domain/repositories/term_repository_contract.dart';
import 'package:data_visualizer/features/term/domain/use_cases/get_terms_by_date_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/get_terms_by_range_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/load_last_directory_terms_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/load_terms_use_case.dart';
import 'package:data_visualizer/features/term/presentation/controllers/term_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TermController', () {
    test('loadTerms applies initial date filter', () async {
      final repository = _FakeTermRepository(termsToLoad: _seedTerms());
      final controller = _buildController(repository);

      await controller.loadTermsWithInitialDateFilter(initialFilterDate: DateTime(2026, 2, 18));

      expect(controller.status.value, equals(TermViewStatus.loaded));
      expect(controller.terms, hasLength(1));
      expect(controller.terms.first.show, isTrue);
    });

    test('loadTerms sets empty status for empty source', () async {
      final repository = _FakeTermRepository(termsToLoad: const <Term>[]);
      final controller = _buildController(repository);

      await controller.loadTerms();

      expect(controller.status.value, equals(TermViewStatus.empty));
      expect(controller.terms, isEmpty);
    });

    test('loadTerms sets error status on repository failure', () async {
      final repository = _FakeTermRepository(termsToLoad: const <Term>[], throwOnLoad: true);
      final controller = _buildController(repository);

      await controller.loadTerms();

      expect(controller.status.value, equals(TermViewStatus.error));
      expect(controller.errorMessage.value, isNotNull);
    });

    test('restoreLastDirectoryTerms sets loaded status when data exists', () async {
      final repository = _FakeTermRepository(
        termsToLoad: const <Term>[],
        termsFromLastDirectory: _seedTerms(),
      );
      final controller = _buildController(repository);

      await controller.restoreLastDirectoryTerms(initialFilterDate: DateTime(2026, 2, 18));

      expect(controller.status.value, equals(TermViewStatus.loaded));
      expect(controller.terms, hasLength(1));
      expect(controller.terms.first.show, isTrue);
    });

    test('restoreLastDirectoryTerms keeps idle status when nothing restored', () async {
      final repository = _FakeTermRepository(termsToLoad: const <Term>[]);
      final controller = _buildController(repository);

      await controller.restoreLastDirectoryTerms();

      expect(controller.status.value, equals(TermViewStatus.idle));
      expect(controller.terms, isEmpty);
    });

    test('selectSingleDate and selectRange filter terms', () async {
      final repository = _FakeTermRepository(termsToLoad: _seedTerms());
      final controller = _buildController(repository);
      await controller.loadTermsWithInitialDateFilter(initialFilterDate: DateTime(2026, 2, 18));

      controller.selectSingleDate(DateTime(2026, 2, 18));
      expect(controller.terms, hasLength(1));

      controller.selectRange(DateTime(2026, 2, 17, 12), DateTime(2026, 2, 20));
      expect(controller.terms, hasLength(2));
    });

    test('toggleVisibility and filterTermsByRange update show flags', () async {
      final repository = _FakeTermRepository(termsToLoad: _seedTerms());
      final controller = _buildController(repository);
      await controller.loadTermsWithInitialDateFilter(initialFilterDate: DateTime(2026, 2, 18));
      controller.selectRange(DateTime(2026, 2, 16), DateTime(2026, 2, 20));
      expect(controller.terms, hasLength(3));

      controller.toggleVisibility(1);
      expect(controller.terms[1].show, isFalse);

      controller.filterTermsByIndexRange(0, 1);
      expect(controller.terms[0].show, isTrue);
      expect(controller.terms[1].show, isTrue);
      expect(controller.terms[2].show, isFalse);
    });

    test('selectSingleDate shows only first thermogram by default', () async {
      final repository = _FakeTermRepository(termsToLoad: _seedTermsForOneDay());
      final controller = _buildController(repository);
      await controller.loadTermsWithInitialDateFilter(initialFilterDate: DateTime(2026, 2, 18));

      controller.selectSingleDate(DateTime(2026, 2, 18));

      expect(controller.terms, hasLength(3));
      expect(controller.terms[0].show, isTrue);
      expect(controller.terms[1].show, isFalse);
      expect(controller.terms[2].show, isFalse);
    });

    test('toggleAllDayThermograms toggles show all and hide all', () async {
      final repository = _FakeTermRepository(termsToLoad: _seedTermsForOneDay());
      final controller = _buildController(repository);
      await controller.loadTermsWithInitialDateFilter(initialFilterDate: DateTime(2026, 2, 18));

      controller.toggleAllDayThermograms();
      expect(controller.terms.every((term) => term.show), isTrue);

      controller.toggleAllDayThermograms();
      expect(controller.terms.every((term) => !term.show), isTrue);
    });
  });
}

TermController _buildController(_FakeTermRepository repository) {
  return TermController(
    loadTermsUseCase: LoadTermsUseCase(repository: repository),
    loadLastDirectoryTermsUseCase: LoadLastDirectoryTermsUseCase(repository: repository),
    getTermsByDateUseCase: GetTermsByDateUseCase(repository: repository),
    getTermsByRangeUseCase: GetTermsByRangeUseCase(repository: repository),
  );
}

List<Term> _seedTerms() {
  return <Term>[
    Las(
      name: 'a.las',
      points: const <Point<double>>[Point<double>(0, 20)],
      dateTime: DateTime(2026, 2, 17, 10),
    ),
    Las(
      name: 'b.las',
      points: const <Point<double>>[Point<double>(0, 21)],
      dateTime: DateTime(2026, 2, 18, 10),
    ),
    Las(
      name: 'c.las',
      points: const <Point<double>>[Point<double>(0, 22)],
      dateTime: DateTime(2026, 2, 19, 10),
    ),
    Las(
      name: 'd.las',
      points: const <Point<double>>[Point<double>(0, 23)],
      dateTime: DateTime(2025, 2, 18, 10),
    ),
  ];
}

List<Term> _seedTermsForOneDay() {
  return <Term>[
    Las(
      name: 'd1.las',
      points: const <Point<double>>[Point<double>(0, 20)],
      dateTime: DateTime(2026, 2, 18, 9),
    ),
    Las(
      name: 'd2.las',
      points: const <Point<double>>[Point<double>(0, 21)],
      dateTime: DateTime(2026, 2, 18, 10),
    ),
    Las(
      name: 'd3.las',
      points: const <Point<double>>[Point<double>(0, 22)],
      dateTime: DateTime(2026, 2, 18, 11),
    ),
  ];
}

class _FakeTermRepository implements TermRepositoryContract {
  _FakeTermRepository({
    required this.termsToLoad,
    this.termsFromLastDirectory = const <Term>[],
    this.throwOnLoad = false,
  });

  final List<Term> termsToLoad;
  final List<Term> termsFromLastDirectory;
  final bool throwOnLoad;
  List<Term> _loaded = <Term>[];

  @override
  Future<List<Term>> loadAllTerms() async {
    if (throwOnLoad) {
      throw StateError('load failed');
    }

    _loaded = termsToLoad;
    return termsToLoad;
  }

  @override
  Future<List<Term>> loadTermsFromLastDirectory() async {
    _loaded = termsFromLastDirectory;
    return termsFromLastDirectory;
  }

  @override
  List<Term> getTermsByDate(DateTime date) {
    return _loaded
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

  @override
  List<Term> getTermsByRange(DateTime start, DateTime end) {
    return _loaded
        .where((term) {
          if (term is! Las) {
            return false;
          }

          return term.dateTime.isAfter(start) && term.dateTime.isBefore(end);
        })
        .toList(growable: false);
  }
}
