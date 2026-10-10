import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.purchasePrice,
    required super.recommendedSellingPrice,
    required super.minimumStock,
    required super.currentStock,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.categoryId,
    required super.categoryName,
    required super.unit,
    required super.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final cat = json['categories'];
    String catId = json['category_id']?.toString() ?? '';
    String catName = json['category_name']?.toString() ?? '';

    if (cat is Map<String, dynamic>) {
      if (catId.isEmpty && cat['id'] != null) {
        catId = cat['id'].toString();
      }
      if (catName.isEmpty && cat['name'] != null) {
        catName = cat['name'].toString();
      }
    }

    String unitVal = json['unit']?.toString() ?? '';
    if (unitVal.trim().isEmpty) {
      unitVal = 'Pcs';
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      unit: UnitType.fromValue(json['unit'].toString().trim()),
      categoryId: catId,
      categoryName: catName,
      purchasePrice: json['purchase_price'] ?? 0,
      recommendedSellingPrice: json['recommended_selling_price'] ?? 0,
      minimumStock: json['minimum_stock'] ?? 0,
      currentStock: json['current_stock'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      description: json['description'] ?? '',
    );
  }
}
