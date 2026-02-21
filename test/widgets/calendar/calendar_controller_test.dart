import 'dart:math';

import 'package:data_visualizer/features/term/domain/entities/las.dart';
import 'package:data_visualizer/features/term/domain/entities/term.dart';
import 'package:data_visualizer/features/term/domain/repositories/term_repository_contract.dart';
import 'package:data_visualizer/features/term/domain/use_cases/get_terms_by_date_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/get_terms_by_range_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/load_last_directory_terms_use_case.dart';
import 'package:data_visualizer/features/term/domain/use_cases/load_terms_use_case.dart';
import 'package:data_visualizer/features/term/presentation/controllers/term_controller.dart';
import 'package:data_visualizer/widgets/calendar/calendar_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  group('CalendarController', () {
    test(
      'day selection stays clickable and filters by selected date',
      () async {
        final repository = _FakeTermRepository(termsToLoad: _seedTerms());
        final termController = _buildTermController(repository);
        final controller = CalendarController(termController: termController);

        await termController.loadTerms();
        controller.selectDay(DateTime(2026, 2, 18), DateTime(2026, 2, 18));

        expect(
          controller.stateSelectedDay.value,
          equals(DateTime(2026, 2, 18)),
        );
        expect(termController.terms, hasLength(1));
        expect(
          controller.rangeSelectionMode.value,
          equals(RangeSelectionMode.toggledOff),
        );
      },
    );

    test(
      'long press enables range mode and range selection applies filter',
      () async {
        final repository = _FakeTermRepository(termsToLoad: _seedTerms());
        final termController = _buildTermController(repository);
        final controller = CalendarController(termController: termController);

        await termController.loadTerms();
        controller
          ..longPressed(DateTime(2026, 2, 17), DateTime(2026, 2, 17))
          ..selectRange(
            DateTime(2026, 2, 17),
            DateTime(2026, 2, 20),
            DateTime(2026, 2, 20),
          );

        expect(termController.terms, hasLength(3));
        expect(
          controller.rangeSelectionMode.value,
          equals(RangeSelectionMode.toggledOff),
        );
        expect(controller.rangeStart.value, equals(DateTime(2026, 2, 17)));
        expect(controller.rangeEnd.value, equals(DateTime(2026, 2, 20)));
      },
    );

    test('resetSelection clears calendar state after manual reload', () async {
      final repository = _FakeTermRepository(termsToLoad: _seedTerms());
      final termController = _buildTermController(repository);
      final controller = CalendarController(termController: termController);

      await termController.loadTerms();
      controller
        ..longPressed(DateTime(2026, 2, 17), DateTime(2026, 2, 17))
        ..selectRange(
          DateTime(2026, 2, 17),
          DateTime(2026, 2, 20),
          DateTime(2026, 2, 20),
        )
        ..resetSelection();

      expect(controller.stateSelectedDay.value, isNull);
      expect(controller.rangeStart.value, isNull);
      expect(controller.rangeEnd.value, isNull);
      expect(
        controller.rangeSelectionMode.value,
        equals(RangeSelectionMode.toggledOff),
      );
    });
  });
}

TermController _buildTermController(_FakeTermRepository repository) {
  return TermController(
    loadTermsUseCase: LoadTermsUseCase(repository: repository),
    loadLastDirectoryTermsUseCase: LoadLastDirectoryTermsUseCase(
      repository: repository,
    ),
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

class _FakeTermRepository implements TermRepositoryContract {
  _FakeTermRepository({required this.termsToLoad});

  final List<Term> termsToLoad;
  List<Term> _loaded = <Term>[];

  @override
  Future<List<Term>> loadAllTerms() async {
    _loaded = termsToLoad;
    return termsToLoad;
  }

  @override
  Future<List<Term>> loadTermsFromLastDirectory() async {
    _loaded = termsToLoad;
    return termsToLoad;
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
