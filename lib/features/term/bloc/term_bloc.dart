import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:data_visualizer/features/term/repository/common/data_source.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import '../model/term.dart';
import '../repository/parser.dart';
import '../repository/las_parser.dart';

part 'term_event.dart';

part 'term_state.dart';

class TermBloc extends Bloc<TermEvent, TermState> {
  final DataSource source;
  final Parser parser;

  TermBloc({
    this.source = const DataSource(),
    this.parser = const LasParser(),
  }) : super(const TermInitial()) {
    on<TermEvent>((event, emit) {});
    on<TermChooseFiles>(_filePressed);
  }

  Future<void> _filePressed(
    TermChooseFiles event,
    Emitter<TermState> emit,
  ) async {
    final result = await source.pickFiles();
    if (result != null) emit(TermParsed(list: _buildData(result)));
  }

  List<Term> _buildData(FilePickerResult result) {
    // todo refactor whole method
    final names = parser.getNames(result);
    final points = parser.getPoints(result);
    final times = parser.getTimes(result);
    var list = <Term>[];
    for (int i = 0; i < names.length; i++) {
      list.add(Term.create(type: ResultType.lasTerm, data: {
        DataType.name: names[i],
        DataType.points: points[i],
        DataType.dateTime: times[i],
      }));
    }
    return list;
  }
}
