import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter/domain/entities/shop_item.dart';
import 'package:app_flutter/domain/entities/inventory_item.dart';
import 'package:app_flutter/domain/repositories/shop_repository.dart';
import 'package:app_flutter/domain/usecases/get_child_inventory_usecase.dart';
import 'package:app_flutter/domain/usecases/purchase_item_usecase.dart';
import 'package:app_flutter/domain/usecases/equip_item_usecase.dart';
import 'package:app_flutter/presentation/providers/shop_providers.dart';

class MockShopRepository implements ShopRepository {
  final List<InventoryItem> inventory = [
    const InventoryItem(id: 'inv1', childId: 'child-123', itemId: 'item-1', isEquipped: false),
  ];

  @override
  Future<void> syncShopData() async {}

  @override
  Future<List<ShopItem>> getShopItems() async => [];

  @override
  Future<List<InventoryItem>> getChildInventory(String childId) async {
    return inventory.where((item) => item.childId == childId).toList();
  }

  @override
  Future<void> purchaseItem(String childId, ShopItem item) async {
    inventory.add(InventoryItem(id: 'inv-${item.id}', childId: childId, itemId: item.id, isEquipped: false));
  }

  @override
  Future<void> equipItem(String childId, String itemId) async {
    for (var i = 0; i < inventory.length; i++) {
      if (inventory[i].childId == childId) {
        inventory[i] = inventory[i].copyWith(isEquipped: inventory[i].itemId == itemId);
      }
    }
  }
}

void main() {
  late MockShopRepository mockRepository;
  late GetChildInventoryUseCase getChildInventoryUseCase;
  late PurchaseItemUseCase purchaseItemUseCase;
  late EquipItemUseCase equipItemUseCase;

  setUp(() {
    mockRepository = MockShopRepository();
    getChildInventoryUseCase = GetChildInventoryUseCase(mockRepository);
    purchaseItemUseCase = PurchaseItemUseCase(mockRepository);
    equipItemUseCase = EquipItemUseCase(mockRepository);
  });

  group('ShopInventoryNotifier', () {
    test('doit charger l\'inventaire au demarrage si childId est non vide', () async {
      final notifier = ShopInventoryNotifier(
        getInventoryUseCase: getChildInventoryUseCase,
        purchaseUseCase: purchaseItemUseCase,
        equipUseCase: equipItemUseCase,
        childId: 'child-123',
      );

      await Future.delayed(Duration.zero);
      expect(notifier.state.value?.length, 1);
      expect(notifier.state.value?.first.itemId, 'item-1');
    });

    test('doit acheter un objet et recharger l\'inventaire', () async {
      final notifier = ShopInventoryNotifier(
        getInventoryUseCase: getChildInventoryUseCase,
        purchaseUseCase: purchaseItemUseCase,
        equipUseCase: equipItemUseCase,
        childId: 'child-123',
      );

      await Future.delayed(Duration.zero);
      const item = ShopItem(id: 'item-2', name: 'Car 2', description: 'Blue Car', price: 20, category: 'cars', unityId: 'blue_car');
      await notifier.purchaseItem(item);
      expect(notifier.state.value?.length, 2);
      expect(notifier.state.value?.last.itemId, 'item-2');
    });

    test('doit equiper un objet et modifier son etat local', () async {
      final notifier = ShopInventoryNotifier(
        getInventoryUseCase: getChildInventoryUseCase,
        purchaseUseCase: purchaseItemUseCase,
        equipUseCase: equipItemUseCase,
        childId: 'child-123',
      );

      await Future.delayed(Duration.zero);
      await notifier.equipItem('item-1');
      expect(notifier.state.value?.first.isEquipped, true);
    });
  });
}
