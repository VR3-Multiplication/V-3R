import '../entities/affiliate_adult.dart';
import '../repositories/affiliation_repository.dart';

class GetChildAffiliatesUseCase {
  final AffiliationRepository repository;

  GetChildAffiliatesUseCase(this.repository);

  Future<List<AffiliateAdult>> execute(String childId) async {
    return await repository.getChildAffiliates(childId);
  }
}
