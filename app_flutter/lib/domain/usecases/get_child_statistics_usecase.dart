import '../entities/child_statistics.dart';
import '../repositories/statement_repository.dart';

class GetChildStatisticsUseCase {
  final StatementRepository repository;

  GetChildStatisticsUseCase(this.repository);

  Future<ChildStatistics> execute(String childId) async {
    return await repository.getStatisticsForChild(childId);
  }
}
