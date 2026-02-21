import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../features/term/presentation/controllers/term_controller.dart';

class TermWidget extends StatelessWidget {
  const TermWidget({super.key});

  static const String xAxisTitle = 'Расстояние, М';
  static const String yAxisTitle = 'Температура, °С';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TermController>();

    return Expanded(
      child: GestureDetector(
        onTap: controller.resetZoom,
        child: Obx(() {
          if (controller.status.value == TermViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final visibleTerms = controller.terms
              .where((term) => term.show)
              .toList(growable: false);

          return SfCartesianChart(
            series: visibleTerms
                .map(
                  (term) => FastLineSeries<Point<double>, double>(
                    dataSource: term.points,
                    xValueMapper: (point, _) => point.x,
                    yValueMapper: (point, _) => point.y,
                  ),
                )
                .toList(growable: false),
            primaryXAxis: const NumericAxis(title: AxisTitle(text: xAxisTitle)),
            primaryYAxis: const NumericAxis(title: AxisTitle(text: yAxisTitle)),
            zoomPanBehavior: controller.zoom,
          );
        }),
      ),
    );
  }
}
