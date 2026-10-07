import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  /// Supabase Project URL dari .env atau --dart-define
  static String get url {
    final envUrl = dotenv.env['SUPABASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    return const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
  }

  /// Supabase Anon Public Key dari .env atau --dart-define
  static String get anonKey {
    final envKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
  }

  /// Memeriksa apakah konfigurasi Supabase sudah diisi dengan benar
  static bool get isConfigured {
    final u = url;
    final k = anonKey;
    return u.startsWith('https://') &&
        !u.contains('YOUR_SUPABASE_PROJECT_URL') &&
        k.length > 20 &&
        !k.contains('YOUR_SUPABASE_ANON_KEY');
  }
}
