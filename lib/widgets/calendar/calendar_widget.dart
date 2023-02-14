import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_controller.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());
    return Container(
      constraints: const BoxConstraints(
        minWidth: 200,
        maxWidth: 300,
      ),
      child: Obx(
        () => TableCalendar(
          // todo add fast year choose
          calendarStyle: CalendarStyle(

          ),
          locale: 'ru',
          weekendDays: const [],
          startingDayOfWeek: StartingDayOfWeek.monday,
          firstDay: controller.kFirstDay,
          lastDay: controller.kLastDay,
          focusedDay: controller.stateFocusedDay.value,
          selectedDayPredicate: controller.compareDays,
          rangeStartDay: controller.rangeStart.value,
          rangeEndDay: controller.rangeEnd.value,
          calendarFormat: controller.calendarFormat.value,
          onFormatChanged: controller.changeFormat,
          rangeSelectionMode: RangeSelectionMode.toggledOff,
          onDaySelected: controller.selectDay,
          onRangeSelected: controller.selectRange,
          // onDayLongPressed: controller.longPressed,
        ),
      ),
    );
  }
}
