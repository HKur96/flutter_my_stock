import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';

abstract class ProductRepository {
  Future<List<CategoryItem>> getCategories();

  Future<CategoryItem?> addCategory({required String name});

  Future<CategoryItem?> updateCategoryName({
    required String id,
    required String name,
    required List<Product> products
  });

  Future<bool> deleteCategory(String id);
}
