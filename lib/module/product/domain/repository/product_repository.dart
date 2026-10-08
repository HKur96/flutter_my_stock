import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';

abstract class ProductRepository {
  Future<List<CategoryItem>> getCategories();

  Future<CategoryItem?> addCategory({required String name});

  Future<CategoryItem?> updateCategoryName({
    required String id,
    required String name,
    required List<Product> products,
  });

  Future<bool> deleteCategory(String id);

  Future<List<Product>> getProducts();

  Future<Product?> addProduct({required Product product});

  Future<bool> deleteProduct(String id);

  Future<Product?> updateProduct({
    required String id,
    required String name,
    required String categoryId,
    required int stock,
  });
}
