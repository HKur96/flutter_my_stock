class ProductSummary {
  final String id;
  final String name;
  final int currentStock;
  final int minimumStock;
  final double recommendedSellingPrice;

  const ProductSummary({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minimumStock,
    required this.recommendedSellingPrice,
  });

  bool get isLowStock => currentStock < minimumStock;

  ProductSummary copyWith({
    String? id,
    String? name,
    int? currentStock,
    int? minimumStock,
    double? recommendedSellingPrice,
  }) {
    return ProductSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      recommendedSellingPrice:
          recommendedSellingPrice ?? this.recommendedSellingPrice,
    );
  }
}
