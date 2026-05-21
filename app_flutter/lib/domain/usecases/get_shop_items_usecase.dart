import '../entities/shop_item.dart';
import '../repositories/shop_repository.dart';

class GetShopItemsUseCase {
  final ShopRepository repository;

  GetShopItemsUseCase(this.repository);

  Future<List<ShopItem>> execute() async {
    await repository.syncShopData();
    return repository.getShopItems();
  }
}
