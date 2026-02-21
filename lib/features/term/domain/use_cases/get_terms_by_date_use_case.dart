import '../../data/repositories/term_repository_impl.dart';
import '../entities/term.dart';
import '../repositories/term_repository_contract.dart';

class GetTermsByDateUseCase {
  GetTermsByDateUseCase({TermRepositoryContract? repository})
    : _repository = repository ?? const TermRepositoryImpl();

  final TermRepositoryContract _repository;

  List<Term> call(DateTime date) => _repository.getTermsByDate(date);
}
