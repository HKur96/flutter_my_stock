import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/stock/data/models/product_log_model.dart';
import 'package:flutter_catat_stok/module/stock/domain/dto/stock_transaction_dto.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';
import 'package:flutter_catat_stok/module/stock/domain/repository/stock_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockRepositoryImpl implements StockRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<ProductLog>> getProductLogs({
    required int page,
    required int limit,
    String? searchQuery,
    ProductLogType? filterType,
    String? productId,
  }) async {
    try {
      final int from = (page - 1) * limit;
      final int to = from + limit - 1;

      var query = _client.from('product_logs').select();

      // 1. Filter berdasarkan productId (jika ada)
      if (productId != null && productId.trim().isNotEmpty) {
        query = query.eq('product_id', productId.trim());
      }

      // 2. Terapkan Filtering aksi/tipe log (jika ada)
      if (filterType != null && filterType != ProductLogType.all) {
        final actionStr = switch (filterType) {
          ProductLogType.stockIn => 'stock_in',
          ProductLogType.stockOut => 'stock_out',
          ProductLogType.update => 'update',
          ProductLogType.create => 'create',
          ProductLogType.delete => 'delete',
          _ => null,
        };
        if (actionStr != null) {
          query = query.ilike('action', '%$actionStr%');
        }
      }

      // 3. Terapkan Search Keyword (jika ada)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        query = query.or('product_name.ilike.%$q%,pic.ilike.%$q%,note.ilike.%$q%');
      }

      // 4. Urutkan berdasarkan waktu terbaru, lalu terapkan range pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((e) => ProductLogModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
    } catch (e) {
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
