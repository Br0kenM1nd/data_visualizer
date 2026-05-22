import '../../data/repositories/term_repository_impl.dart';
import '../entities/term.dart';
import '../repositories/term_repository_contract.dart';

class GetTermsByDateUseCase({
  final TermRepositoryContract _repository = const TermRepositoryImpl(),
}) {
  List<Term> call(DateTime date) => _repository.getTermsByDate(date);
}
