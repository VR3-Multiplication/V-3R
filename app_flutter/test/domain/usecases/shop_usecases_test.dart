import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/shop_item.dart';
import 'package:app_flutter/domain/entities/inventory_item.dart';
import 'package:app_flutter/domain/repositories/shop_repository.dart';
import 'package:app_flutter/domain/usecases/get_shop_items_usecase.dart';
import 'package:app_flutter/domain/usecases/get_child_inventory_usecase.dart';
import 'package:app_flutter/domain/usecases/purchase_item_usecase.dart';
import 'package:app_flutter/domain/usecases/equip_item_usecase.dart';

class MockShopRepository implements ShopRepository {
  final List<ShopItem> items = [];
  final Map<String, List<InventoryItem>> inventory = {};
  bool syncCalled = false;

  @override
  Future<void> syncShopData() async {
    syncCalled = true;
  }

  @override
  Future<List<ShopItem>> getShopItems() async {
    return items;
  }

  @override
  Future<List<InventoryItem>> getChildInventory(String childId) async {
    return inventory[childId] ?? [];
  }

  @override
  Future<void> purchaseItem(String childId, ShopItem item) async {
    final newItem = InventoryItem(
      id: 'inv-${item.id}',
      childId: childId,
      itemId: item.id,
      isEquipped: false,
    );
    inventory.putIfAbsent(childId, () => []).add(newItem);
  }

  @override
  Future<void> equipItem(String childId, String itemId) async {
    final list = inventory[childId] ?? [];
    inventory[childId] = list.map((item) {
      return item.copyWith(isEquipped: item.itemId == itemId);
    }).toList();
  }
}

void main() {
  late MockShopRepository mockRepository;

  setUp(() {
    mockRepository = MockShopRepository();
  });

  group('Shop Use Cases', () {
    test('GetShopItemsUseCase doit synchroniser et retourner les items de la boutique', () async {
      mockRepository.items.add(const ShopItem(id: 'i1', name: 'Car', description: 'Red Car', price: 10, category: 'cars', unityId: 'red_car'));
      final useCase = GetShopItemsUseCase(mockRepository);
      
      final result = await useCase.execute();
      
      expect(mockRepository.syncCalled, true);
      expect(result.length, 1);
      expect(result.first.name, 'Car');
    });

    test('GetChildInventoryUseCase doit retourner l\'inventaire de l\'enfant', () async {
      mockRepository.inventory['child-1'] = [
        const InventoryItem(id: 'inv1', childId: 'child-1', itemId: 'i1', isEquipped: true),
      ];
      final useCase = GetChildInventoryUseCase(mockRepository);
      
      final result = await useCase.execute('child-1');
      
      expect(result.length, 1);
      expect(result.first.isEquipped, true);
    });

    test('PurchaseItemUseCase doit acheter l\'objet', () async {
      final useCase = PurchaseItemUseCase(mockRepository);
      const item = ShopItem(id: 'i1', name: 'Car', description: 'Red Car', price: 10, category: 'cars', unityId: 'red_car');
      
      await useCase.execute('child-1', item);
      
      expect(mockRepository.inventory['child-1']?.length, 1);
      expect(mockRepository.inventory['child-1']?.first.itemId, 'i1');
    });

    test('EquipItemUseCase doit équiper l\'objet et déséquiper les autres', () async {
      mockRepository.inventory['child-1'] = [
        const InventoryItem(id: 'inv1', childId: 'child-1', itemId: 'i1', isEquipped: true),
        const InventoryItem(id: 'inv2', childId: 'child-1', itemId: 'i2', isEquipped: false),
      ];
      final useCase = EquipItemUseCase(mockRepository);
      
      await useCase.execute('child-1', 'i2');
      
      final items = mockRepository.inventory['child-1']!;
      expect(items.firstWhere((i) => i.itemId == 'i1').isEquipped, false);
      expect(items.firstWhere((i) => i.itemId == 'i2').isEquipped, true);
    });
  });
}
