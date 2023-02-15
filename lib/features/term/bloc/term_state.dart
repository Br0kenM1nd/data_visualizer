part of 'term_bloc.dart';

abstract class TermState extends Equatable {
  const TermState();
}

class TermInitial extends TermState {
  const TermInitial();

  @override
  List<Object> get props => [];
}

class TermGot extends TermState {
  final List<Term> terms;

  const TermGot(this.terms);

  @override
  List<Object> get props => [terms];
}

class TermError extends TermState {
  final Exception error;

  const TermError(this.error);

  @override
  List<Object> get props => [error];
}
