import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:data_visualizer/features/data/repository/common/data_source.dart';
import 'package:equatable/equatable.dart';

import '../repository/parser.dart';
import '../repository/las_parser.dart';

part 'data_event.dart';

part 'data_state.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final DataSource source;
  final Parser parser;

  DataBloc({
    this.source = const DataSource(),
    this.parser = const LasParser(),
  }) : super(const DataInitial()) {
    on<DataEvent>((event, emit) {});
    on<DataChooseFiles>(_filePressed);
  }

  Future<void> _filePressed(
    DataChooseFiles event,
    Emitter<DataState> emit,
  ) async {
    final result = await source.pickFiles();
    if (result != null) {
      emit(DataParsed(data: {
        DataType.names: parser.getNames(result),
        DataType.times: parser.getTimes(result),
        DataType.points: parser.getPoints(result),
      }));
    }
  }
}
