import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'package:app_flutter/domain/entities/affiliated_child.dart';
import 'package:app_flutter/domain/entities/affiliate_adult.dart';
import 'package:app_flutter/domain/repositories/affiliation_repository.dart';
import 'package:app_flutter/domain/usecases/get_affiliated_children_usecase.dart';

class MockAffiliationRepository implements AffiliationRepository {
  @override
  Future<void> affiliateChild({required String affiliationCode}) async {}

  @override
  Future<List<AffiliatedChild>> getAffiliatedChildren() async {
    return [
      AffiliatedChild(
        profile: UserProfile(id: '1', role: UserRole.child, pseudo: 'Leo'),
        isSuperAdmin: true,
      ),
      AffiliatedChild(
        profile: UserProfile(id: '2', role: UserRole.child, pseudo: 'Mia'),
        isSuperAdmin: false,
      ),
    ];
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
  late GetAffiliatedChildrenUseCase useCase;
  late MockAffiliationRepository mockRepository;

  setUp(() {
    mockRepository = MockAffiliationRepository();
    useCase = GetAffiliatedChildrenUseCase(mockRepository);
  });

  group('GetAffiliatedChildrenUseCase', () {
    test('Doit retourner la liste des enfants', () async {
      final children = await useCase.execute();
      expect(children.length, 2);
      expect(children.first.profile.pseudo, 'Leo');
      expect(children.first.isSuperAdmin, true);
      expect(children.last.isSuperAdmin, false);
    });
  });
}
