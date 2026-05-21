import '../entities/user_profile.dart';

abstract class AuthRepository {
  /// Connecte un adulte (Parent ou Enseignant) avec un email et un mot de passe
  Future<UserProfile> loginAdult({
    required String email,
    required String password,
  });

  /// Inscrit un adulte (Parent ou Enseignant)
  Future<UserProfile> signUpAdult({
    required String email,
    required String password,
    required UserRole role,
  });

  /// Connecte un enfant avec Pseudo et PIN
  Future<UserProfile> signInChild({
    required String pseudo,
    required String pin,
  });

  /// Inscrit un enfant avec Pseudo et PIN
  Future<UserProfile> signUpChild({
    required String pseudo,
    required String pin,
  });

  /// Déconnecte l'utilisateur courant
  Future<void> logout();

  /// Simule un paiement pour devenir Super-Admin (TEST UNIQUEMENT)
  Future<void> simulatePayment();

  /// Régénère le code d'affiliation unique de l'enfant connecté
  Future<String> regenerateAffiliationCode();
}
