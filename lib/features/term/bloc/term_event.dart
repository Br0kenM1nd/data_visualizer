part of 'term_bloc.dart';

abstract class TermEvent extends Equatable {
  const TermEvent();

  @override
  List<Object> get props => [];
}

class TermChooseFiles extends TermEvent {
  const TermChooseFiles();
}

class TermChooseDir extends TermEvent {
  const TermChooseDir();
}

class TermChooseSingleDate extends TermEvent {
  final DateTime date;

  const TermChooseSingleDate(this.date);

  @override
  List<Object> get props => [date];
}

class TermChooseRangeDate extends TermEvent {
  final DateTime start;
  final DateTime end;

  const TermChooseRangeDate(this.start, this.end);

  @override
  List<Object> get props => [start, end];
}
