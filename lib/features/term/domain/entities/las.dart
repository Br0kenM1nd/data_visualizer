import 'dart:math';

import 'dated.dart';
import 'term.dart';

class Las extends Term implements Dated {
  const Las({
    required super.name,
    required super.points,
    required this.dateTime,
    super.show = true,
  });

  @override
  final DateTime dateTime;

  @override
  Las copyWith({
    String? name,
    List<Point<double>>? points,
    DateTime? dateTime,
    bool? show,
  }) {
    return Las(
      name: name ?? this.name,
      points: points ?? this.points,
      dateTime: dateTime ?? this.dateTime,
      show: show ?? this.show,
    );
  }

  @override
  Las toggleVisibility() => copyWith(show: !show);

  @override
  List<Object> get props => <Object>[...super.props, dateTime];
}
