import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/stock/data/models/product_log_model.dart';
import 'package:flutter_catat_stok/module/stock/domain/dto/stock_transaction_dto.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';
import 'package:flutter_catat_stok/module/stock/domain/repository/stock_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockRepositoryImpl implements StockRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<ProductLog>> getProductLogs() async {
    try {
      final response = await _client
          .from('product_logs')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((e) => ProductLogModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> stockIn(StockTransactionDto dto) async {
    try {
      await _client.rpc(
        'stock_in',
        params: {
          'p_product_id': dto.productId,
          'p_quantity': dto.quantity,
          'p_purchase_price': dto.purchasePrice ?? 0,
          'p_note': dto.note,
        },
      );
      return true;
    } catch (e, s) {
      print('err stock in $e\n$s');
      return false;
    }
  }

  @override
  Future<bool> stockOut(StockTransactionDto dto) async {
    try {
      await _client.rpc(
        'stock_out',
        params: {
          'p_product_id': dto.productId,
          'p_quantity': dto.quantity,
          'p_reason': dto.reason ?? 'Stock Keluar',
          'p_note': dto.note,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
