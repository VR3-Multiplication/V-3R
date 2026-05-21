import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/affiliate_adult.dart';
import 'package:app_flutter/domain/entities/affiliated_child.dart';
import 'package:app_flutter/domain/repositories/affiliation_repository.dart';
import 'package:app_flutter/domain/usecases/revoke_affiliation_usecase.dart';

class MockAffiliationRepository implements AffiliationRepository {
  String? revokedAdultId;
  String? revokedChildId;

  @override
  Future<void> affiliateChild({required String affiliationCode}) async {}

  @override
  Future<List<AffiliatedChild>> getAffiliatedChildren() async => [];

  @override
  Future<void> revokeAffiliation({required String adultId, required String childId}) async {
    revokedAdultId = adultId;
    revokedChildId = childId;
  }

  @override
  Future<List<AffiliateAdult>> getChildAffiliates(String childId) async => [];

  @override
  Future<void> updateSortOrder({required String childId, required int sortOrder}) async {}

  @override
  Future<String> getStudentSortPreference() async => 'custom';

  @override
  Future<void> updateStudentSortPreference(String preference) async {}
}

void main() {
  late RevokeAffiliationUseCase useCase;
  late MockAffiliationRepository mockRepository;

  setUp(() {
    mockRepository = MockAffiliationRepository();
    useCase = RevokeAffiliationUseCase(mockRepository);
  });

  test('doit appeler le repository pour revoquer une affiliation', () async {
    await useCase.execute(adultId: 'adult-1', childId: 'child-2');

    expect(mockRepository.revokedAdultId, 'adult-1');
    expect(mockRepository.revokedChildId, 'child-2');
  });
}
