import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

// Note: L'interface AuthRepository doit être mise à jour pour inclure registerAdult.
class RegisterAdultUseCase {
  final AuthRepository repository;

  RegisterAdultUseCase(this.repository);

  Future<UserProfile> execute({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Format d\'email invalide.');
    }
    if (password.length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caractères.');
    }
    
    // On appelle signUpAdult sur le repository
    return await repository.signUpAdult(email: email, password: password, role: role);
  }
}
