class Product {
  final String id;
  final String name;
  final String sku;
  final num purchasePrice;
  final num recommendedSellingPrice;
  final int minimumStock;
  final int currentStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.purchasePrice,
    required this.recommendedSellingPrice,
    required this.minimumStock,
    required this.currentStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
