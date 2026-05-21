import '../../domain/entities/user_profile.dart';
import '../../domain/entities/affiliated_child.dart';
import '../../domain/entities/affiliate_adult.dart';
import '../../domain/repositories/affiliation_repository.dart';
import '../datasources/affiliation_remote_data_source.dart';

class AffiliationRepositoryImpl implements AffiliationRepository {
  final AffiliationRemoteDataSource remoteDataSource;

  AffiliationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> affiliateChild({required String affiliationCode}) async {
    final exists = await remoteDataSource.checkAffiliationCodeExists(affiliationCode);
    if (!exists) {
      throw Exception('Code invalide ou enfant introuvable.');
    }

    try {
      await remoteDataSource.affiliateChild(code: affiliationCode);
    } catch (e) {
      // Simplification des erreurs pour l'interface utilisateur
      if (e.toString().contains('Code invalide')) {
        throw Exception('Code invalide ou enfant introuvable.');
      }
      throw Exception('Une erreur est survenue lors de l\'affiliation.');
    }
  }

  @override
  Future<List<AffiliatedChild>> getAffiliatedChildren() async {
    final data = await remoteDataSource.getAffiliatedChildren();
    
    return data.map((json) {
      final profileJson = json['profile'] as Map<String, dynamic>;
      final profile = UserProfile(
        id: profileJson['id'],
        role: UserRole.child,
        pseudo: profileJson['pseudo'] ?? 'Enfant',
        fullName: profileJson['full_name'],
      );
      return AffiliatedChild(
        profile: profile,
        isSuperAdmin: json['is_super_admin'] as bool,
        sortOrder: (json['sort_order'] as int?) ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> revokeAffiliation({required String adultId, required String childId}) async {
    await remoteDataSource.revokeAffiliation(adultId: adultId, childId: childId);
  }

  @override
  Future<List<AffiliateAdult>> getChildAffiliates(String childId) async {
    final data = await remoteDataSource.getChildAffiliates(childId);
    return data.map((json) {
      return AffiliateAdult(
        id: json['adult_id'],
        pseudo: json['pseudo'] ?? 'Inconnu',
        isSuperAdmin: json['is_super_admin'] as bool,
      );
    }).toList();
  }

  @override
  Future<void> updateSortOrder({required String childId, required int sortOrder}) async {
    await remoteDataSource.updateSortOrder(childId: childId, sortOrder: sortOrder);
  }

  @override
  Future<String> getStudentSortPreference() async {
    return await remoteDataSource.getStudentSortPreference();
  }

  @override
  Future<void> updateStudentSortPreference(String preference) async {
    await remoteDataSource.updateStudentSortPreference(preference);
  }
}
