// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/extensions.dart';
import 'package:flutter_catat_stok/module/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/mock_data.dart';
import '../core/utils/smooth_page_route.dart';
import 'stock_in_screen.dart';
import 'stock_out_screen.dart';
import '../module/product/presentation/screens/add_edit_product_screen.dart';
import '../module/product/presentation/screens/manage_category_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDatas();
    });
  }

  Future<void> _loadDatas() async {
    await context.read<ProductProvider>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final lowStockItems = MockData.products.where((p) => p.isLowStock).toList();
    final recentTrx = MockData.transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDatas,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Header
                _buildAppHeader(),
                const SizedBox(height: 20),

                // KPI Overview Cards Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildKpiCard(
                      title: 'Total Produk',
                      value: '${MockData.products.length} SKU',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryLight,
                    ),
                    _buildKpiCard(
                      title: 'Stok Menipis',
                      value: '${lowStockItems.length} Item',
                      color: AppColors.warning,
                      bgColor: AppColors.warningBg,
                    ),
                    Consumer<ProductProvider>(
                      builder: (context, provider, _) {
                        return _buildKpiCard(
                          title: 'Total Kategori',
                          value: '${provider.categories.length} Kategori',
                          color: Colors.purple,
                          bgColor: Colors.purple.shade50,
                        );
                      },
                    ),
                    _buildKpiCard(
                      title: 'Transaksi Bulan Ini',
                      value: '${MockData.transactions.length + 18} Trx',
                      color: AppColors.stockIn,
                      bgColor: AppColors.stockInBg,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Action Buttons
                const Text(
                  'Aksi Cepat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Stok Masuk',
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.stockIn,
                        bgColor: AppColors.stockInBg,
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const StockInScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Stok Keluar',
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.stockOut,
                        bgColor: AppColors.stockOutBg,
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const StockOutScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Tambah Produk',
                        icon: Icons.add_box_outlined,
                        color: AppColors.primary,
                        bgColor: AppColors.primaryLight,
                        onTap: () {
                          final categories =
                              context.read<ProductProvider>().categories;
                          if (categories.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kategori masih kosong. Buat kategori terlebih dahulu.',
                                ),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                page: const ManageCategoryScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                page: const AddEditProductScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Kategori',
                        icon: Icons.grid_view_rounded,
                        color: Colors.purple,
                        bgColor: Colors.purple.shade50,
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const ManageCategoryScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Low Stock Alerts Section
                if (lowStockItems.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Peringatan Stok Menipis ⚠️',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (widget.onNavigateToTab != null) {
                            widget.onNavigateToTab!(1); // Go to Products tab
                          }
                        },
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lowStockItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = lowStockItems[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.imageUrl,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 44,
                                  height: 44,
                                  color: AppColors.inputBg,
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Sisa Stok: ${item.stock} ${item.unit} (Min. ${item.minStock})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.stockOut,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SmoothPageRoute(
                                    page: StockInScreen(initialProduct: item),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '+ Stok',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Recent Activities Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Transaksi Terkini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.onNavigateToTab != null) {
                          widget.onNavigateToTab!(3); // Go to History tab
                        }
                      },
                      child: const Text('Selengkapnya'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTrx.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final trx = recentTrx[index];
                    final isIn = trx.type == 'IN';
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isIn
                                  ? AppColors.stockInBg
                                  : AppColors.stockOutBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIn
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: isIn
                                  ? AppColors.stockIn
                                  : AppColors.stockOut,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trx.productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  trx.date,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isIn ? "+" : "-"}${trx.qty}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isIn
                                  ? AppColors.stockIn
                                  : AppColors.stockOut,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  provider.user?.name.initials ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang, 👋',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    provider.user?.name ?? 'Pengguna',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 26),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.stockOut,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(SmoothPageRoute(page: ManageCategoryScreen()));
              },
            ),
          ],
        );
      },
    );
  }
}
