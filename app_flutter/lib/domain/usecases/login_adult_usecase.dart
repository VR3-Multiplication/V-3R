import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class LoginAdultUseCase {
  final AuthRepository repository;

  LoginAdultUseCase(this.repository);

  Future<UserProfile> execute({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Format d\'email invalide.');
    }
    if (password.length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caractères.');
    }
    return await repository.loginAdult(email: email, password: password);
  }
}
