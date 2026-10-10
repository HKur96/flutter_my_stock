import 'package:flutter_catat_stok/module/product/domain/models/product_summary.dart';

class ProductSummaryModel extends ProductSummary {
  const ProductSummaryModel({
    required super.id,
    required super.name,
    required super.currentStock,
    required super.recommendedSellingPrice,
    required super.minimumStock,
  });

  factory ProductSummaryModel.fromJson(Map<String, dynamic> map) {
    return ProductSummaryModel(
      id: map['id'],
      name: map['name'],
      currentStock: map['current_stock'],
      minimumStock: map['minimum_stock'],
      recommendedSellingPrice: map['recommended_selling_price'],
    );
  }
}
