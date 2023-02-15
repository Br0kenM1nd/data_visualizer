import 'package:data_visualizer/features/term/model/las.dart';
import 'package:data_visualizer/features/term/repository/all_data.dart';
import 'package:file_picker/file_picker.dart';

import '../model/term.dart';
import 'parser/las_parser.dart';
import 'parser/parser.dart';
import 'source/data_source.dart';

class TermRepository {
  final DataSource source;
  final Parser parser;

  const TermRepository({
    this.source = const DataSource(),
    this.parser = const LasParser(),
  });

  Future<List<Term>?> loadAllTerms() async {
    final result = await source.pickFiles();
    if (result == null) return null;
    AllData.terms = _buildData(result);
    return AllData.terms;
  }

  List<Term> getTermsByRange(DateTime start, DateTime end) {
    if (AllData.terms == null) return [];

    List<Term> filteredTerms = [];

    for (final term in AllData.terms!) {
      if (term is Las &&
          term.dateTime.isAfter(start) &&
          term.dateTime.isBefore(end)) filteredTerms.add(term);
    }
    return filteredTerms;
  }

  List<Term> getTermsByDate(DateTime date) {
    if (AllData.terms == null) return [];
    List<Term> filteredTerms = [];
    for (final term in AllData.terms!) {
      if (term is Las &&
          term.dateTime.day == date.day &&
          term.dateTime.month == date.month) filteredTerms.add(term);
    }
    return filteredTerms;
  }

  List<Term> _buildData(FilePickerResult result) {
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
