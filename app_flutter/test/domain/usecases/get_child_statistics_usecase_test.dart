import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/child_statistics.dart';
import 'package:app_flutter/domain/repositories/statement_repository.dart';
import 'package:app_flutter/domain/usecases/get_child_statistics_usecase.dart';

class MockStatementRepository implements StatementRepository {
  @override
  Future<ChildStatistics> getStatisticsForChild(String childId) async {
    return ChildStatistics(
      tableStats: [
        TableStatistic(table: 7, totalAttempts: 10, correctAnswers: 8),
      ],
      dailyProgress: [],
    );
  }

  @override
  Future<void> saveStatement({
    required String childId,
    required int operand1,
    required int operand2,
    required bool success,
  }) async {}

  @override
  Future<void> syncPendingStatements() async {}
}

void main() {
  late GetChildStatisticsUseCase useCase;
  late MockStatementRepository mockRepository;

  setUp(() {
    mockRepository = MockStatementRepository();
    useCase = GetChildStatisticsUseCase(mockRepository);
  });

  test('doit retourner les statistiques du calcul pour un enfant', () async {
    final stats = await useCase.execute('child-1');

    expect(stats.tableStats.length, 1);
    expect(stats.tableStats.first.table, 7);
    expect(stats.tableStats.first.totalAttempts, 10);
    expect(stats.tableStats.first.correctAnswers, 8);
  });
}
