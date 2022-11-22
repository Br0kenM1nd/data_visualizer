import 'dart:async';
import 'dart:math';

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
    on<TermChooseDate>(_chooseDate);
  }

  Future<void> _filePressed(
    TermChooseFiles event,
    Emitter<TermState> emit,
  ) async {
    repository.loadAllTerms();
  }

  void _chooseDate(TermChooseDate event, Emitter<TermState> emit) {
    final terms = repository.getTermsByDate(event.date);
    final points = repository.getPointsFromTerms(terms);
    emit(TermParsed(list: terms, points: points));
  }
}
