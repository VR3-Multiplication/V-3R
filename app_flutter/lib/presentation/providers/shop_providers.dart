import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/shop_item.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../data/datasources/shop_remote_data_source.dart';
import '../../data/repositories/shop_repository_impl.dart';
import '../../domain/usecases/get_shop_items_usecase.dart';
import '../../domain/usecases/get_child_inventory_usecase.dart';
import '../../domain/usecases/purchase_item_usecase.dart';
import '../../domain/usecases/equip_item_usecase.dart';
import 'auth_providers.dart';
import 'local_database_provider.dart';

final shopRemoteDataSourceProvider = Provider<ShopRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ShopRemoteDataSourceImpl(supabaseClient: client);
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final remote = ref.watch(shopRemoteDataSourceProvider);
  final local = ref.watch(localDatabaseProvider);
  return ShopRepositoryImpl(remoteDataSource: remote, localDb: local);
});

// Use Cases Providers
final getShopItemsUseCaseProvider = Provider<GetShopItemsUseCase>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return GetShopItemsUseCase(repo);
});

final getChildInventoryUseCaseProvider = Provider<GetChildInventoryUseCase>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return GetChildInventoryUseCase(repo);
});

final purchaseItemUseCaseProvider = Provider<PurchaseItemUseCase>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return PurchaseItemUseCase(repo);
});

final equipItemUseCaseProvider = Provider<EquipItemUseCase>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return EquipItemUseCase(repo);
});

// FutureProvider pour la liste des articles de la boutique
final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  final useCase = ref.watch(getShopItemsUseCaseProvider);
  return await useCase.execute();
});

class ShopInventoryNotifier extends StateNotifier<AsyncValue<List<InventoryItem>>> {
  final GetChildInventoryUseCase _getInventoryUseCase;
  final PurchaseItemUseCase _purchaseUseCase;
  final EquipItemUseCase _equipUseCase;
  final String _childId;

  ShopInventoryNotifier({
    required GetChildInventoryUseCase getInventoryUseCase,
    required PurchaseItemUseCase purchaseUseCase,
    required EquipItemUseCase equipUseCase,
    required String childId,
  })  : _getInventoryUseCase = getInventoryUseCase,
        _purchaseUseCase = purchaseUseCase,
        _equipUseCase = equipUseCase,
        _childId = childId,
        super(const AsyncValue.loading()) {
    if (_childId.isNotEmpty) {
      loadInventory();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadInventory() async {
    state = const AsyncValue.loading();
    try {
      final list = await _getInventoryUseCase.execute(_childId);
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> purchaseItem(ShopItem item) async {
    if (_childId.isEmpty) return;
    try {
      await _purchaseUseCase.execute(_childId, item);
      await loadInventory();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> equipItem(String itemId) async {
    if (_childId.isEmpty) return;
    try {
      await _equipUseCase.execute(_childId, itemId);
      state.whenData((list) {
        state = AsyncValue.data(list.map((item) {
          return item.copyWith(isEquipped: item.itemId == itemId);
        }).toList());
      });
    } catch (e) {
      rethrow;
    }
  }
}

// StateNotifierProvider pour l'inventaire de l'enfant
final childInventoryProvider = StateNotifierProvider<ShopInventoryNotifier, AsyncValue<List<InventoryItem>>>((ref) {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  return ShopInventoryNotifier(
    getInventoryUseCase: ref.watch(getChildInventoryUseCaseProvider),
    purchaseUseCase: ref.watch(purchaseItemUseCaseProvider),
    equipUseCase: ref.watch(equipItemUseCaseProvider),
    childId: userId ?? '',
  );
});
