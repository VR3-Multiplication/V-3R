import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'package:app_flutter/domain/entities/affiliate_adult.dart';
import 'package:app_flutter/domain/entities/affiliated_child.dart';
import 'package:app_flutter/domain/repositories/affiliation_repository.dart';
import 'package:app_flutter/domain/usecases/get_child_affiliates_usecase.dart';

class MockAffiliationRepository implements AffiliationRepository {
  @override
  Future<void> affiliateChild({required String affiliationCode}) async {}

  @override
  Future<List<AffiliatedChild>> getAffiliatedChildren() async => [];

  @override
  Future<void> revokeAffiliation({required String adultId, required String childId}) async {}

  @override
  Future<List<AffiliateAdult>> getChildAffiliates(String childId) async {
    return [
      AffiliateAdult(
        id: 'adult-1',
        pseudo: 'Parent 1',
        isSuperAdmin: true,
      ),
    ];
  }

  @override
  Future<void> updateSortOrder({required String childId, required int sortOrder}) async {}

  @override
  Future<String> getStudentSortPreference() async => 'custom';

  @override
  Future<void> updateStudentSortPreference(String preference) async {}
}

void main() {
  late GetChildAffiliatesUseCase useCase;
  late MockAffiliationRepository mockRepository;

  setUp(() {
    mockRepository = MockAffiliationRepository();
    useCase = GetChildAffiliatesUseCase(mockRepository);
  });

  test('doit retourner la liste des adultes affilies à un enfant', () async {
    final list = await useCase.execute('child-1');

    expect(list.length, 1);
    expect(list.first.id, 'adult-1');
    expect(list.first.pseudo, 'Parent 1');
    expect(list.first.isSuperAdmin, true);
  });
}
