import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/logger/logger.dart';
import '../../domain/entities/term.dart';
import '../../domain/use_cases/get_terms_by_date_use_case.dart';
import '../../domain/use_cases/get_terms_by_range_use_case.dart';
import '../../domain/use_cases/load_last_directory_terms_use_case.dart';
import '../../domain/use_cases/load_terms_use_case.dart';

enum TermViewStatus { idle, loading, loaded, empty, error }

class TermController extends GetxController {
  TermController({
    required LoadTermsUseCase loadTermsUseCase,
    required LoadLastDirectoryTermsUseCase loadLastDirectoryTermsUseCase,
    required GetTermsByDateUseCase getTermsByDateUseCase,
    required GetTermsByRangeUseCase getTermsByRangeUseCase,
  }) : _loadTermsUseCase = loadTermsUseCase,
       _loadLastDirectoryTermsUseCase = loadLastDirectoryTermsUseCase,
       _getTermsByDateUseCase = getTermsByDateUseCase,
       _getTermsByRangeUseCase = getTermsByRangeUseCase;

  final LoadTermsUseCase _loadTermsUseCase;
  final LoadLastDirectoryTermsUseCase _loadLastDirectoryTermsUseCase;
  final GetTermsByDateUseCase _getTermsByDateUseCase;
  final GetTermsByRangeUseCase _getTermsByRangeUseCase;

  final Rx<TermViewStatus> status = TermViewStatus.idle.obs;
  final RxnString errorMessage = RxnString();
  final RxList<Term> terms = <Term>[].obs;

  final ZoomPanBehavior zoom = ZoomPanBehavior(
    enableSelectionZooming: true,
    enablePinching: true,
    enableMouseWheelZooming: true,
  );

  Future<void> loadTerms() async {
    await loadTermsWithInitialDateFilter();
  }

  Future<void> loadTermsWithInitialDateFilter({
    DateTime? initialFilterDate,
  }) async {
    status.value = TermViewStatus.loading;
    errorMessage.value = null;

    try {
      final loadedTerms = await _loadTermsUseCase();
      if (loadedTerms.isEmpty) {
        terms.clear();
        status.value = TermViewStatus.empty;
        return;
      }

      final filterDate = initialFilterDate ?? DateTime.now();
      final filtered = _getTermsByDateUseCase(filterDate);
      final prepared = _prepareInitialDayVisibility(filtered);
      terms.assignAll(prepared);
      status.value = prepared.isEmpty
          ? TermViewStatus.empty
          : TermViewStatus.loaded;
    } on Object catch (error, stackTrace) {
      appLogger.e('Failed to load terms', error: error, stackTrace: stackTrace);
      errorMessage.value = error.toString();
      status.value = TermViewStatus.error;
    }
  }

  Future<void> restoreLastDirectoryTerms({DateTime? initialFilterDate}) async {
    try {
      final loadedTerms = await _loadLastDirectoryTermsUseCase();
      if (loadedTerms.isEmpty) {
        terms.clear();
        status.value = TermViewStatus.idle;
        return;
      }

      final filterDate = initialFilterDate ?? DateTime.now();
      final filtered = _getTermsByDateUseCase(filterDate);
      final prepared = _prepareInitialDayVisibility(filtered);
      terms.assignAll(prepared);
      status.value = prepared.isEmpty
          ? TermViewStatus.empty
          : TermViewStatus.loaded;
    } on Object catch (error, stackTrace) {
      appLogger.w(
        'Skipping auto-load from last directory due to error',
        error: error,
        stackTrace: stackTrace,
      );
      status.value = TermViewStatus.idle;
    }
  }

  void selectSingleDate(DateTime selectedDay) {
    final filtered = _getTermsByDateUseCase(selectedDay);
    final prepared = _prepareInitialDayVisibility(filtered);
    terms.assignAll(prepared);
    status.value = prepared.isEmpty
        ? TermViewStatus.empty
        : TermViewStatus.loaded;
  }

  void selectRange(DateTime start, DateTime end) {
    final filtered = _getTermsByRangeUseCase(start, end);
    terms.assignAll(filtered);
    status.value = filtered.isEmpty
        ? TermViewStatus.empty
        : TermViewStatus.loaded;
  }

  void toggleVisibility(int index) {
    if (index < 0 || index >= terms.length) {
      return;
    }

    terms[index] = terms[index].toggleVisibility();
  }

  void filterTermsByIndexRange(int startIndex, int endIndex) {
    if (terms.isEmpty) {
      return;
    }

    if (startIndex < 0 || endIndex < 0) {
      return;
    }

    final lower = startIndex <= endIndex ? startIndex : endIndex;
    final upper = startIndex <= endIndex ? endIndex : startIndex;

    for (var i = 0; i < terms.length; i++) {
      final shouldShow = i >= lower && i <= upper;
      terms[i] = terms[i].copyWith(show: shouldShow);
    }
  }

  void toggleAllDayThermograms() {
    if (terms.isEmpty) {
      return;
    }

    final showAll = terms.any((term) => !term.show);
    for (var i = 0; i < terms.length; i++) {
      terms[i] = terms[i].copyWith(show: showAll);
    }
  }

  bool get areAllThermogramsVisible =>
      terms.isNotEmpty && terms.every((term) => term.show);

  void resetZoom() => zoom.reset();

  List<Term> _prepareInitialDayVisibility(List<Term> source) {
    if (source.isEmpty) {
      return <Term>[];
    }

    return List<Term>.generate(source.length, (index) {
      return source[index].copyWith(show: index == 0);
    }, growable: false);
  }
}
