import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/stock/data/models/product_log_model.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';
import 'package:flutter_catat_stok/module/stock/domain/repository/stock_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockRepositoryImpl implements StockRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<ProductLog>> getProductLogs() async {
    try {
      final response = await _client.from('product_logs').select('*');

      return response.map((e) => ProductLogModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> stockIn() {
    // TODO: implement stockIn
    throw UnimplementedError();
  }

  @override
  Future<bool> stockOut() {
    // TODO: implement stockOut
    throw UnimplementedError();
  }
}
