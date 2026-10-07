import 'package:flutter/foundation.dart';
import 'package:flutter_catat_stok/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'Supabase client belum diinisialisasi. Pastikan URL dan Anon Key sudah diisi di SupabaseConfig.',
      );
    }
    return Supabase.instance.client;
  }

  /// Inisialisasi Supabase SDK
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint(
        '⚠️ [SupabaseService] Konfigurasi Supabase (URL / Anon Key) belum disetel. Menggunakan Mock/Local Repository Mode.',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      _isInitialized = true;
      debugPrint('✅ [SupabaseService] Berhasil terhubung ke Supabase!');
    } catch (e) {
      debugPrint('❌ [SupabaseService] Gagal inisialisasi Supabase: $e');

      _isInitialized = false;
    }
  }
}
