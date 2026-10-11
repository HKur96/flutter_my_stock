import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/settings/domain/models/store_settings.dart';
import 'package:flutter_catat_stok/module/settings/domain/repository/store_settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreSettingsRepositoryImpl implements StoreSettingsRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<StoreSettings?> getStoreSettings() async {
    try {
      final res = await _client
          .from('store_settings')
          .select()
          .limit(1)
          .maybeSingle();

      return StoreSettings.fromJson(res ?? {});
    } catch (_) {
      return const StoreSettings(
        id: '',
        storeName: 'Warung Saya',
        address: '',
        phoneNumber: '',
        headerFooterNote: '',
      );
    }
  }

  @override
  Future<bool> saveStoreSettings(StoreSettings settings) async {
    try {
      if (settings.id.isNotEmpty) {
        await _client
            .from('store_settings')
            .update(settings.toJson())
            .eq('id', settings.id);
      } else {
        // Cek dulu apakah tabel sudah ada data
        final existing = await _client
            .from('store_settings')
            .select('id')
            .limit(1)
            .maybeSingle();

        if (existing != null) {
          final id = existing['id'] as String;
          await _client
              .from('store_settings')
              .update(settings.toJson())
              .eq('id', id);
        } else {
          await _client.from('store_settings').insert(settings.toJson());
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
