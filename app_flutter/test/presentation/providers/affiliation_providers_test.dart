import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter/domain/repositories/affiliation_repository.dart';
import 'package:app_flutter/presentation/providers/affiliation_providers.dart';
import 'package:app_flutter/domain/entities/affiliated_child.dart';
import 'package:app_flutter/domain/entities/affiliate_adult.dart';

class MockAffiliationRepository implements AffiliationRepository {
  String preference = 'custom';
  bool updateCalled = false;
  String? updatedPreference;

  @override
  Future<void> affiliateChild({required String affiliationCode}) async {}

  @override
  Future<List<AffiliatedChild>> getAffiliatedChildren() async => [];

  @override
  Future<void> revokeAffiliation({required String adultId, required String childId}) async {}

  @override
  Future<List<AffiliateAdult>> getChildAffiliates(String childId) async => [];

  @override
  Future<void> updateSortOrder({required String childId, required int sortOrder}) async {}

  @override
  Future<String> getStudentSortPreference() async {
    return preference;
  }

  @override
  Future<void> updateStudentSortPreference(String pref) async {
    updateCalled = true;
    updatedPreference = pref;
    preference = pref;
  }
}

void main() {
  late MockAffiliationRepository mockRepository;
  late StudentSortPreferenceNotifier notifier;

  setUp(() {
    mockRepository = MockAffiliationRepository();
    // notifier va charger la preference au demarrage
    notifier = StudentSortPreferenceNotifier(mockRepository);
  });

  group('StudentSortPreferenceNotifier', () {
    test('doit charger la preference par defaut au demarrage', () async {
      // Attendre la fin du microtask de loadPreference() lancé dans le constructeur
      await Future.delayed(Duration.zero);
      expect(notifier.state.value, 'custom');
    });

    test('doit mettre a jour la preference et appeler le repository', () async {
      await Future.delayed(Duration.zero);
      await notifier.updatePreference('az');
      expect(notifier.state.value, 'az');
      expect(mockRepository.updateCalled, true);
      expect(mockRepository.updatedPreference, 'az');
    });
  });
}
