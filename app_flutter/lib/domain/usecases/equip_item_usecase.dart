import '../repositories/shop_repository.dart';

class EquipItemUseCase {
  final ShopRepository repository;

  EquipItemUseCase(this.repository);

  Future<void> execute(String childId, String itemId) {
    return repository.equipItem(childId, itemId);
  }
}
