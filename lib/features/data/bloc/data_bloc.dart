import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:data_visualizer/features/data/repository/common/data_source.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import '../model/data.dart';
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
    if (result != null) emit(DataParsed(list: _buildData(result)));
  }

  List<Data> _buildData(FilePickerResult result) {
    // todo refactor whole method
    final names = parser.getNames(result);
    final points = parser.getPoints(result);
    final times = parser.getTimes(result);
    var list = <Data>[];
    for (int i = 0; i < names.length; i++) {
      list.add(Data.create(type: ResultType.lasTerm, data: {
        DataType.name: names[i],
        DataType.points: points[i],
        DataType.dateTime: times[i],
      }));
    }
    return list;
  }
}
