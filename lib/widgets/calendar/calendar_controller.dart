import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/logger/logger.dart';
import '../../features/term/presentation/controllers/term_controller.dart';

class CalendarController extends GetxController {
  CalendarController({TermController? termController})
    : _termController = termController ?? Get.find<TermController>();

  final TermController _termController;

  var calendarFormat = CalendarFormat.month.obs;
  final kFirstDay = DateTime(2000);
  final kLastDay = DateTime(2100);

  // Long press enables range selection mode.
  var rangeSelectionMode = RangeSelectionMode.toggledOff.obs;
  var stateFocusedDay = DateTime.now().obs;
  var stateSelectedDay = Rxn<DateTime>();
  var rangeStart = Rxn<DateTime>();
  var rangeEnd = Rxn<DateTime>();

  bool compareDays(DateTime day) => isSameDay(day, stateSelectedDay.value);

  DateTime get activeDate => stateSelectedDay.value ?? stateFocusedDay.value;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    stateFocusedDay.value = now;
    stateSelectedDay.value = now;
  }

  void changeFormat(CalendarFormat format) {
    if (calendarFormat.value != format) calendarFormat.value = format;
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(stateSelectedDay.value, selectedDay)) {
      stateSelectedDay.value = selectedDay;
      stateFocusedDay.value = focusedDay;

      if (rangeSelectionMode.value == RangeSelectionMode.toggledOff) {
        rangeStart.value = null;
        rangeEnd.value = null;
        _termController.selectSingleDate(selectedDay);
      }
    }
  }

  void selectRange(DateTime? start, DateTime? end, DateTime focusedDay) {
    stateSelectedDay.value = null;
    stateFocusedDay.value = focusedDay;
    rangeStart.value = start;
    rangeEnd.value = end;

    if (start != null && end != null) {
      _termController.selectRange(start, end);
      rangeSelectionMode.value = RangeSelectionMode.toggledOff;
    }
  }

  // void selectRange(DateTime? start, DateTime? end, DateTime focusedDay) {
  //   stateSelectedDay.value = null;
  //   stateFocusedDay.value = focusedDay;
  //   rangeStart.value = start;
  //   rangeEnd.value = end;
  //   rangeSelectionMode.value = RangeSelectionMode.toggledOn;
  //   if (start != null && end != null) _termController.selectRange(start, end);
  // }

  void longPressed(DateTime day, DateTime focusedDay) {
    appLogger.d('Range anchor day selected: $day');
    rangeSelectionMode.value = RangeSelectionMode.toggledOn;
    stateSelectedDay.value = day;
    stateFocusedDay.value = focusedDay;
  }

  void resetSelection() {
    rangeSelectionMode.value = RangeSelectionMode.toggledOff;
    stateSelectedDay.value = null;
    rangeStart.value = null;
    rangeEnd.value = null;
  }

  void setActiveDate(DateTime date) {
    stateSelectedDay.value = date;
    stateFocusedDay.value = date;
    rangeSelectionMode.value = RangeSelectionMode.toggledOff;
    rangeStart.value = null;
    rangeEnd.value = null;
  }
}
