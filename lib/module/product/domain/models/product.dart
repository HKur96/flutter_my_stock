class Product {
  final String id;
  final String name;
  final String sku;
  final String unit;
  final String categoryId;
  final String categoryName;
  final num purchasePrice;
  final num recommendedSellingPrice;
  final int minimumStock;
  final int currentStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    required this.purchasePrice,
    required this.categoryId,
    required this.categoryName,
    required this.recommendedSellingPrice,
    required this.minimumStock,
    required this.currentStock,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.description,
  });

  bool get isLowStock => currentStock < minimumStock;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'recommended_selling_price': recommendedSellingPrice,
      'minimum_stock': minimumStock,
      'current_stock': currentStock,
      'is_active': isActive,
      'description': description,
      'unit': unit,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
