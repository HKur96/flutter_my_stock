import 'package:flutter_catat_stok/module/product/data/models/product_model.dart';
import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';

class CategoryItemModel extends CategoryItem {
  CategoryItemModel({
    required super.id,
    required super.name,
    required super.products,
  });

  factory CategoryItemModel.fromJson(Map<String, dynamic> json) =>
      CategoryItemModel(
        id: json['id'],
        name: json['name'],
        products: json['products']
            .map<Product>(
              (x) => ProductModel.fromJson(x as Map<String, dynamic>),
            )
            .toList(),
      );
}
