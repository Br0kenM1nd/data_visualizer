import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../features/term/bloc/term_bloc.dart';

class CalendarController extends GetxController {
  final bloc = BlocProvider.of<TermBloc>(Get.context!);

  var calendarFormat = CalendarFormat.month.obs;
  final kFirstDay = DateTime(2000);
  final kLastDay = DateTime(2100);

  // Can be toggled on/off by long pressing a date
  var rangeSelectionMode = RangeSelectionMode.toggledOn.obs;
  var stateFocusedDay = DateTime.now().obs;
  var stateSelectedDay = Rxn<DateTime>();
  var rangeStart = Rxn<DateTime>();
  var rangeEnd = Rxn<DateTime>();

  bool compareDays(DateTime day) => isSameDay(day, stateSelectedDay.value);

  void changeFormat(CalendarFormat format) {
    if (calendarFormat.value != format) calendarFormat.value = format;
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(stateSelectedDay.value, selectedDay)) {
      rangeStart.value = null;
      rangeEnd.value = null;
      stateSelectedDay.value = selectedDay;
      stateFocusedDay.value = focusedDay;
      bloc.add(TermChooseSingleDate(selectedDay));
    }
  }

  void selectRange(DateTime? _, DateTime? __, DateTime focusedDay) {
    if (stateSelectedDay.value?.isBefore(focusedDay) ?? false) {
      rangeStart.value = stateSelectedDay.value;
      rangeEnd.value = focusedDay;
      stateFocusedDay.value = focusedDay;
      bloc.add(TermChooseRangeDate(stateSelectedDay.value!, focusedDay));
    }
  }

  // void selectRange(DateTime? start, DateTime? end, DateTime focusedDay) {
  //   stateSelectedDay.value = null;
  //   stateFocusedDay.value = focusedDay;
  //   rangeStart.value = start;
  //   rangeEnd.value = end;
  //   rangeSelectionMode.value = RangeSelectionMode.toggledOn;
  //   if (start != null && end != null) bloc.add(TermChooseRangeDate(start, end));
  // }

  void longPressed(DateTime day, DateTime _) {
    print(
      '${("-" * 100).toString()}\n'
      '${day}\n'
      '${_}\n'
      '${("-" * 100).toString()}\n',
    );
    stateSelectedDay.value = day;
  }
}
