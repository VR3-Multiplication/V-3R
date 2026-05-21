class ShopItem {
  final String id;
  final String name;
  final String? description;
  final int price;
  final String category;
  final String unityId;
  final String? imageUrl;

  const ShopItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    required this.unityId,
    this.imageUrl,
  });
}
