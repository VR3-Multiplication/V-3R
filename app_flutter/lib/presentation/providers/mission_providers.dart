import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import 'local_database_provider.dart';
import '../../data/datasources/mission_remote_data_source.dart';
import '../../data/repositories/mission_repository_impl.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/usecases/assign_mission_usecase.dart';
import '../../domain/usecases/get_pending_missions_stream_usecase.dart';
import '../../domain/usecases/mark_mission_as_completed_usecase.dart';
import '../../domain/entities/mission.dart';

// 1. Data Source
final missionRemoteDataSourceProvider = Provider<MissionRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MissionRemoteDataSourceImpl(supabaseClient: client);
});

// 2. Repository
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final dataSource = ref.watch(missionRemoteDataSourceProvider);
  final localDb = ref.watch(localDatabaseProvider);
  return MissionRepositoryImpl(
    remoteDataSource: dataSource,
    localDb: localDb,
  );
});

// 3. UseCases
final assignMissionUseCaseProvider = Provider<AssignMissionUseCase>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return AssignMissionUseCase(repository);
});

final getPendingMissionsStreamUseCaseProvider = Provider<GetPendingMissionsStreamUseCase>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return GetPendingMissionsStreamUseCase(repository);
});

final markMissionAsCompletedUseCaseProvider = Provider<MarkMissionAsCompletedUseCase>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return MarkMissionAsCompletedUseCase(repository);
});

final pendingMissionsStreamProvider = StreamProvider.family<List<Mission>, String>((ref, childId) {
  final useCase = ref.watch(getPendingMissionsStreamUseCaseProvider);
  return useCase.execute(childId: childId);
});

final missionsAssignedByAdultProvider = StreamProvider.family<List<Mission>, String>((ref, adultId) {
  final repository = ref.watch(missionRepositoryProvider);
  return repository.getMissionsByAdultStream(adultId);
});
