import '../repositories/mission_repository.dart';

class MarkMissionAsCompletedUseCase {
  final MissionRepository repository;

  MarkMissionAsCompletedUseCase(this.repository);

  Future<void> execute({required String missionId, int? score}) async {
    if (missionId.isEmpty) {
      throw Exception('L\'ID de la mission ne peut pas être vide.');
    }
    
    await repository.markMissionAsCompleted(missionId, score: score);
  }
}
