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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      purchasePrice: json['purchase_price'],
      recommendedSellingPrice: json['recommended_selling_price'],
      minimumStock: json['minimum_stock'],
      currentStock: json['current_stock'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'purchase_price': purchasePrice,
      'recommended_selling_price': recommendedSellingPrice,
      'minimum_stock': minimumStock,
      'current_stock': currentStock,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
