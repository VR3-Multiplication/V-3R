import 'dart:math';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile> loginAdult({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.loginAdult(email: email, password: password);
    
    if (response.user == null) {
      throw Exception('Impossible de récupérer l\'utilisateur après la connexion.');
    }

    final user = response.user!;
    // On extrait le rôle depuis les métadonnées (stockées lors du signUp)
    final roleString = user.userMetadata?['role'] ?? 'parent';
    
    UserRole role;
    if (roleString == 'teacher') {
      role = UserRole.teacher;
    } else {
      role = UserRole.parent;
    }

    return UserProfile(
      id: user.id,
      role: role,
      email: user.email,
      pseudo: 'User_${user.id.substring(0, 5)}', // Pseudo générique en attendant la table profile
    );
  }

  @override
  Future<UserProfile> signUpAdult({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await remoteDataSource.signUpAdult(
      email: email,
      password: password,
      role: role.name,
    );
    
    if (response.user == null) {
      throw Exception('Impossible de récupérer l\'utilisateur après l\'inscription.');
    }

    final user = response.user!;
    
    // Insertion directe du profil en base pour contourner un éventuel problème de trigger
    try {
      await remoteDataSource.createUserProfile(
        id: user.id,
        role: role.name,
        pseudo: 'User_${user.id.substring(0, 5)}',
      );
    } catch (e) {
      // Ignorer si le trigger a déjà fait le travail ou en cas d'erreur de duplication
    }
    
    return UserProfile(
      id: user.id,
      role: role,
      email: user.email,
      pseudo: 'User_${user.id.substring(0, 5)}',
    );
  }

  @override
  Future<UserProfile> signInChild({
    required String pseudo,
    required String pin,
  }) async {
    final String generatedEmail = '${pseudo.toLowerCase().replaceAll(' ', '')}@kids.mathrunner.local';
    
    // On réutilise la méthode du data source
    final response = await remoteDataSource.loginAdult(email: generatedEmail, password: pin);
    
    if (response.user == null) {
      throw Exception('Impossible de récupérer l\'utilisateur après la connexion.');
    }

    final user = response.user!;
    return UserProfile(
      id: user.id,
      role: UserRole.child,
      email: null, // On ne l'expose pas dans l'app
      pseudo: pseudo,
    );
  }

  @override
  Future<UserProfile> signUpChild({
    required String pseudo,
    required String pin,
  }) async {
    final String generatedEmail = '${pseudo.toLowerCase().replaceAll(' ', '')}@kids.mathrunner.local';
    
    final response = await remoteDataSource.signUpAdult(
      email: generatedEmail,
      password: pin,
      role: UserRole.child.name,
      pseudo: pseudo,
    );
    
    if (response.user == null) {
      throw Exception('Impossible de récupérer l\'utilisateur après l\'inscription.');
    }

    final user = response.user!;
    
    // Génération locale d'un code d'affiliation unique à 6 caractères
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final String affiliationCode = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();

    // Insertion directe du profil en base pour contourner un éventuel problème de trigger
    try {
      await remoteDataSource.createUserProfile(
        id: user.id,
        role: 'child',
        pseudo: pseudo,
        affiliationCode: affiliationCode,
      );
    } catch (e) {
      // Ignorer si le trigger a déjà fait le travail
    }

    return UserProfile(
      id: user.id,
      role: UserRole.child,
      email: null,
      pseudo: pseudo,
      affiliationCode: affiliationCode,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<void> simulatePayment() async {
    await remoteDataSource.simulatePayment();
  }

  @override
  Future<String> regenerateAffiliationCode() async {
    final userId = remoteDataSource.currentUserId;
    if (userId == null) throw Exception("Utilisateur non connecté.");

    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final String newCode = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();

    await remoteDataSource.updateProfileAffiliationCode(
      userId: userId,
      code: newCode,
    );

    return newCode;
  }
}
