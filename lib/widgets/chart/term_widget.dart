import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../features/term/presentation/controllers/term_controller.dart';
import 'term_chart_data_sampler.dart';

class TermWidget extends StatefulWidget {
  const TermWidget({super.key});

  static const String xAxisTitle = 'Расстояние, М';
  static const String yAxisTitle = 'Температура, °С';
  static const String xAxisName = 'distance';

  @override
  State<TermWidget> createState() => _TermWidgetState();
}

class _TermWidgetState extends State<TermWidget> {
  double? _visibleMin;
  double? _visibleMax;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TermController>();

    return Expanded(
      child: GestureDetector(
        onTap: () => _resetZoom(controller),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final targetPointCount = _targetPointCount(constraints.maxWidth);

            return Obx(() {
              if (controller.status.value == TermViewStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final visibleTerms = controller.terms
                  .where((term) => term.show)
                  .toList(growable: false);

              return SfCartesianChart(
                onActualRangeChanged: _rememberVisibleXRange,
                onZoomEnd: (_) => _refreshSampledData(),
                series: visibleTerms
                    .map(
                      (term) => FastLineSeries<Point<double>, double>(
                        dataSource: TermChartDataSampler.sample(
                          term.points,
                          visibleMin: _visibleMin,
                          visibleMax: _visibleMax,
                          targetPointCount: targetPointCount,
                        ),
                        xValueMapper: (point, _) => point.x,
                        yValueMapper: (point, _) => point.y,
                        animationDuration: 0,
                        enableTooltip: false,
                        enableTrackball: false,
                        width: 1,
                      ),
                    )
                    .toList(growable: false),
                primaryXAxis: const NumericAxis(
                  name: TermWidget.xAxisName,
                  title: AxisTitle(text: TermWidget.xAxisTitle),
                ),
                primaryYAxis: const NumericAxis(title: AxisTitle(text: TermWidget.yAxisTitle)),
                zoomPanBehavior: controller.zoom,
              );
            });
          },
        ),
      ),
    );
  }

  int _targetPointCount(double chartWidth) {
    if (chartWidth.isInfinite || chartWidth <= 0) {
      return 1200;
    }

    return max(300, chartWidth.ceil() * 2);
  }

  void _rememberVisibleXRange(ActualRangeChangedArgs args) {
    if (args.axisName != TermWidget.xAxisName) {
      return;
    }

    final min = args.visibleMin;
    final max = args.visibleMax;
    if (min is! num || max is! num) {
      return;
    }

    _visibleMin = min.toDouble();
    _visibleMax = max.toDouble();
  }

  void _refreshSampledData() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _resetZoom(TermController controller) {
    _visibleMin = null;
    _visibleMax = null;
    controller.resetZoom();
    _refreshSampledData();
  }
}
