import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product_summary.dart';

abstract class ProductRepository {
  Future<List<CategoryItem>> getCategories();

  Future<CategoryItem?> addCategory({required String name});

  Future<CategoryItem?> updateCategoryName({
    required String id,
    required String name,
    required List<Product> products,
  });

  Future<bool> deleteCategory(String id);

  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    String? categoryId,
  });

  Future<List<ProductSummary>> getProductsSummary();

  Future<Product?> addProduct({required Product product});

  Future<bool> deleteProduct(String id);

  Future<Product?> updateProduct({required Product product});
}
