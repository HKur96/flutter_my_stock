import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/product/data/models/unit_item_model.dart';
import 'package:flutter_catat_stok/module/product/domain/models/unit_item.dart';
import 'package:flutter_catat_stok/module/product/domain/repository/unit_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UnitRepositoryImpl implements UnitRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<UnitItem>> getUnits() async {
    try {
      final res = await _client
          .from('units')
          .select()
          .order('name', ascending: true);

      return res.map<UnitItem>((json) => UnitItemModel.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> addUnit(String name, {String? description}) async {
    final newId = 'unit_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = UnitItem(
      id: newId,
      name: name.trim(),
      description: description?.trim(),
    );

    try {
      await _client.from('units').insert(newItem.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteUnit(String id) async {
    try {
      await _client.from('units').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
