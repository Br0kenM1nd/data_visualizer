import 'dart:math';

import 'package:data_visualizer/features/term/model/las.dart';
import 'package:fl_chart/fl_chart.dart';

enum DataType { name, points, spots, dateTime }

enum ResultType { lasTerm, svgTerm }

typedef DataStruct = Map<DataType, dynamic>;

class Term {
  Term();

  late final String name;
  late final List<FlSpot> spots;
  late final List<Point> points;
  var show = true;

  factory Term.create({required ResultType type, required DataStruct data}) {
    switch (type) {
      case ResultType.lasTerm:
        return Las(
          name: data[DataType.name],
          points: data[DataType.points],
          spots: data[DataType.spots],
          dateTime: data[DataType.dateTime],
        );
      case ResultType.svgTerm:
        return Term();
    }
  }
}
