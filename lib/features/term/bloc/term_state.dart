part of 'term_bloc.dart';

abstract class TermState extends Equatable {
  const TermState();
}

class TermInitial extends TermState {
  const TermInitial();

  @override
  List<Object> get props => [];
}

class TermParsed extends TermState {
  final List<Term> list;
  final List<List<Point>> points;

  const TermParsed({required this.list, required this.points});

  @override
  List<Object> get props => [list];
}

class TermError extends TermState {
  final Exception error;

  const TermError(this.error);

  @override
  List<Object> get props => [error];
}
