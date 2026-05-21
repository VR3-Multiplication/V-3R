import '../entities/shop_item.dart';
import '../repositories/shop_repository.dart';

class PurchaseItemUseCase {
  final ShopRepository repository;

  PurchaseItemUseCase(this.repository);

  Future<void> execute(String childId, ShopItem item) {
    return repository.purchaseItem(childId, item);
  }
}
