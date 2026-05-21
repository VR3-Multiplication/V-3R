import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/child_statistics.dart';
import 'package:app_flutter/domain/entities/class_statistics.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'package:app_flutter/domain/repositories/class_repository.dart';
import 'package:app_flutter/domain/repositories/statement_repository.dart';
import 'package:app_flutter/domain/usecases/get_class_statistics_usecase.dart';
import 'package:app_flutter/domain/entities/school_class.dart';

class MockClassRepository implements ClassRepository {
  final List<UserProfile> students;

  MockClassRepository(this.students);

  @override
  Future<List<UserProfile>> getClassStudents(String classId) async {
    return students;
  }

  @override
  Future<List<SchoolClass>> getClasses() async => [];
  @override
  Future<SchoolClass> createClass(String name) async => SchoolClass(id: '1', teacherId: '1', name: name, createdAt: DateTime.now());
  @override
  Future<void> deleteClass(String classId) async {}
  @override
  Future<void> addStudentToClass(String classId, String studentId) async {}
  @override
  Future<void> removeStudentFromClass(String classId, String studentId) async {}
  @override
  Future<void> updateClassStudentSortOrder({required String classId, required String studentId, required int sortOrder}) async {}
  @override
  Future<void> updateClassSortPreference({required String classId, required String preference}) async {}
}

class MockStatementRepository implements StatementRepository {
  final Map<String, ChildStatistics> statsMap;

  MockStatementRepository(this.statsMap);

  @override
  Future<ChildStatistics> getStatisticsForChild(String childId) async {
    return statsMap[childId] ?? ChildStatistics(tableStats: [], dailyProgress: []);
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
  group('GetClassStatisticsUseCase Tests', () {
    test('doit retourner les statistiques completes de la classe avec heatmap et alertes', () async {
      final now = DateTime.now();
      final student1 = UserProfile(
        id: 'student-1',
        pseudo: 'Lucas',
        role: UserRole.child,
      );
      final student2 = UserProfile(
        id: 'student-2',
        pseudo: 'Léa',
        role: UserRole.child,
      );

      final stats1 = ChildStatistics(
        tableStats: [
          TableStatistic(table: 5, totalAttempts: 10, correctAnswers: 8), // 80%
          TableStatistic(table: 7, totalAttempts: 6, correctAnswers: 2),  // 33% -> Devrait lever une alerte faible perf
        ],
        dailyProgress: [],
        lastActiveAt: now.subtract(const Duration(days: 8)), // Devrait lever une alerte inactivité
      );

      final stats2 = ChildStatistics(
        tableStats: [
          TableStatistic(table: 5, totalAttempts: 5, correctAnswers: 5),  // 100%
          TableStatistic(table: 8, totalAttempts: 2, correctAnswers: 1),  // 50% (pas assez de tentatives pour alerte < 4)
        ],
        dailyProgress: [],
        lastActiveAt: now.subtract(const Duration(days: 2)), // Actif
      );

      final classRepo = MockClassRepository([student1, student2]);
      final statementRepo = MockStatementRepository({
        'student-1': stats1,
        'student-2': stats2,
      });

      final useCase = GetClassStatisticsUseCase(
        classRepository: classRepo,
        statementRepository: statementRepo,
      );

      final classStats = await useCase.execute('class-123');

      // Vérifications de base
      expect(classStats.classId, 'class-123');
      expect(classStats.studentsStats.length, 2);
      expect(classStats.studentsStats[0].student.pseudo, 'Lucas');
      expect(classStats.studentsStats[1].student.pseudo, 'Léa');

      // Calculs globaux
      // Total attempts = 10 (Lucas T5) + 6 (Lucas T7) + 5 (Léa T5) + 2 (Léa T8) = 23
      // Total correct = 8 + 2 + 5 + 1 = 16
      // Global rate = 16 / 23 * 100 = 69.56%
      expect(classStats.totalCalculations, 23);
      expect(classStats.activeStudentsCount, 2);
      expect(classStats.globalSuccessRate, closeTo(69.56, 0.05));

      // Alertes
      final alerts = classStats.pedagogicalAlerts;
      expect(alerts.length, 2);

      // Lucas : Alerte faible perf table de 7
      final lowPerfAlert = alerts.firstWhere((a) => a.type == AlertType.lowPerformance);
      expect(lowPerfAlert.student.pseudo, 'Lucas');
      expect(lowPerfAlert.table, 7);
      expect(lowPerfAlert.value, closeTo(33.33, 0.05));

      // Lucas : Alerte inactivité
      final inactivityAlert = alerts.firstWhere((a) => a.type == AlertType.inactivity);
      expect(inactivityAlert.student.pseudo, 'Lucas');
      expect(inactivityAlert.value, 8.0);

      // Classement des tables (difficultés)
      // Table 5 : 15 attempts, 13 correct -> 86.66%
      // Table 7 : 6 attempts, 2 correct -> 33.33%
      // Table 8 : 2 attempts, 1 correct -> 50%
      // Classement attendu de la plus dure à la plus facile : T7, T8, T5
      final ranking = classStats.tableDifficultyRanking;
      expect(ranking.length, 3);
      expect(ranking[0].key, 7); // Table de 7 plus difficile
      expect(ranking[1].key, 8); // Table de 8
      expect(ranking[2].key, 5); // Table de 5 plus facile
    });
  });
}
