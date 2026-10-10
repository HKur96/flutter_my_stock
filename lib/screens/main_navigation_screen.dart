import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/product/presentation/screens/manage_category_screen.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/smooth_page_route.dart';
import 'dashboard_screen.dart';
import '../module/product/presentation/screens/product_list_screen.dart';
import '../module/stock/presentation/screens/history_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialTab;

  const MainNavigationScreen({super.key, this.initialTab = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCategories();
    });
  }

  Future<void> _checkCategories() async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.getCategories();
    if (!mounted) return;
    if (productProvider.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan buat kategori terlebih dahulu karena produk membutuhkan kategori.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      Navigator.of(context).pushReplacement(
        SmoothPageRoute(
          page: const ManageCategoryScreen(type: PickCategoryType.initial),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        onNavigateToTab: (idx) => setState(() => _currentIndex = idx),
      ),
      const ProductListScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  Icons.home_rounded,
                  Icons.home_outlined,
                  'Beranda',
                ),
                _buildNavItem(
                  1,
                  Icons.inventory_2_rounded,
                  Icons.inventory_2_outlined,
                  'Produk',
                ),
                _buildNavItem(
                  2,
                  Icons.history_rounded,
                  Icons.history_outlined,
                  'Riwayat',
                ),
                _buildNavItem(
                  3,
                  Icons.person_rounded,
                  Icons.person_outline_rounded,
                  'Akun',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
