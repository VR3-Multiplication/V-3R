import '../entities/mission.dart';

abstract class MissionRepository {
  /// Assigne une nouvelle mission à un enfant
  Future<void> assignMission(Mission mission);

  /// Récupère un flux (Stream) en temps réel des missions en attente pour un enfant
  Stream<List<Mission>> getPendingMissionsStream(String childId);

  /// Récupère un flux (Stream) en temps réel des missions données par un adulte
  Stream<List<Mission>> getMissionsByAdultStream(String adultId);

  /// Marque une mission comme terminée (quand l'enfant a réussi) avec un score facultatif
  Future<void> markMissionAsCompleted(String missionId, {int? score});

  /// Abandonne ou annule une mission
  Future<void> abandonMission(String missionId);
}
