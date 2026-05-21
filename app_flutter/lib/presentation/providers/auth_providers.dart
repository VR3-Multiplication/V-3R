import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_adult_usecase.dart';
import '../../domain/usecases/register_adult_usecase.dart';
import '../../domain/usecases/login_child_usecase.dart';
import '../../domain/usecases/register_child_usecase.dart';
import '../../domain/entities/user_profile.dart';

// 1. Fournir l'instance Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// 2. Fournir le DataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSourceImpl(supabaseClient: client);
});

// 3. Fournir le Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: dataSource);
});

// 4. Fournir le UseCase
final loginAdultUseCaseProvider = Provider<LoginAdultUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginAdultUseCase(repository);
});

// 5. Fournir le Register UseCase
final registerAdultUseCaseProvider = Provider<RegisterAdultUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterAdultUseCase(repository);
});

// 6. Fournir les UseCases Enfant
final loginChildUseCaseProvider = Provider<LoginChildUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginChildUseCase(repository);
});

final registerChildUseCaseProvider = Provider<RegisterChildUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterChildUseCase(repository);
});

// 7. StreamProvider pour écouter les changements d'état d'authentification
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// 8. Fournir le profil de l'utilisateur actuellement connecté
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  // On écoute le flux d'authentification pour forcer la réévaluation du profil à chaque login/logout
  ref.watch(authStateProvider);

  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  final response = await client
      .from('profiles')
      .select('id, role, pseudo, full_name, affiliation_code')
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) return null;

  UserRole role;
  final roleStr = response['role'];
  if (roleStr == 'teacher') {
    role = UserRole.teacher;
  } else if (roleStr == 'child') {
    role = UserRole.child;
  } else {
    role = UserRole.parent;
  }

  return UserProfile(
    id: response['id'],
    role: role,
    email: user.email,
    pseudo: response['pseudo'] ?? '',
    fullName: response['full_name'],
    affiliationCode: response['affiliation_code'],
  );
});

// 9. Provider pour charger le profil de n'importe quel adulte par son ID (pour savoir qui envoie la mission)
final adultProfileProvider = FutureProvider.family<UserProfile?, String>((ref, adultId) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('profiles')
      .select('id, role, pseudo, full_name')
      .eq('id', adultId)
      .maybeSingle();

  if (response == null) return null;

  UserRole role;
  final roleStr = response['role'];
  if (roleStr == 'teacher') {
    role = UserRole.teacher;
  } else if (roleStr == 'child') {
    role = UserRole.child;
  } else {
    role = UserRole.parent;
  }

  return UserProfile(
    id: response['id'],
    role: role,
    email: null,
    pseudo: response['pseudo'] ?? '',
    fullName: response['full_name'],
  );
});
