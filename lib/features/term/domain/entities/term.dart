import 'dart:math';

import 'package:equatable/equatable.dart';

class Term extends Equatable {
  const Term({required this.name, required this.points, required this.show});

  final String name;
  final List<Point<double>> points;
  final bool show;

  Term copyWith({String? name, List<Point<double>>? points, bool? show}) {
    return Term(
      name: name ?? this.name,
      points: points ?? this.points,
      show: show ?? this.show,
    );
  }

  Term toggleVisibility() => copyWith(show: !show);

  @override
  List<Object> get props => <Object>[name, points, show];
}
