import '../../data/repositories/term_repository_impl.dart';
import '../entities/term.dart';
import '../repositories/term_repository_contract.dart';

class LoadLastDirectoryTermsUseCase {
  LoadLastDirectoryTermsUseCase({TermRepositoryContract? repository})
    : _repository = repository ?? const TermRepositoryImpl();

  final TermRepositoryContract _repository;

  Future<List<Term>> call() => _repository.loadTermsFromLastDirectory();
}
