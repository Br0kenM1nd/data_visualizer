import 'dart:math';

import 'package:data_visualizer/features/term/model/las.dart';
import 'package:equatable/equatable.dart';

enum DataType { name, points, dateTime, show }

enum ResultType { lasTerm, svgTerm }

typedef DataStruct = Map<DataType, dynamic>;

class Term extends Equatable {
  final String name;
  final List<Point> points;
  final bool show;

  const Term({required this.name, required this.points, required this.show});

  factory Term.create({required ResultType type, required DataStruct data}) {
    switch (type) {
      case ResultType.lasTerm:
        return Las(
          name: data[DataType.name],
          points: data[DataType.points],
          dateTime: data[DataType.dateTime],
          show: data[DataType.show] ?? true,
        );
      case ResultType.svgTerm:
        return Term(
          name: data[DataType.name],
          points: data[DataType.points],
          show: data[DataType.show] ?? true,
        );
    }
  }



  @override
  List<Object> get props => [name, points, show];

  Term copyWith({
    String? name,
    List<Point>? points,
    bool? show,
  }) {
    return Term(
      name: name ?? this.name,
      points: points ?? this.points,
      show: show ?? this.show,
    );
  }
}
