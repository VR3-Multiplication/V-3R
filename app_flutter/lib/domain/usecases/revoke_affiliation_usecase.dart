import '../repositories/affiliation_repository.dart';

class RevokeAffiliationUseCase {
  final AffiliationRepository repository;

  RevokeAffiliationUseCase(this.repository);

  Future<void> execute({required String adultId, required String childId}) async {
    await repository.revokeAffiliation(adultId: adultId, childId: childId);
  }
}
