import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_controller.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CalendarController>()
        ? Get.find<CalendarController>()
        : Get.put(CalendarController());

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
      child: Obx(
        () => TableCalendar(
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
          rangeSelectionMode: controller.rangeSelectionMode.value,
          onDaySelected: controller.selectDay,
          onDayLongPressed: controller.longPressed,
          onRangeSelected: controller.selectRange,
        ),
      ),
    );
  }
}
