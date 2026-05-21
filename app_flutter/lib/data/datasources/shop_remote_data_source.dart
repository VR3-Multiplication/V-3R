import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ShopRemoteDataSource {
  Future<List<Map<String, dynamic>>> getShopItems();
  Future<List<Map<String, dynamic>>> getChildInventory(String childId);
  Future<void> purchaseItem(String childId, String itemId);
  Future<void> equipItem(String childId, String itemId);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final SupabaseClient supabaseClient;

  ShopRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getShopItems() async {
    final response = await supabaseClient.from('shop_items').select();
    return (response as List).map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getChildInventory(String childId) async {
    final response = await supabaseClient
        .from('child_inventory')
        .select()
        .eq('child_id', childId);
    return (response as List).map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> purchaseItem(String childId, String itemId) async {
    // 1. On vérifie le prix et les étoiles de l'enfant
    // (Dans un vrai projet, on ferait ça via une fonction RPC pour la sécurité)
    
    // 2. Ajouter à l'inventaire
    await supabaseClient.from('child_inventory').insert({
      'child_id': childId,
      'item_id': itemId,
      'is_equipped': false,
    });
  }

  @override
  Future<void> equipItem(String childId, String itemId) async {
    // On passe tout à false
    await supabaseClient
        .from('child_inventory')
        .update({'is_equipped': false})
        .eq('child_id', childId);
    
    // On passe l'item à true
    await supabaseClient
        .from('child_inventory')
        .update({'is_equipped': true})
        .eq('child_id', childId)
        .eq('item_id', itemId);
  }
}
