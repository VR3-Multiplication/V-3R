import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/shop_providers.dart';
import '../providers/translation_providers.dart';
import '../../domain/entities/shop_item.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopItemsAsync = ref.watch(shopItemsProvider);
    final inventoryAsync = ref.watch(childInventoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1B),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 150,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            title: Text(
              tr(ref, 'garage_title'),
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            actions: [
              _buildStarCounter(ref).animate().fadeIn(delay: 300.ms).scale(),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Choisis ton bolide pour la prochaine mission !',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ).animate().fadeIn(delay: 500.ms),
            ),
          ),
          shopItemsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, s) => SliverFillRemaining(child: Center(child: Text('Erreur: $e', style: const TextStyle(color: Colors.white)))),
            data: (items) => inventoryAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, s) => SliverFillRemaining(child: Center(child: Text('Erreur: $e'))),
              data: (inventory) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // Look "Card large" pour plus de Wow
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        final isOwned = inventory.any((inv) => inv.itemId == item.id);
                        final isEquipped = inventory.any((inv) => inv.itemId == item.id && inv.isEquipped);
                        
                        return _buildCarCard(context, ref, item, isOwned, isEquipped)
                            .animate()
                            .fadeIn(delay: (index * 100).ms)
                            .slideY(begin: 0.2);
                      },
                      childCount: items.length,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarCounter(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade800]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 10)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: 24),
          SizedBox(width: 6),
          Text(
            '150', // Placeholder
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, WidgetRef ref, ShopItem item, bool isOwned, bool isEquipped) {
    final carColor = _getCarColor(item.unityId);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: isEquipped ? carColor : Colors.white10,
          width: isEquipped ? 3 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Background Glow
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: carColor.withValues(alpha: 0.2),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 3.seconds),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Image
                  Expanded(
                    flex: 2,
                    child: Hero(
                      tag: 'car_${item.id}',
                      child: Icon(Icons.directions_car_filled_rounded, size: 80, color: carColor)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut),
                    ),
                  ),
                  
                  // Infos
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description ?? '',
                          style: const TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        _buildButton(ref, item, isOwned, isEquipped, carColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(WidgetRef ref, ShopItem item, bool isOwned, bool isEquipped, Color color) {
    if (isEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text('ÉQUIPÉ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      );
    }

    if (isOwned) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
        onPressed: () => ref.read(childInventoryProvider.notifier).equipItem(item.id),
        child: const Text('ÉQUIPER'),
      );
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
      icon: const Icon(Icons.star_rounded, size: 18),
      label: Text('${item.price} ÉTOILES', style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () => ref.read(childInventoryProvider.notifier).purchaseItem(item),
    );
  }

  Color _getCarColor(String unityId) {
    if (unityId.contains('red')) return const Color(0xFFFF1744);
    if (unityId.contains('blue')) return const Color(0xFF2979FF);
    if (unityId.contains('green')) return const Color(0xFF00E676);
    if (unityId.contains('yellow')) return const Color(0xFFFFEA00);
    return Colors.grey;
  }
}
