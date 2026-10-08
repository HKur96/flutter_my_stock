import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';
import 'package:flutter_catat_stok/module/stock/domain/repository/stock_repository.dart';

class StockProvider with ChangeNotifier {
  final StockRepository _stockRepository;
  StockProvider(this._stockRepository);

  List<ProductLog> _productLogs = [];
  bool _isLoading = false;

  List<ProductLog> get productLogs => _productLogs;
  bool get isLoading => _isLoading;

  Future<void> getProductLogs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _stockRepository.getProductLogs();

      _productLogs = response;
    } catch (e) {
      showFlashError("Terjadi kesalahan saat mendapatkan data riwayat stok");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
