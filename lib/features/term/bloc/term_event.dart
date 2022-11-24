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

class TermChooseDate extends TermEvent {
  final DateTime date;

  const TermChooseDate(this.date);
}
