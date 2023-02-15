import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/term.dart';
import '../repository/term_repository.dart';

part 'term_event.dart';

part 'term_state.dart';

class TermBloc extends Bloc<TermEvent, TermState> {
  final TermRepository repository;

  TermBloc({
    this.repository = const TermRepository(),
  }) : super(const TermInitial()) {
    on<TermEvent>((event, emit) {});
    on<TermChooseFiles>(_filePressed);
    on<TermChooseSingleDate>(_chooseSingleDate);
    on<TermChooseRangeDate>(_chooseRangeDate);
  }

  Future<void> _filePressed(
    TermChooseFiles event,
    Emitter<TermState> emit,
  ) async => repository.loadAllTerms();

  void _chooseSingleDate(TermChooseSingleDate event, Emitter<TermState> emit) {
    emit(TermGot(repository.getTermsByDate(event.date)));
  }

  Future<void> _chooseRangeDate(
    TermChooseRangeDate event,
    Emitter<TermState> emit,
  ) async {
    print(
      '${("-" * 100).toString()}\n'
          '${event.start}\n'
          '${event.end}\n'
          '${("-" * 100).toString()}\n',
    );
    final terms = repository.getTermsByRange(event.start, event.end);
    emit(TermGot(terms));
  }
}
