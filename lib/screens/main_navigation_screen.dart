import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/product/presentation/screens/manage_category_screen.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/smooth_page_route.dart';
import 'dashboard_screen.dart';
import '../module/product/presentation/screens/product_list_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'stock_in_screen.dart';
import 'stock_out_screen.dart';
import '../module/product/presentation/screens/add_edit_product_screen.dart';

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

  void _showQuickActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Aksi Cepat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const StockInScreen()),
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.stockInBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.stockIn,
                  ),
                ),
                title: const Text(
                  'Catat Stok Masuk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Tambah jumlah stok barang baru diterima'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
              const Divider(height: 1),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const StockOutScreen()),
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.stockOutBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.stockOut,
                  ),
                ),
                title: const Text(
                  'Catat Stok Keluar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Kurangi stok karena penjualan / rusak'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
              const Divider(height: 1),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  final categories = context.read<ProductProvider>().categories;
                  if (categories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Buat kategori terlebih dahulu sebelum menambah produk.',
                        ),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                    Navigator.push(
                      context,
                      SmoothPageRoute(page: const ManageCategoryScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      SmoothPageRoute(page: const AddEditProductScreen()),
                    );
                  }
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_box_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'Tambah Produk Baru',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Daftarkan SKU & barang baru ke katalog'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        );
      },
    );
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: screens[_currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'main_nav_fab',
        onPressed: _showQuickActionSheet,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
            const SizedBox(width: 40), // Space for FloatingActionButton
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
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
