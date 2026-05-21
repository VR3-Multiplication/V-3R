import '../entities/mission.dart';
import '../repositories/mission_repository.dart';

class GetPendingMissionsStreamUseCase {
  final MissionRepository repository;

  GetPendingMissionsStreamUseCase(this.repository);

  Stream<List<Mission>> execute({required String childId}) {
    if (childId.isEmpty) {
      throw Exception('L\'ID de l\'enfant ne peut pas être vide.');
    }
    
    return repository.getPendingMissionsStream(childId);
  }
}
