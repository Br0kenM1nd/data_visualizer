import '../../data/repositories/term_repository_impl.dart';
import '../entities/term.dart';
import '../repositories/term_repository_contract.dart';

class LoadTermsUseCase {
  LoadTermsUseCase({TermRepositoryContract? repository})
    : _repository = repository ?? const TermRepositoryImpl();

  final TermRepositoryContract _repository;

  Future<List<Term>> call() => _repository.loadAllTerms();
}
