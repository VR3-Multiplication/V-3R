import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class LoginChildUseCase {
  final AuthRepository repository;

  LoginChildUseCase(this.repository);

  Future<UserProfile> execute({
    required String pseudo,
    required String pin,
  }) async {
    if (pseudo.trim().isEmpty) {
      throw Exception('Le pseudo ne peut pas être vide.');
    }
    if (pin.isEmpty) {
      throw Exception('Le code PIN ne peut pas être vide.');
    }
    
    // On appelle signInChild sur le repository (à créer)
    return await repository.signInChild(pseudo: pseudo.trim(), pin: pin);
  }
}
