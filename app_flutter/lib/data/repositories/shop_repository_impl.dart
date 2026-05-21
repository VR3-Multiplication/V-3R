import 'package:drift/drift.dart';
import '../../domain/entities/shop_item.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_data_source.dart';
import '../local/app_database.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;
  final AppDatabase localDb;

  ShopRepositoryImpl({required this.remoteDataSource, required this.localDb});

  // --- Mappers ---
  ShopItem _toEntity(ShopItemData data) => ShopItem(
    id: data.id,
    name: data.name,
    description: data.description,
    price: data.price,
    category: data.category,
    unityId: data.unityId,
  );

  InventoryItem _toInventoryEntity(LocalInventoryData data) => InventoryItem(
    id: data.id,
    childId: data.childId,
    itemId: data.itemId,
    isEquipped: data.isEquipped,
  );

  @override
  Future<void> syncShopData() async {
    try {
      final remoteItems = await remoteDataSource.getShopItems();
      final companions = remoteItems.map((json) => ShopItemsCompanion.insert(
        id: json['id'],
        name: json['name'],
        description: Value(json['description']),
        price: json['price'],
        unityId: json['unity_id'],
        category: Value(json['category'] ?? 'car'),
      )).toList();
      
      await localDb.upsertShopItems(companions);
    } catch (e) {
      // Erreur silencieuse en mode offline
    }
  }

  @override
  Future<List<ShopItem>> getShopItems() async {
    final items = await localDb.getAllShopItems();
    return items.map(_toEntity).toList();
  }

  @override
  Future<List<InventoryItem>> getChildInventory(String childId) async {
    try {
      final remoteInv = await remoteDataSource.getChildInventory(childId);
      for (var item in remoteInv) {
        await localDb.addInventoryItem(LocalInventoryCompanion.insert(
          id: item['id'],
          childId: item['child_id'],
          itemId: item['item_id'],
          isEquipped: Value(item['is_equipped'] ?? false),
        ));
      }
    } catch (e) {
      // Erreur silencieuse
    }
    
    final localInv = await localDb.getChildInventory(childId);
    return localInv.map(_toInventoryEntity).toList();
  }

  @override
  Future<void> purchaseItem(String childId, ShopItem item) async {
    await remoteDataSource.purchaseItem(childId, item.id);
    await syncShopData();
    await getChildInventory(childId);
  }

  @override
  Future<void> equipItem(String childId, String itemId) async {
    await localDb.equipItem(childId, itemId);
    try {
      await remoteDataSource.equipItem(childId, itemId);
    } catch (e) {
      // Sera synchronisé plus tard
    }
  }
}
