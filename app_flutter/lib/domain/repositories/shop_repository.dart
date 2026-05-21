import '../entities/shop_item.dart';
import '../entities/inventory_item.dart';

abstract class ShopRepository {
  Future<void> syncShopData();
  Future<List<ShopItem>> getShopItems();
  Future<List<InventoryItem>> getChildInventory(String childId);
  Future<void> purchaseItem(String childId, ShopItem item);
  Future<void> equipItem(String childId, String itemId);
}
