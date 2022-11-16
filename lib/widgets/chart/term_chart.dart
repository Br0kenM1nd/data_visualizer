import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../features/term/model/term.dart';

class TermChart extends StatelessWidget {
  final List<Term>? terms;

  const TermChart({this.terms, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var allX = <num>[];
    var allY = <num>[];
    var xy = [];
    var points = <Point>[];
    var allPoints = [<Point>[]];
    if (terms != null) {
      for (var i = 0; i < terms!.length; ++i) {
        for (var j = 0; j < terms![i].points.length; ++j) {
          allX.add(terms![i].points[j].x);
          allY.add(terms![i].points[j].y);
          points.add(terms![i].points[j]);
          allPoints.add(terms![i].points);
        }
      }
      xy.add(allX);
      xy.add(allY);
    }
    return Expanded(
      child: SfCartesianChart(
        series: <LineSeries>[
          ...allPoints.map((pointz) => LineSeries<Point, num>(
            dataSource: pointz,
            xValueMapper: (data, _) => _ * 2,
            yValueMapper: (point, _) => point.y,
            width: 2,
            markerSettings: MarkerSettings(
              // isVisible: true,
              // height: 4,
              // width: 4,
              // shape: DataMarkerType.circle,
              // borderWidth: 3,
              // borderColor: Colors.red,
            ),
            dataLabelSettings: DataLabelSettings(),
          )).toList(),
        ],
        palette: [
          Colors.red,
          Colors.black,
          Colors.white,
          Colors.yellow,
        ],
        zoomPanBehavior: ZoomPanBehavior(
          enableSelectionZooming: true,
          enablePinching: true,
          enableMouseWheelZooming: true,
        ),
      ),
    );
  }
}
