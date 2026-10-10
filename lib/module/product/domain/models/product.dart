import 'package:flutter_catat_stok/core/config/enum.dart';

class Product {
  final String id;
  final String name;
  final String sku;
  final UnitType unit;
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
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sku == other.sku &&
          unit == other.unit &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          purchasePrice == other.purchasePrice &&
          recommendedSellingPrice == other.recommendedSellingPrice &&
          minimumStock == other.minimumStock &&
          currentStock == other.currentStock &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          description == other.description;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        sku,
        unit,
        categoryId,
        categoryName,
        purchasePrice,
        recommendedSellingPrice,
        minimumStock,
        currentStock,
        isActive,
        createdAt,
        updatedAt,
        description,
      );
}
