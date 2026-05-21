import '../repositories/affiliation_repository.dart';

class AffiliateChildUseCase {
  final AffiliationRepository repository;

  AffiliateChildUseCase(this.repository);

  Future<void> execute({required String affiliationCode}) async {
    final code = affiliationCode.trim().toUpperCase();

    if (code.isEmpty) {
      throw Exception('Le code d\'affiliation ne peut pas être vide.');
    }
    if (code.length != 6) {
      throw Exception('Le code d\'affiliation doit comporter exactement 6 caractères.');
    }
    
    await repository.affiliateChild(affiliationCode: code);
  }
}
