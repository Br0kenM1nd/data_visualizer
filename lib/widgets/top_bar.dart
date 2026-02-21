import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/term/presentation/controllers/term_controller.dart';
import 'calendar/calendar_controller.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TermController>();
    final calendarController = Get.isRegistered<CalendarController>()
        ? Get.find<CalendarController>()
        : null;

    return AppBar(
      title: Row(
        children: [
          TextButton(
            onPressed: () async {
              final initialDate =
                  calendarController?.activeDate ?? DateTime.now();
              await controller.loadTermsWithInitialDateFilter(
                initialFilterDate: initialDate,
              );
              calendarController?.setActiveDate(initialDate);
            },
            child: const Text('Файл'),
          ),
          const Expanded(child: SizedBox()),
          IconButton(
            onPressed: () => Get.changeThemeMode(ThemeMode.light),
            icon: const Icon(Icons.light_mode),
          ),
          IconButton(
            onPressed: () => Get.changeThemeMode(ThemeMode.dark),
            icon: const Icon(Icons.dark_mode, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
