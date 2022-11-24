import 'dart:math';

import 'package:data_visualizer/widgets/chart/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TermChart extends StatelessWidget {
  final List<List<Point>>? termsPoints;

  const TermChart({this.termsPoints, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TermController());
    return Expanded(
      child: GestureDetector(
        onTap: controller.zoomReset,
        child: SfCartesianChart(
          series: termsPoints == null
              ? <FastLineSeries>[]
              : termsPoints!
                  .map((points) => FastLineSeries<Point, num>(
                        // animationDuration: 0,
                        dataSource: points,
                        xValueMapper: (point, step) => point.x,
                        yValueMapper: (point, step) => point.y,
                        width: 2,
                        // markerSettings: const MarkerSettings(
                        //   isVisible: true,
                        //   height: 4,
                        //   width: 4,
                        //   // shape: DataMarkerType.circle,
                        //   borderWidth: 3,
                        //   // borderColor: Colors.red,
                        // ),
                        dataLabelSettings: const DataLabelSettings(),
                      ))
                  .toList(),
          primaryXAxis: NumericAxis(title: AxisTitle(text: 'Расстояние, М')),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'Температура, °С')),
          zoomPanBehavior: controller.zoom,
        ),
      ),
    );
  }
}
