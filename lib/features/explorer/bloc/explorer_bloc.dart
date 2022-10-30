import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

import '../model/point.dart';
import '../repository/explorer_repository.dart';

part 'explorer_event.dart';

part 'explorer_state.dart';

class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  final ExplorerRepository repository;

  ExplorerBloc({this.repository = const ExplorerRepository()})
      : super(ExplorerInitial()) {
    on<ExplorerEvent>((event, emit) {});
    on<ExplorerFilePressed>(_filePressed);
  }

  Future<void> _filePressed(
    ExplorerFilePressed event,
    Emitter<ExplorerState> emit,
  ) async {
    final files = await repository.pickFiles();
    if (files == null) return;
    emit(ExplorerLasOpenSuccessfully(await repository.getTempFromFiles(files)));
  }
}
