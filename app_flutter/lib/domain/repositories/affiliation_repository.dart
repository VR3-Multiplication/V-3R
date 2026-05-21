import '../entities/affiliated_child.dart';
import '../entities/affiliate_adult.dart';

abstract class AffiliationRepository {
  /// Lie un enfant au compte de l'adulte actuellement connecté via le code à 6 caractères
  Future<void> affiliateChild({required String affiliationCode});

  /// Récupère la liste des enfants affiliés à l'adulte actuellement connecté
  Future<List<AffiliatedChild>> getAffiliatedChildren();

  /// Révoque une affiliation
  Future<void> revokeAffiliation({required String adultId, required String childId});

  /// Récupère la liste des autres adultes affiliés à cet enfant
  Future<List<AffiliateAdult>> getChildAffiliates(String childId);

  /// Met à jour l'ordre d'affichage d'un enfant affilié
  Future<void> updateSortOrder({required String childId, required int sortOrder});

  /// Récupère la préférence de tri des élèves
  Future<String> getStudentSortPreference();

  /// Met à jour la préférence de tri des élèves
  Future<void> updateStudentSortPreference(String preference);
}
