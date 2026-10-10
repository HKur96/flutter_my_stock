import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/stock/domain/dto/stock_transaction_dto.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';
import 'package:flutter_catat_stok/module/stock/domain/repository/stock_repository.dart';

class StockProvider with ChangeNotifier {
  final StockRepository _stockRepository;
  StockProvider(this._stockRepository);

  // Main Product Logs (HistoryScreen & DashboardScreen)
  List<ProductLog> _productLogs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  List<ProductLog> get productLogs => _productLogs;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  // Product Detail Logs (ProductDetailScreen)
  List<ProductLog> _productDetailLogs = [];
  bool _isDetailLoading = false;
  bool _isDetailLoadingMore = false;
  bool _hasDetailMore = true;
  int _detailCurrentPage = 1;

  List<ProductLog> get productDetailLogs => _productDetailLogs;
  bool get isDetailLoading => _isDetailLoading;
  bool get isDetailLoadingMore => _isDetailLoadingMore;
  bool get hasDetailMore => _hasDetailMore;
  int get detailCurrentPage => _detailCurrentPage;

  Future<void> getProductLogs({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    ProductLogType? filterType,
    bool isRefresh = false,
  }) async {
    if (_isLoading || _isLoadingMore) return;

    if (isRefresh || page == 1) {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await _stockRepository.getProductLogs(
        page: page,
        limit: limit,
        searchQuery: searchQuery,
        filterType: filterType,
      );

      if (isRefresh || page == 1) {
        _productLogs = response;
      } else {
        _productLogs.addAll(response);
      }

      _currentPage = page;
      _hasMore = response.length >= limit;
    } catch (e) {
      showFlashError("Terjadi kesalahan saat mendapatkan data riwayat stok");
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> getProductDetailLogs({
    required String productId,
    int page = 1,
    int limit = 10,
    bool isRefresh = false,
  }) async {
    if (_isDetailLoading || _isDetailLoadingMore) return;

    if (isRefresh || page == 1) {
      _isDetailLoading = true;
      _detailCurrentPage = 1;
      _hasDetailMore = true;
    } else {
      _isDetailLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await _stockRepository.getProductLogs(
        page: page,
        limit: limit,
        productId: productId,
      );

      if (isRefresh || page == 1) {
        _productDetailLogs = response;
      } else {
        _productDetailLogs.addAll(response);
      }

      _detailCurrentPage = page;
      _hasDetailMore = response.length >= limit;
    } catch (e) {
      showFlashError("Terjadi kesalahan saat mendapatkan riwayat stok produk");
    } finally {
      _isDetailLoading = false;
      _isDetailLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> stockIn(StockTransactionDto dto) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _stockRepository.stockIn(dto);

      if (!response) {
        throw Exception("Gagal menambahkan stok");
      }

      await getProductLogs(page: 1, limit: 10, isRefresh: true);

      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Stok masuk berhasil!'),
          backgroundColor: AppColors.stockIn,
        ),
      );

      return response;
    } catch (e) {
      showFlashError('Gagal menambahkan stok');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> stockOut(StockTransactionDto dto) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _stockRepository.stockOut(dto);

      if (!response) {
        throw Exception("Gagal mengurangi stok");
      }

      await getProductLogs(page: 1, limit: 10, isRefresh: true);

      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Stok keluar berhasil!'),
          backgroundColor: AppColors.stockOut,
        ),
      );

      return response;
    } catch (e) {
      showFlashError('Gagal mengurangi stok');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
