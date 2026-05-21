import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/repositories/affiliation_repository.dart';
import 'package:app_flutter/domain/usecases/affiliate_child_usecase.dart';
import 'package:app_flutter/domain/entities/affiliated_child.dart';
import 'package:app_flutter/domain/entities/affiliate_adult.dart';

class MockAffiliationRepository implements AffiliationRepository {
  String? lastCodeReceived;

  @override
  Future<void> affiliateChild({required String affiliationCode}) async {
    lastCodeReceived = affiliationCode;
    if (affiliationCode == 'INVALID') {
      throw Exception('Code introuvable.');
    }
  }

  @override
  Future<List<AffiliatedChild>> getAffiliatedChildren() async {
    return [];
  }

  @override
  Future<void> revokeAffiliation({required String adultId, required String childId}) async {}

  @override
  Future<List<AffiliateAdult>> getChildAffiliates(String childId) async {
    return [];
  }

  @override
  Future<void> updateSortOrder({required String childId, required int sortOrder}) async {}

  @override
  Future<String> getStudentSortPreference() async {
    return 'custom';
  }

  @override
  Future<void> updateStudentSortPreference(String preference) async {}
}

void main() {
  late AffiliateChildUseCase useCase;
  late MockAffiliationRepository mockRepository;

  setUp(() {
    mockRepository = MockAffiliationRepository();
    useCase = AffiliateChildUseCase(mockRepository);
  });

  group('AffiliateChildUseCase', () {
    test('Doit appeler le repository avec le code en majuscules si valide (6 caractères)', () async {
      await useCase.execute(affiliationCode: 'a1b2c3');
      expect(mockRepository.lastCodeReceived, 'A1B2C3');
    });

    test('Doit lever une exception si le code est vide', () async {
      expect(
        () => useCase.execute(affiliationCode: '   '),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('ne peut pas être vide'))),
      );
    });

    test('Doit lever une exception si le code ne fait pas 6 caractères', () async {
      expect(
        () => useCase.execute(affiliationCode: 'A1B2C'), // 5 chars
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('exactement 6 caractères'))),
      );
      
      expect(
        () => useCase.execute(affiliationCode: 'A1B2C3D'), // 7 chars
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('exactement 6 caractères'))),
      );
    });
  });
}
