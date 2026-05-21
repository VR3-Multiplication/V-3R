import 'dart:async';
import 'package:drift/drift.dart';
import '../../domain/entities/mission.dart';
import '../../domain/repositories/mission_repository.dart';
import '../datasources/mission_remote_data_source.dart';
import '../local/app_database.dart' as db;

class MissionRepositoryImpl implements MissionRepository {
  final MissionRemoteDataSource remoteDataSource;
  final db.AppDatabase localDb;

  MissionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDb,
  });

  @override
  Future<void> assignMission(Mission mission) async {
    await remoteDataSource.assignMission(mission);
  }

  @override
  Stream<List<Mission>> getPendingMissionsStream(String childId) {
    late StreamController<List<Mission>> controller;
    StreamSubscription? remoteSubscription;
    StreamSubscription? localSubscription;

    controller = StreamController<List<Mission>>(
      onListen: () {
        // 1. Écouter Supabase en temps réel et synchroniser dans SQLite
        remoteSubscription = remoteDataSource.getPendingMissionsStream(childId).listen(
          (remoteMissions) async {
            try {
              // Nettoyer les anciennes missions en attente qui ne sont plus présentes dans Supabase
              final remoteIds = remoteMissions.map((m) => m['id'] as String).toList();
              await localDb.deleteOldPendingMissions(childId, remoteIds);

              // Insérer/Mettre à jour les missions actives reçues de Supabase
              final companions = remoteMissions.map((json) => db.MissionsCompanion.insert(
                id: json['id'],
                adultId: json['assigned_by'],
                childId: json['assigned_to'],
                operationType: json['operation_type'],
                difficulty: json['difficulty'],
                isCompleted: Value(json['is_completed']),
                createdAt: DateTime.parse(json['created_at']),
              )).toList();
              await localDb.insertMissions(companions);
            } catch (e) {
              // Gestion silencieuse (ex: déconnexion temporaire)
            }
          },
          onError: (e) {
            // Ignorer ou propager l'erreur
          },
        );

        // 2. Écouter les modifications de la base locale réactive et émettre les données dans le controller
        localSubscription = localDb.watchPendingMissions(childId).listen(
          (list) {
            final domainMissions = list.map((m) => Mission(
              id: m.id,
              assignedBy: m.adultId,
              assignedTo: m.childId,
              operationType: m.operationType,
              difficulty: m.difficulty,
              isCompleted: m.isCompleted,
              createdAt: m.createdAt,
            )).toList();
            if (!controller.isClosed) {
              controller.add(domainMissions);
            }
          },
          onError: (e) {
            if (!controller.isClosed) {
              controller.addError(e);
            }
          },
        );
      },
      onCancel: () {
        remoteSubscription?.cancel();
        localSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Stream<List<Mission>> getMissionsByAdultStream(String adultId) {
    return remoteDataSource.getMissionsByAdultStream(adultId).map((list) {
      return list.map((json) => Mission(
        id: json['id'],
        assignedBy: json['assigned_by'],
        assignedTo: json['assigned_to'],
        operationType: json['operation_type'],
        difficulty: json['difficulty'],
        isCompleted: json['is_completed'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
        score: json['score'] as int?,
        status: json['status'] as String? ?? (json['is_completed'] == true ? 'completed' : 'pending'),
      )).toList();
    });
  }

  @override
  Future<void> markMissionAsCompleted(String missionId, {int? score}) async {
    // 1. Mettre à jour localement immédiatement
    await (localDb.update(localDb.missions)..where((t) => t.id.equals(missionId)))
      .write(const db.MissionsCompanion(isCompleted: Value(true)));

    // 2. Tenter de mettre à jour Supabase
    try {
      await remoteDataSource.markMissionAsCompleted(missionId, score: score);
    } catch (e) {
      // Ignorer
    }
  }

  @override
  Future<void> abandonMission(String missionId) async {
    // 1. Mettre à jour localement immédiatement
    await (localDb.update(localDb.missions)..where((t) => t.id.equals(missionId)))
      .write(const db.MissionsCompanion(isCompleted: Value(true)));

    // 2. Tenter de mettre à jour Supabase
    try {
      await remoteDataSource.abandonMission(missionId);
    } catch (e) {
      // Ignorer
    }
  }
}
