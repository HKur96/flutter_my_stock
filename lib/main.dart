import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/auth/data/repository/auth_repository_impl.dart';
import 'package:flutter_catat_stok/module/auth/domain/repository/auth_repository.dart';
import 'package:flutter_catat_stok/module/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_catat_stok/module/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_catat_stok/module/product/data/repository/product_repository_impl.dart';
import 'package:flutter_catat_stok/module/product/domain/repository/product_repository.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/stock/data/repository/stock_repository_impl.dart';
import 'package:flutter_catat_stok/module/stock/domain/repository/stock_repository.dart';
import 'package:flutter_catat_stok/module/stock/presentation/provider/stock_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'package:flutter_catat_stok/module/product/data/repository/unit_repository_impl.dart';
import 'package:flutter_catat_stok/module/product/domain/repository/unit_repository.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/unit_provider.dart';
import 'package:flutter_catat_stok/module/settings/data/repository/store_settings_repository_impl.dart';
import 'package:flutter_catat_stok/module/settings/domain/repository/store_settings_repository.dart';
import 'package:flutter_catat_stok/module/settings/presentation/provider/store_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable overlay notification Chucker (bug layout di v1.9.2).
  // Buka Chucker via shake gesture atau navigasi manual.
  ChuckerFlutter.showNotification = false;

  await initializeDateFormatting('id_ID', null);

  // Inisialisasi dotenv
  await _initializeEnv();

  // Inisialisasi Supabase SDK (jika URL dan Anon Key disetel)
  await SupabaseService.initialize();

  final AuthRepository authRepository = AuthRepositoryImpl();
  final ProductRepository productRepository = ProductRepositoryImpl();
  final StockRepository stockRepository = StockRepositoryImpl();
  final StoreSettingsRepository storeSettingsRepository =
      StoreSettingsRepositoryImpl();
  final UnitRepository unitRepository = UnitRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => StockProvider(stockRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreSettingsProvider(storeSettingsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UnitProvider(unitRepository),
        ),
      ],
      child: const StokSayaApp(),
    ),
  );
}

Future<void> _initializeEnv() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Failsafe jika .env tidak ditemukan saat testing
  }
}

class StokSayaApp extends StatefulWidget {
  const StokSayaApp({super.key});

  @override
  State<StokSayaApp> createState() => _StokSayaAppState();
}

class _StokSayaAppState extends State<StokSayaApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stok Saya',
      navigatorKey: gNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
