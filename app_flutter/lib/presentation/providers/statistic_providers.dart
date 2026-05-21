import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import 'local_database_provider.dart';
import 'class_providers.dart';
import '../../data/datasources/statement_remote_data_source.dart';
import '../../data/repositories/statement_repository_impl.dart';
import '../../domain/repositories/statement_repository.dart';
import '../../domain/usecases/get_child_statistics_usecase.dart';
import '../../domain/usecases/get_class_statistics_usecase.dart';
import '../../domain/entities/child_statistics.dart';
import '../../domain/entities/class_statistics.dart';

// 1. Data Source
final statementRemoteDataSourceProvider = Provider<StatementRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StatementRemoteDataSourceImpl(supabaseClient: client);
});

// 2. Repository
final statementRepositoryProvider = Provider<StatementRepository>((ref) {
  final dataSource = ref.watch(statementRemoteDataSourceProvider);
  final localDb = ref.watch(localDatabaseProvider);
  return StatementRepositoryImpl(
    remoteDataSource: dataSource,
    localDb: localDb,
  );
});

// 3. UseCases
final getChildStatisticsUseCaseProvider = Provider<GetChildStatisticsUseCase>((ref) {
  final repository = ref.watch(statementRepositoryProvider);
  return GetChildStatisticsUseCase(repository);
});

final getClassStatisticsUseCaseProvider = Provider<GetClassStatisticsUseCase>((ref) {
  final classRepository = ref.watch(classRepositoryProvider);
  final statementRepository = ref.watch(statementRepositoryProvider);
  return GetClassStatisticsUseCase(
    classRepository: classRepository,
    statementRepository: statementRepository,
  );
});

// 4. State Providers
final childStatisticsProvider = FutureProvider.family<ChildStatistics, String>((ref, childId) async {
  final useCase = ref.watch(getChildStatisticsUseCaseProvider);
  return await useCase.execute(childId);
});

final classStatisticsProvider = FutureProvider.family<ClassStatistics, String>((ref, classId) async {
  final useCase = ref.watch(getClassStatisticsUseCaseProvider);
  return await useCase.execute(classId);
});

