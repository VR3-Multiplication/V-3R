import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/mission.dart';
import 'package:app_flutter/domain/repositories/mission_repository.dart';
import 'package:app_flutter/domain/usecases/assign_mission_usecase.dart';
import 'package:app_flutter/domain/usecases/get_pending_missions_stream_usecase.dart';
import 'package:app_flutter/domain/usecases/mark_mission_as_completed_usecase.dart';

class MockMissionRepository implements MissionRepository {
  List<Mission> missions = [];

  @override
  Future<void> assignMission(Mission mission) async {
    missions.add(mission);
  }

  @override
  Stream<List<Mission>> getPendingMissionsStream(String childId) {
    return Stream.value(
        missions.where((m) => m.assignedTo == childId && !m.isCompleted).toList());
  }

  @override
  Stream<List<Mission>> getMissionsByAdultStream(String adultId) {
    return Stream.value(
        missions.where((m) => m.assignedBy == adultId).toList());
  }

  @override
  Future<void> markMissionAsCompleted(String missionId, {int? score}) async {
    final index = missions.indexWhere((m) => m.id == missionId);
    if (index != -1) {
      missions[index] = missions[index].copyWith(
        isCompleted: true,
        score: score,
        status: 'completed',
      );
    }
  }

  @override
  Future<void> abandonMission(String missionId) async {
    final index = missions.indexWhere((m) => m.id == missionId);
    if (index != -1) {
      missions[index] = missions[index].copyWith(
        isCompleted: true,
        status: 'abandoned',
      );
    }
  }
}

void main() {
  late MockMissionRepository mockRepository;
  late AssignMissionUseCase assignMissionUseCase;
  late GetPendingMissionsStreamUseCase getStreamUseCase;
  late MarkMissionAsCompletedUseCase markCompletedUseCase;

  setUp(() {
    mockRepository = MockMissionRepository();
    assignMissionUseCase = AssignMissionUseCase(mockRepository);
    getStreamUseCase = GetPendingMissionsStreamUseCase(mockRepository);
    markCompletedUseCase = MarkMissionAsCompletedUseCase(mockRepository);
  });

  group('Missions UseCases', () {
    test('AssignMissionUseCase valide et crée une mission', () async {
      await assignMissionUseCase.execute(
        assignedBy: 'adult1',
        assignedTo: 'child1',
        operationType: 'table_7',
        difficulty: 2,
      );

      expect(mockRepository.missions.length, 1);
      expect(mockRepository.missions.first.operationType, 'table_7');
      expect(mockRepository.missions.first.difficulty, 2);
    });

    test('MissionParser parse correctement les tables et objectifs personnalisés', () {
      final mission1 = Mission(
        id: '1',
        assignedBy: 'adult1',
        assignedTo: 'child1',
        operationType: 'table_6,7,8?max_errors=3&avg_time=2.5&question_time=4.0',
        difficulty: 2,
        createdAt: DateTime.now(),
      );

      expect(mission1.tables, [6, 7, 8]);
      expect(mission1.maxErrors, 3);
      expect(mission1.avgTimeLimit, 2.5);
      expect(mission1.questionTimeLimit, 4.0);
      expect(mission1.hasCustomGoals, true);

      final mission2 = Mission(
        id: '2',
        assignedBy: 'adult1',
        assignedTo: 'child1',
        operationType: 'table_5',
        difficulty: 1,
        createdAt: DateTime.now(),
      );

      expect(mission2.tables, [5]);
      expect(mission2.maxErrors, null);
      expect(mission2.avgTimeLimit, null);
      expect(mission2.questionTimeLimit, null);
      expect(mission2.hasCustomGoals, false);
    });

    test('AssignMissionUseCase accepte des tables multiples avec objectifs', () async {
      await assignMissionUseCase.execute(
        assignedBy: 'adult1',
        assignedTo: 'child1',
        operationType: 'table_3,4?max_errors=2',
        difficulty: 2,
      );

      expect(mockRepository.missions.last.operationType, 'table_3,4?max_errors=2');
    });

    test('AssignMissionUseCase lève une exception sur opération invalide', () async {
      expect(
        () => assignMissionUseCase.execute(
          assignedBy: 'adult1',
          assignedTo: 'child1',
          operationType: 'Geometrie',
          difficulty: 1,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('GetPendingMissionsStreamUseCase renvoie les missions en attente via Stream', () async {
      await assignMissionUseCase.execute(
        assignedBy: 'adult1',
        assignedTo: 'child1',
        operationType: 'all',
        difficulty: 3,
      );

      final stream = getStreamUseCase.execute(childId: 'child1');
      final missions = await stream.first;

      expect(missions.length, 1);
      expect(missions.first.assignedTo, 'child1');
    });

    test('MarkMissionAsCompletedUseCase valide la mission', () async {
      await assignMissionUseCase.execute(
        assignedBy: 'adult1',
        assignedTo: 'child1',
        operationType: 'table_2',
        difficulty: 1,
      );

      final missionId = mockRepository.missions.first.id;

      await markCompletedUseCase.execute(missionId: missionId);

      final stream = getStreamUseCase.execute(childId: 'child1');
      final pendingMissions = await stream.first;

      // La mission est terminée, donc le flux des missions EN ATTENTE doit être vide
      expect(pendingMissions.isEmpty, true);
      expect(mockRepository.missions.first.isCompleted, true);
    });
  });
}
