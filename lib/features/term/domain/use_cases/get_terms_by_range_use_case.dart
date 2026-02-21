import '../../data/repositories/term_repository_impl.dart';
import '../entities/term.dart';
import '../repositories/term_repository_contract.dart';

class GetTermsByRangeUseCase {
  GetTermsByRangeUseCase({TermRepositoryContract? repository})
    : _repository = repository ?? const TermRepositoryImpl();

  final TermRepositoryContract _repository;

  List<Term> call(DateTime start, DateTime end) =>
      _repository.getTermsByRange(start, end);
}
