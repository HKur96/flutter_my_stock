import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';

abstract class StockRepository {
  Future<List<ProductLog>> getProductLogs();

  Future<bool> stockIn();

  Future<bool> stockOut();
}
