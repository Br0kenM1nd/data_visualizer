import 'package:data_visualizer/features/term/model/term.dart';
import 'package:data_visualizer/features/term/model/dated.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';

class Las extends Term with Dated, EquatableMixin {
  @override
  final String name;
  @override
  final List<FlSpot> points;

  @override
  final DateTime dateTime;

  @override
  List<Object> get props => [name, points, dateTime];

  Las({required this.name, required this.points, required this.dateTime});
}
