import 'package:drift/drift.dart';
import '../../domain/entities/child_statistics.dart';
import '../../domain/repositories/statement_repository.dart';
import '../datasources/statement_remote_data_source.dart';
import '../local/app_database.dart';

class StatementRepositoryImpl implements StatementRepository {
  final StatementRemoteDataSource remoteDataSource;
  final AppDatabase localDb;

  StatementRepositoryImpl({
    required this.remoteDataSource,
    required this.localDb,
  });

  @override
  Future<ChildStatistics> getStatisticsForChild(String childId) async {
    final rawStatements = await remoteDataSource.getStatementsForChild(childId);

    // 1. Calcul des stats par table (1 à 10)
    final Map<int, List<bool>> tableAttempts = {};
    for (int i = 1; i <= 10; i++) {
      tableAttempts[i] = [];
    }

    // 2. Calcul de la progression quotidienne et détection de la dernière activité
    final Map<DateTime, int> dailyCorrect = {};
    DateTime? lastActiveAt;

    for (var row in rawStatements) {
      final bool isSuccess = row['success'] == true;
      final int op1 = row['operand1'] as int;
      final int op2 = row['operand2'] as int;
      final DateTime date = DateTime.parse(row['created_at']).toLocal();
      final DateTime dayDate = DateTime(date.year, date.month, date.day);

      if (lastActiveAt == null || date.isAfter(lastActiveAt)) {
        lastActiveAt = date;
      }

      // On considère que si l'un des deux opérandes est entre 1 et 10, ça compte pour cette table
      // Pour une multiplication, on compte souvent par table de X.
      if (op1 >= 1 && op1 <= 10) tableAttempts[op1]!.add(isSuccess);
      // On ne compte pas deux fois si c'est 7x7, mais si c'est 7x8 ça compte pour la table de 7 et de 8 ? 
      // Généralement l'enfant "travaille la table de 7", donc on regarde si 7 est présent.
      if (op2 >= 1 && op2 <= 10 && op2 != op1) tableAttempts[op2]!.add(isSuccess);

      if (isSuccess) {
        dailyCorrect[dayDate] = (dailyCorrect[dayDate] ?? 0) + 1;
      }
    }

    final List<TableStatistic> tableStats = tableAttempts.entries.map((entry) {
      return TableStatistic(
        table: entry.key,
        totalAttempts: entry.value.length,
        correctAnswers: entry.value.where((s) => s).length,
      );
    }).toList();

    final List<DailyStatistic> dailyProgress = dailyCorrect.entries.map((entry) {
      return DailyStatistic(date: entry.key, correctAnswers: entry.value);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    return ChildStatistics(
      tableStats: tableStats,
      dailyProgress: dailyProgress,
      lastActiveAt: lastActiveAt,
    );
  }

  @override
  Future<void> saveStatement({
    required String childId,
    required int operand1,
    required int operand2,
    required bool success,
  }) async {
    // 1. Sauvegarde locale immédiate
    final entryId = await localDb.addStatement(LocalStatementsCompanion.insert(
      childId: childId,
      operand1: operand1,
      operand2: operand2,
      success: success,
      isSynced: const Value(false),
    ));

    // 2. Tentative de synchro immédiate
    try {
      await remoteDataSource.saveStatement(
        childId: childId,
        operand1: operand1,
        operand2: operand2,
        success: success,
      );
      // Marquer comme synchronisé si réussi
      await localDb.markAsSynced([entryId]);
      print('FLUTTER_DEBUG: Calcul synchronisé immédiatement avec Supabase.');
    } catch (e) {
      print('FLUTTER_DEBUG: Échec de synchro immédiate (enregistré localement): $e');
    }
  }

  /// Tente de synchroniser tous les calculs en attente
  @override
  Future<void> syncPendingStatements() async {
    final pending = await localDb.getUnsyncedStatements();
    if (pending.isEmpty) {
      print('FLUTTER_DEBUG: Aucun calcul en attente de synchronisation.');
      return;
    }

    print('FLUTTER_DEBUG: Synchronisation de ${pending.length} calculs en attente...');
    for (var s in pending) {
      try {
        await remoteDataSource.saveStatement(
          childId: s.childId,
          operand1: s.operand1,
          operand2: s.operand2,
          success: s.success,
        );
        await localDb.markAsSynced([s.id]);
        print('FLUTTER_DEBUG: Calcul ${s.id} synchronisé avec succès.');
      } catch (e) {
        print('FLUTTER_DEBUG: Échec de synchronisation du calcul ${s.id}: $e');
        break; // On s'arrête au premier échec réseau
      }
    }
  }
}
