import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'package:app_flutter/domain/repositories/auth_repository.dart';
import 'package:app_flutter/domain/usecases/register_adult_usecase.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserProfile> loginAdult({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> signUpAdult({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    return UserProfile(
      id: 'adult-123',
      role: role,
      email: email,
      pseudo: 'User_adult',
    );
  }

  @override
  Future<UserProfile> signInChild({required String pseudo, required String pin}) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> signUpChild({required String pseudo, required String pin}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> simulatePayment() async {}

  @override
  Future<String> regenerateAffiliationCode() async {
    return '123456';
  }
}

void main() {
  late RegisterAdultUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterAdultUseCase(mockRepository);
  });

  group('RegisterAdultUseCase', () {
    test('doit créer un compte adulte si email et password sont valides', () async {
      final profile = await useCase.execute(
        email: 'test@mathrunner.local',
        password: 'securepassword',
        role: UserRole.parent,
      );

      expect(profile.id, 'adult-123');
      expect(profile.email, 'test@mathrunner.local');
      expect(profile.role, UserRole.parent);
    });

    test('doit lever une exception si le format de l\'email est invalide', () async {
      expect(
        () => useCase.execute(
          email: 'invalid-email',
          password: 'securepassword',
          role: UserRole.parent,
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Format d\'email invalide.'))),
      );
    });

    test('doit lever une exception si le mot de passe est trop court', () async {
      expect(
        () => useCase.execute(
          email: 'test@mathrunner.local',
          password: '123',
          role: UserRole.parent,
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Le mot de passe doit contenir au moins 6 caractères.'))),
      );
    });
  });
}
