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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi dotenv
  await _initializeEnv();

  // Inisialisasi Supabase SDK (jika URL dan Anon Key disetel)
  await SupabaseService.initialize();

  final AuthRepository authRepository = AuthRepositoryImpl();
  final ProductRepository productRepository = ProductRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository),
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    gNavigatorKey = _navigatorKey;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stok Saya',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
