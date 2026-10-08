import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/domain/repository/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository;

  ProductProvider(this._productRepository);

  List<CategoryItem> _categories = [];
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingProduct = false;

  List<CategoryItem> get categories => _categories;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingProduct => _isLoadingProduct;

  List<String> get categoriesChipFilter => [
    'Semua',
    ...categories.map((x) => x.name),
  ];

  List<Product> get lowStockItems {
    if (_isLoadingProduct) return [];
    return _products.where((x) => x.isLowStock).toList();
  }

  Future<void> getCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _productRepository.getCategories();
      _categories = response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory({required String name}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _productRepository.addCategory(name: name);
      if (response != null) {
        _categories = [response, ..._categories];
      }
      notifyListeners();

      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil ditambahkan!'),
          backgroundColor: AppColors.stockIn,
        ),
      );
    } catch (e) {
      showFlashError('Tidak dapat menambahkan kategori');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productRepository.deleteCategory(id);
      _categories = _categories.where((x) => x.id != id).toList();
      ScaffoldMessenger.of(
        gNavigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Kategori dihapus')));
    } catch (e) {
      ScaffoldMessenger.of(
        gNavigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus kategori')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategoryName({required CategoryItem category}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _productRepository.updateCategoryName(
        id: category.id,
        name: category.name,
        products: category.products,
      );
      if (response != null) {
        _categories = _categories
            .map((x) => x.id == category.id ? response : x)
            .toList();
      }
      notifyListeners();

      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil diupdate!'),
          backgroundColor: AppColors.stockIn,
        ),
      );
    } catch (e) {
      showFlashError('Tidak dapat mengupdate kategori');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> getProducts() async {
    _isLoadingProduct = true;
    notifyListeners();

    try {
      final response = await _productRepository.getProducts();
      _products = response;
      notifyListeners();
      return response;
    } catch (e) {
      return [];
    } finally {
      _isLoadingProduct = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct({required Product product}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newProduct = await _productRepository.addProduct(product: product);

      if (newProduct == null) {
        throw Exception('Gagal menambahkan produk');
      }

      _products = [..._products, newProduct];
      notifyListeners();

      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan!'),
          backgroundColor: AppColors.stockIn,
        ),
      );
      return true;
    } catch (e) {
      showFlashError('Tidak dapat menambahkan produk');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String categoryId,
    required int stock,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productRepository.updateProduct(
        id: id,
        name: name,
        categoryId: categoryId,
        stock: stock,
      );
      notifyListeners();
      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil diupdate!'),
          backgroundColor: AppColors.stockIn,
        ),
      );
    } catch (e) {
      showFlashError('Tidak dapat mengupdate produk');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
