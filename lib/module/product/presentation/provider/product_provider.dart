import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product_summary.dart';
import 'package:flutter_catat_stok/module/product/domain/repository/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository;

  ProductProvider(this._productRepository);

  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;
  set selectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  List<CategoryItem> _categories = [];
  List<Product> _products = [];
  List<ProductSummary> _productsSummary = [];
  bool _isLoading = false;
  bool _isLoadingProduct = false;
  bool _isLoadingProductSummary = false;
  bool _isLoadingMoreProduct = false;
  bool _hasMoreProduct = true;
  int _currentProductPage = 1;

  List<CategoryItem> get categories => _categories;
  List<Product> get products => _products;
  List<ProductSummary> get productsSummary => _productsSummary;
  bool get isLoading => _isLoading;
  bool get isLoadingProduct => _isLoadingProduct;
  bool get isLoadingProductSummary => _isLoadingProductSummary;
  bool get isLoadingMoreProduct => _isLoadingMoreProduct;
  bool get hasMoreProduct => _hasMoreProduct;
  int get currentProductPage => _currentProductPage;

  // Products
  double get totalValue => _productsSummary.fold(
    0.0,
    (sum, item) => sum + (item.recommendedSellingPrice * item.currentStock),
  );
  int get totalItemsCount =>
      _productsSummary.fold(0, (sum, item) => sum + item.currentStock);

  List<String> get categoriesChipFilter => [
    'Semua',
    ...categories.map((x) => x.name),
  ];

  List<ProductSummary> get lowStockItems {
    if (_isLoadingProduct) return [];
    return _productsSummary.where((x) => x.isLowStock).toList();
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

  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    String? categoryId,
    bool isRefresh = false,
  }) async {
    if (_isLoadingProduct || _isLoadingMoreProduct) return _products;

    if (isRefresh || page == 1) {
      _isLoadingProduct = true;
      _currentProductPage = 1;
      _hasMoreProduct = true;
    } else {
      _isLoadingMoreProduct = true;
    }
    notifyListeners();

    try {
      final response = await _productRepository.getProducts(
        page: page,
        limit: limit,
        searchQuery: searchQuery,
        categoryId: categoryId,
      );

      if (isRefresh || page == 1) {
        _products = response;
      } else {
        _products.addAll(response);
      }

      _currentProductPage = page;
      _hasMoreProduct = response.length >= limit;
      return _products;
    } catch (e) {
      return [];
    } finally {
      _isLoadingProduct = false;
      _isLoadingMoreProduct = false;
      notifyListeners();
    }
  }

  Future<List<ProductSummary>> getProductsSummary() async {
    _isLoadingProductSummary = true;
    notifyListeners();
    try {
      final response = await _productRepository.getProductsSummary();
      _productsSummary = response;
      notifyListeners();
      return response;
    } catch (e) {
      return [];
    } finally {
      _isLoadingProductSummary = false;
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

  Future<bool> updateProduct({required Product product}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _productRepository.updateProduct(product: product);

      if (response == null) {
        throw Exception('Gagal mengupdate produk');
      }

      _selectedProduct = response;
      _products = _products
          .map((x) => x.id == product.id ? response : x)
          .toList();
      notifyListeners();

      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil diupdate!'),
          backgroundColor: AppColors.stockIn,
        ),
      );
      return true;
    } catch (e) {
      showFlashError('Tidak dapat mengupdate produk');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _productRepository.deleteProduct(id);
      if (!res) {
        throw 'Tidak dapat menghapus produk';
      }

      _products = _products.where((x) => x.id != id).toList();
      notifyListeners();

      ScaffoldMessenger.of(
        gNavigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Produk berhasil dihapus')));
      return true;
    } catch (e) {
      showFlashError('Tidak dapat menghapus produk');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
