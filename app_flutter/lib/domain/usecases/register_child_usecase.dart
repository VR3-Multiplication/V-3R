import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class RegisterChildUseCase {
  final AuthRepository repository;

  RegisterChildUseCase(this.repository);

  Future<UserProfile> execute({
    required String pseudo,
    required String pin,
  }) async {
    if (pseudo.trim().length < 3) {
      throw Exception('Le pseudo doit contenir au moins 3 caractères.');
    }
    if (pin.length < 4) {
      throw Exception('Le code PIN doit contenir au moins 4 chiffres.');
    }
    
    // On appelle signUpChild sur le repository (à créer)
    return await repository.signUpChild(pseudo: pseudo.trim(), pin: pin);
  }
}
