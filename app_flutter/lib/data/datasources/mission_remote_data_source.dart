import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/mission.dart';

abstract class MissionRemoteDataSource {
  Future<void> assignMission(Mission mission);
  Stream<List<Map<String, dynamic>>> getPendingMissionsStream(String childId);
  Stream<List<Map<String, dynamic>>> getMissionsByAdultStream(String adultId);
  Future<void> markMissionAsCompleted(String missionId, {int? score});
  Future<void> abandonMission(String missionId);
}

class MissionRemoteDataSourceImpl implements MissionRemoteDataSource {
  final SupabaseClient supabaseClient;

  MissionRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> assignMission(Mission mission) async {
    final Map<String, dynamic> data = {
      'id': mission.id,
      'assigned_by': mission.assignedBy,
      'assigned_to': mission.assignedTo,
      'operation_type': mission.operationType,
      'difficulty': mission.difficulty,
      'is_completed': mission.isCompleted,
      'created_at': mission.createdAt.toIso8601String(),
    };
    
    // Si la db prend en charge le score et le statut, on les ajoute
    try {
      data['score'] = mission.score;
      data['status'] = mission.status;
      await supabaseClient.from('missions').insert(data);
    } catch (e) {
      // Fallback sans score ni status
      data.remove('score');
      data.remove('status');
      await supabaseClient.from('missions').insert(data);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getPendingMissionsStream(String childId) {
    // Supabase Realtime ne supporte qu'un seul filtre .eq() sur les streams.
    // On filtre donc par 'assigned_to', puis on filtre les missions terminées côté client.
    return supabaseClient
        .from('missions')
        .stream(primaryKey: ['id'])
        .eq('assigned_to', childId)
        .order('created_at')
        .map((list) => list.where((mission) => mission['is_completed'] == false).toList());
  }

  @override
  Stream<List<Map<String, dynamic>>> getMissionsByAdultStream(String adultId) {
    return supabaseClient
        .from('missions')
        .stream(primaryKey: ['id'])
        .eq('assigned_by', adultId)
        .order('created_at', ascending: false);
  }

  @override
  Future<void> markMissionAsCompleted(String missionId, {int? score}) async {
    final updates = {
      'is_completed': true,
      'status': 'completed',
    };
    if (score != null) {
      updates['score'] = score;
    }
    
    try {
      await supabaseClient
          .from('missions')
          .update(updates)
          .eq('id', missionId);
    } catch (e) {
      // Fallback
      await supabaseClient
          .from('missions')
          .update({'is_completed': true})
          .eq('id', missionId);
    }
  }

  @override
  Future<void> abandonMission(String missionId) async {
    try {
      await supabaseClient
          .from('missions')
          .update({
            'is_completed': true,
            'status': 'abandoned',
          })
          .eq('id', missionId);
    } catch (e) {
      // Fallback
      await supabaseClient
          .from('missions')
          .update({'is_completed': true})
          .eq('id', missionId);
    }
  }
}
