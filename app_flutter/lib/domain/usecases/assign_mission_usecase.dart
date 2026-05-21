import '../entities/mission.dart';
import '../repositories/mission_repository.dart';
import 'package:uuid/uuid.dart';

class AssignMissionUseCase {
  final MissionRepository repository;

  AssignMissionUseCase(this.repository);

  Future<void> execute({
    required String assignedBy,
    required String assignedTo,
    required String operationType,
    required int difficulty,
  }) async {
    if (assignedBy.isEmpty || assignedTo.isEmpty) {
      throw Exception('Les identifiants ne peuvent pas être vides.');
    }
    
    final baseType = operationType.split('?')[0];
    if (!baseType.startsWith('table_') && baseType != 'all') {
      throw Exception('Seules les tables de multiplication sont supportées (ex: table_7, all).');
    }

    if (difficulty < 1 || difficulty > 3) {
      throw Exception('La difficulté doit être comprise entre 1 et 3.');
    }

    final mission = Mission(
      id: const Uuid().v4(), // Génération d'un UUID unique pour la mission
      assignedBy: assignedBy,
      assignedTo: assignedTo,
      operationType: operationType.toLowerCase(),
      difficulty: difficulty,
      isCompleted: false,
      createdAt: DateTime.now().toUtc(),
    );

    await repository.assignMission(mission);
  }
}
