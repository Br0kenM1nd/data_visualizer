import 'dart:math';

import 'package:equatable/equatable.dart';

class const Term({
  required final String name,
  required final List<Point<double>> points,
  required final bool show,
}) extends Equatable {
  Term copyWith({String? name, List<Point<double>>? points, bool? show}) {
    return Term(name: name ?? this.name, points: points ?? this.points, show: show ?? this.show);
  }

  Term toggleVisibility() => copyWith(show: !show);

  @override
  List<Object> get props => <Object>[name, points, show];
}
