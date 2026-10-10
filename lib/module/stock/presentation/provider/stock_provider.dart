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

  List<ProductLog> _productLogs = [];
  bool _isLoading = false;

  List<ProductLog> get productLogs => _productLogs;
  bool get isLoading => _isLoading;

  Future<void> getProductLogs({
    required int page,
    required int limit,
    required String? searchQuery,
    required ProductLogType? filterType,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _stockRepository.getProductLogs(
        page: page,
        limit: limit,
        searchQuery: searchQuery,
        filterType: filterType,
      );

      _productLogs = response;
    } catch (e) {
      showFlashError("Terjadi kesalahan saat mendapatkan data riwayat stok");
    } finally {
      _isLoading = false;
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

      await getProductLogs();

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

      await getProductLogs();

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
