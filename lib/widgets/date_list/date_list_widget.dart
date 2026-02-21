import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/term/domain/entities/las.dart';
import '../../features/term/domain/entities/term.dart';
import '../../features/term/presentation/controllers/term_controller.dart';
import 'date_list_controller.dart';

class DateListWidget extends StatefulWidget {
  const DateListWidget({super.key});

  @override
  State<DateListWidget> createState() => _DateListWidgetState();
}

class _DateListWidgetState extends State<DateListWidget> {
  static const colors = [
    Color.fromRGBO(75, 135, 185, 1),
    Color.fromRGBO(192, 108, 132, 1),
    Color.fromRGBO(246, 114, 128, 1),
    Color.fromRGBO(248, 177, 149, 1),
    Color.fromRGBO(116, 180, 155, 1),
    Color.fromRGBO(0, 168, 181, 1),
    Color.fromRGBO(73, 76, 162, 1),
    Color.fromRGBO(255, 205, 96, 1),
    Color.fromRGBO(255, 240, 219, 1),
    Color.fromRGBO(238, 238, 238, 1),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DateListController>()
        ? Get.find<DateListController>()
        : Get.put(DateListController());
    final termController = Get.find<TermController>();

    return Obx(() {
      final List<Term> terms = termController.terms;
      if (terms.isEmpty) {
        return const SizedBox.shrink();
      }

      final (sliderStart, sliderEnd) = _sliderRangeForTerms(terms);
      final sliderMax = (terms.length - 1).toDouble();

      return Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: terms.length * 30.0),
            child: RotatedBox(
              quarterTurns: 1,
              child: terms.length > 1
                  ? RangeSlider(
                      divisions: terms.length - 1,
                      values: RangeValues(
                        sliderStart.toDouble(),
                        sliderEnd.toDouble(),
                      ),
                      max: sliderMax,
                      labels: RangeLabels(
                        '${sliderStart + 1}',
                        '${sliderEnd + 1}',
                      ),
                      onChanged: (range) {
                        final startIndex = range.start.round();
                        final endIndex = range.end.round();
                        controller.filterTermsByIndexRange(
                          startIndex,
                          endIndex,
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Column(
            children: [
              Text('кол-во: ${terms.length}'),
              TextButton(
                onPressed: controller.toggleAllDayThermograms,
                child: Text(
                  termController.areAllThermogramsVisible
                      ? 'Скрыть все термограммы дня'
                      : 'Отрисовать все термограммы дня',
                ),
              ),
              const Text('Дата и время'),
              for (int i = 0; i < terms.length; i++)
                if (terms[i] is Las)
                  TextButton(
                    onPressed: () => controller.toggleTermVisibility(i),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: colors[i % colors.length],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          (terms[i] as Las).dateTime.toString(),
                          style: TextStyle(
                            color: terms[i].show ? null : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      );
    });
  }

  (int, int) _sliderRangeForTerms(List<Term> terms) {
    final visibleIndexes = <int>[
      for (int i = 0; i < terms.length; i++)
        if (terms[i].show) i,
    ];

    if (visibleIndexes.isEmpty) {
      return (0, 0);
    }

    return (visibleIndexes.first, visibleIndexes.last);
  }
}
