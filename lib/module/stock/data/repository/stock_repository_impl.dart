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
    required String? searchQuery,
    required ProductLogType? filterType,
  }) async {
    try {
      // 1. Hitung range untuk pagination (Supabase menggunakan indeks berbasis 0)
      // Contoh: page 1, limit 10 -> from: 0, to: 9
      // Contoh: page 2, limit 10 -> from: 10, to: 19
      final int from = (page - 1) * limit;
      final int to = from + limit - 1;

      // 2. Mulai builder query ke tabel 'product_logs'
      // Anda juga bisa melakukan JOIN tabel relasi, misal: .select('*, products(name)')
      var query = Supabase.instance.client.from('product_logs').select();

      // 3. Terapkan Filtering (jika ada)
      if (filterType != null) {
        query = query.eq('action', filterType.name); // Contoh kolom: log_type
      }

      // 4. Terapkan Search Keyword (jika ada)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // .ilike digunakan untuk pencarian case-insensitive (tidak peduli huruf besar/kecil)
        // Simbol '%' diartikan mengandung kata kunci tersebut
        query = query.ilike('product_name', '%${searchQuery.trim()}%');
      }

      // 5. Urutkan berdasarkan waktu terbaru, lalu terapkan range pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

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
