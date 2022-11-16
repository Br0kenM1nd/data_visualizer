import 'las.dart';
import 'term.dart';

abstract class TermFactory {
  List<Term> createData(dynamic parsed);
}

class LasFactory implements TermFactory {
  @override
  List<Las> createData(dynamic parsed) {
    return [];
  }
}
