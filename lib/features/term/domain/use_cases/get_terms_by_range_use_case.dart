import '../../data/repositories/term_repository_impl.dart';
import '../entities/term.dart';
import '../repositories/term_repository_contract.dart';

class GetTermsByRangeUseCase({
  final TermRepositoryContract _repository = const TermRepositoryImpl(),
}) {
  List<Term> call(DateTime start, DateTime end) => _repository.getTermsByRange(start, end);
}
