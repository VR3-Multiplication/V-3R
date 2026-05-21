class InventoryItem {
  final String id;
  final String childId;
  final String itemId;
  final bool isEquipped;

  const InventoryItem({
    required this.id,
    required this.childId,
    required this.itemId,
    required this.isEquipped,
  });

  InventoryItem copyWith({
    String? id,
    String? childId,
    String? itemId,
    bool? isEquipped,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      itemId: itemId ?? this.itemId,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
