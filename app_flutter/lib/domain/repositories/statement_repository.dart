import '../entities/child_statistics.dart';

abstract class StatementRepository {
  Future<ChildStatistics> getStatisticsForChild(String childId);
  
  /// Enregistre un calcul effectué par l'enfant
  Future<void> saveStatement({
    required String childId,
    required int operand1,
    required int operand2,
    required bool success,
  });

  /// Synchronise les calculs enregistrés localement qui n'ont pas encore été envoyés
  Future<void> syncPendingStatements();
}
