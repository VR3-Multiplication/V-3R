import '../entities/inventory_item.dart';
import '../repositories/shop_repository.dart';

class GetChildInventoryUseCase {
  final ShopRepository repository;

  GetChildInventoryUseCase(this.repository);

  Future<List<InventoryItem>> execute(String childId) {
    return repository.getChildInventory(childId);
  }
}
