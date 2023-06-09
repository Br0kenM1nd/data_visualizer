import 'dart:math';

import 'package:data_visualizer/features/term/model/term.dart';
import 'package:data_visualizer/features/term/model/dated.dart';

class Las extends Term implements Dated {
  @override
  final String name;
  @override
  final List<Point> points;

  @override
  final DateTime dateTime;

  @override
  final bool show;

  Las({
    required this.name,
    required this.points,
    required this.dateTime,
    this.show = true,
  }) : super(name: name, points: points, show: show);

  @override
  Las copyWith({
    String? name,
    List<Point>? points,
    DateTime? dateTime,
    bool? show,
  }) =>
      Las(
        name: name ?? this.name,
        points: points ?? this.points,
        dateTime: dateTime ?? this.dateTime,
        show: show ?? this.show,
      );

  @override
  Las change() => Las(
        name: name,
        points: points,
        dateTime: dateTime,
        show: !show,
      );

  @override
  List<Object> get props => [name, points, show, dateTime];

  @override
  set dateTime(DateTime time) => dateTime = time;
}
