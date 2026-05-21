import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'package:app_flutter/domain/repositories/auth_repository.dart';
import 'package:app_flutter/domain/usecases/login_child_usecase.dart';
import 'package:app_flutter/domain/usecases/register_child_usecase.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserProfile> signInChild({required String pseudo, required String pin}) async {
    if (pseudo == 'Leo' && pin == '1234') {
      return UserProfile(id: 'child_123', role: UserRole.child, pseudo: pseudo);
    }
    throw Exception('Mauvais pseudo ou pin');
  }

  @override
  Future<UserProfile> signUpChild({required String pseudo, required String pin}) async {
    return UserProfile(id: 'new_child', role: UserRole.child, pseudo: pseudo);
  }

  @override
  Future<UserProfile> loginAdult({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> signUpAdult({required String email, required String password, required UserRole role}) async {
    throw UnimplementedError();
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
  late LoginChildUseCase loginUseCase;
  late RegisterChildUseCase registerUseCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginChildUseCase(mockRepository);
    registerUseCase = RegisterChildUseCase(mockRepository);
  });

  group('LoginChildUseCase', () {
    test('Doit retourner un profil si pseudo et pin sont valides', () async {
      final result = await loginUseCase.execute(pseudo: 'Leo', pin: '1234');
      expect(result.pseudo, 'Leo');
      expect(result.role, UserRole.child);
    });

    test('Doit lever une exception si le pseudo est vide', () async {
      expect(
        () => loginUseCase.execute(pseudo: '   ', pin: '1234'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('ne peut pas être vide'))),
      );
    });
  });

  group('RegisterChildUseCase', () {
    test('Doit retourner un profil après inscription', () async {
      final result = await registerUseCase.execute(pseudo: 'Ninja', pin: '0000');
      expect(result.pseudo, 'Ninja');
    });

    test('Doit lever une exception si le PIN est trop court', () async {
      expect(
        () => registerUseCase.execute(pseudo: 'Ninja', pin: '12'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('au moins 4 chiffres'))),
      );
    });
    
    test('Doit lever une exception si le Pseudo est trop court', () async {
      expect(
        () => registerUseCase.execute(pseudo: 'Ni', pin: '1234'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('au moins 3 caractères'))),
      );
    });
  });
}
