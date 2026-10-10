import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/module/stock/domain/dto/stock_transaction_dto.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';

abstract class StockRepository {
  Future<List<ProductLog>> getProductLogs({
    required int page,
    required int limit,
    String? searchQuery,
    ProductLogType? filterType,
    String? productId,
  });

  Future<bool> stockIn(StockTransactionDto dto);

  Future<bool> stockOut(StockTransactionDto dto);
}
