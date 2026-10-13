import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/core/services/local_storage_service.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product_summary.dart';
import 'package:flutter_catat_stok/module/product/domain/repository/product_repository.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';
import 'package:flutter_catat_stok/module/stock/presentation/provider/stock_provider.dart';
import 'package:provider/provider.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository;

  ProductProvider(this._productRepository);

  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;
  set selectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  int _productRequestId = 0;
  String? _productErrorDelegate;
  String? get productErrorDelegate => _productErrorDelegate;

  List<CategoryItem> _categories = [];
  List<Product> _products = [];
  List<Product> _productsDelegate = [];
  List<ProductSummary> _productsSummary = [];
  bool _isLoading = false;
  bool _isLoadingProduct = false;
  bool _isLoadingProductDelegate = false;
  bool _isLoadingProductSummary = false;
  bool _isLoadingMoreProduct = false;
  bool _isLoadingMoreProductDelegate = false;
  bool _hasMoreProduct = true;
  bool _hasMoreProductDelegate = false;
  int _currentProductPage = 1;
  int _currentProductDelegatePage = 1;

  List<CategoryItem> get categories => _categories;
  List<Product> get products => _products;
  List<Product> get productsDelegate => _productsDelegate;
  List<ProductSummary> get productsSummary => _productsSummary;
  bool get isLoading => _isLoading;
  bool get isLoadingProduct => _isLoadingProduct;
  bool get isLoadingProductDelegate => _isLoadingProductDelegate;
  bool get isLoadingProductSummary => _isLoadingProductSummary;
  bool get isLoadingMoreProduct => _isLoadingMoreProduct;
  bool get isLoadingMoreProductDelegate => _isLoadingMoreProductDelegate;
  bool get hasMoreProduct => _hasMoreProduct;
  bool get hasMoreProductDelegate => _hasMoreProductDelegate;
  int get currentProductPage => _currentProductPage;
  int get currentProductDelegatePage => _currentProductDelegatePage;

  // Products
  double get totalValue => _productsSummary.fold(
    0.0,
    (sum, item) => sum + (item.purchasePrice * item.currentStock),
  );

  double get totalValuePotential => _productsSummary.fold(
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

  Future<void> getCategories({bool isRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isRefresh && _categories.isNotEmpty) {
        _isLoading = false;
        print('[GetCategories] Categories is cached.');
        notifyListeners();
        return;
      }

      print('[GetCategories] Fetching categories from API...');
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

  Future<String?> uploadProductImage({
    required String filePath,
    required List<int> bytes,
  }) async {
    return await _productRepository.uploadProductImage(
      filePath: filePath,
      bytes: bytes,
    );
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
      final currentUser = await LocalStorageService().getUser();

      if (newProduct == null) {
        throw Exception('Gagal menambahkan produk');
      }

      gNavigatorKey.currentContext!.read<StockProvider>().updateProductLogs(
        ProductLog(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          productId: newProduct.id,
          productName: newProduct.name,
          imageUrl: newProduct.imageUrl,
          unit: newProduct.unit,
          productLogType: ProductLogType.create,
          pic: currentUser?.name ?? 'Unknown',
          oldData: {},
          newData: {'current_stock': newProduct.currentStock},
          createdAt: DateTime.now(),
          note:
              '${currentUser?.name} menambahkan produk ${newProduct.name} dengan stok awal ${newProduct.currentStock} ${newProduct.unit.name}',
        ),
      );

      _products = [newProduct, ..._products];
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

  Future<List<Product>> getProductDelegate({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    String? categoryId,
    bool isRefresh = false,
  }) async {
    final isFirstPage = isRefresh || page == 1;

    // Hanya load-more yang diblok saat ada request berjalan.
    // Request halaman pertama (search baru) selalu boleh, request lama jadi basi.
    if (!isFirstPage &&
        (_isLoadingProductDelegate || _isLoadingMoreProductDelegate)) {
      return _productsDelegate;
    }

    final requestId = ++_productRequestId;

    if (isFirstPage) {
      _isLoadingProductDelegate = true;
      _isLoadingMoreProductDelegate = false;
      _currentProductDelegatePage = 1;
      _hasMoreProductDelegate = true;
      _productErrorDelegate = null;
    } else {
      _isLoadingMoreProductDelegate = true;
    }
    notifyListeners();

    try {
      final response = await _productRepository.getProducts(
        page: page,
        limit: limit,
        searchQuery: searchQuery,
        categoryId: categoryId,
      );

      // Ada request yang lebih baru, abaikan hasil ini
      if (requestId != _productRequestId) return _productsDelegate;

      if (isFirstPage) {
        _productsDelegate = response;
      } else {
        _productsDelegate.addAll(response);
      }

      _currentProductDelegatePage = page;
      _hasMoreProductDelegate = response.length >= limit;
      return _productsDelegate;
    } catch (e) {
      if (requestId == _productRequestId) {
        _productErrorDelegate = 'Gagal memuat produk';
      }
      return _productsDelegate;
    } finally {
      if (requestId == _productRequestId) {
        _isLoadingProductDelegate = false;
        _isLoadingMoreProductDelegate = false;
        notifyListeners();
      }
    }
  }
}
