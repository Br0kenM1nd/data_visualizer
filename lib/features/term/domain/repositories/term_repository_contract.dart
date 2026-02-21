import '../entities/term.dart';

abstract class TermRepositoryContract {
  Future<List<Term>> loadAllTerms();

  Future<List<Term>> loadTermsFromLastDirectory();

  List<Term> getTermsByDate(DateTime date);

  List<Term> getTermsByRange(DateTime start, DateTime end);
}
