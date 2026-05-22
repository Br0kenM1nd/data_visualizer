import '../../data/repositories/term_repository_impl.dart';
import '../entities/term.dart';
import '../repositories/term_repository_contract.dart';

class LoadTermsUseCase({final TermRepositoryContract _repository = const TermRepositoryImpl()}) {
  Future<List<Term>> call() => _repository.loadAllTerms();
}
