import '../entities/affiliated_child.dart';
import '../repositories/affiliation_repository.dart';

class GetAffiliatedChildrenUseCase {
  final AffiliationRepository repository;

  GetAffiliatedChildrenUseCase(this.repository);

  Future<List<AffiliatedChild>> execute() async {
    return await repository.getAffiliatedChildren();
  }
}
