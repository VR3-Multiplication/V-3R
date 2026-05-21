import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'package:app_flutter/domain/repositories/auth_repository.dart';
import 'package:app_flutter/domain/usecases/login_adult_usecase.dart';

// Mock Manuel pour éviter la génération de code complexe pendant le TDD initial
class MockAuthRepository implements AuthRepository {
  @override
  Future<UserProfile> loginAdult({required String email, required String password}) async {
    if (email == 'parent@test.com' && password == '123456') {
      return UserProfile(
        id: '123',
        role: UserRole.parent,
        email: email,
        pseudo: 'ParentTest',
      );
    }
    throw Exception('Erreur d\'authentification');
  }

  @override
  Future<UserProfile> signUpAdult({required String email, required String password, required UserRole role}) async {
    return UserProfile(id: 'new_123', role: role, email: email, pseudo: 'NewUser');
  }

  @override
  Future<UserProfile> signInChild({required String pseudo, required String pin}) async {
    if (pseudo == 'Leo' && pin == '1234') {
      return UserProfile(id: 'child_123', role: UserRole.child, pseudo: pseudo);
    }
    throw Exception('Erreur d\'authentification enfant');
  }

  @override
  Future<UserProfile> signUpChild({required String pseudo, required String pin}) async {
    return UserProfile(id: 'new_child_123', role: UserRole.child, pseudo: pseudo);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> simulatePayment() async {}

  @override
  Future<String> regenerateAffiliationCode() async {
    return 'NEWCOD';
  }
}

void main() {
  late LoginAdultUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginAdultUseCase(mockRepository);
  });

  group('LoginAdultUseCase', () {
    test('doit retourner un UserProfile si l\'email et le mot de passe sont corrects', () async {
      // Act
      final result = await useCase.execute(email: 'parent@test.com', password: '123456');

      // Assert
      expect(result.id, '123');
      expect(result.role, UserRole.parent);
      expect(result.email, 'parent@test.com');
    });

    test('doit lever une exception si l\'email est vide', () async {
      // Assert
      expect(
        () => useCase.execute(email: '', password: 'password123'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Format d\'email invalide'))),
      );
    });

    test('doit lever une exception si le mot de passe est trop court', () async {
      // Assert
      expect(
        () => useCase.execute(email: 'test@test.com', password: '123'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('au moins 6 caractères'))),
      );
    });
  });
}
