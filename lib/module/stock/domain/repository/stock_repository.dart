import 'package:flutter_catat_stok/module/stock/domain/dto/stock_transaction_dto.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';

abstract class StockRepository {
  Future<List<ProductLog>> getProductLogs();

  Future<bool> stockIn(StockTransactionDto dto);

  Future<bool> stockOut(StockTransactionDto dto);
}
