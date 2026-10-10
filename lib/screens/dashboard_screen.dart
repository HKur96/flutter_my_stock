// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/extensions.dart';
import 'package:flutter_catat_stok/core/utils/currency_formatter.dart';
import 'package:flutter_catat_stok/module/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';
import 'package:flutter_catat_stok/module/stock/presentation/provider/stock_provider.dart';
import 'package:flutter_catat_stok/module/stock/presentation/screens/stock_opname_screen.dart';
import 'package:provider/provider.dart';
import '../core/config/enum.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/smooth_page_route.dart';
import '../core/widgets/app_card.dart';
import '../module/stock/presentation/screens/stock_in_screen.dart';
import '../module/stock/presentation/screens/stock_out_screen.dart';

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
    await Future.wait([
      context.read<ProductProvider>().getCategories(),
      context.read<ProductProvider>().getProducts(),
      context.read<StockProvider>().getProductLogs(
        page: 1,
        limit: 5,
        searchQuery: '',
        filterType: null,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDatas,
          child: SingleChildScrollView(
            key: const PageStorageKey('dashboard_screen'),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Header (Title "Beranda" & Profile Avatar)
                _buildHeader(),
                const SizedBox(height: 16),

                // Card Estimasi Nilai Stok (Match Stitch 11_beranda)
                _buildStockValueCard(),
                const SizedBox(height: 16),

                // Action Buttons Row (Stok Masuk, Stok Keluar, Opname)
                _buildActionButtonsRow(),
                const SizedBox(height: 20),

                // Stok Menipis Section (Match Stitch 11_beranda)
                _buildLowStockSection(),
                const SizedBox(height: 20),

                // Aktivitas Terakhir Section (Match Stitch 11_beranda)
                _buildRecentActivitiesSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthProvider>().user;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Beranda',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          child: Text(
            user?.name.initials ?? 'U',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockValueCard() {
    return Selector<ProductProvider, List<Product>>(
      selector: (_, p) => p.products,
      builder: (context, products, _) {
        final double totalValue = products.fold(
          0.0,
          (sum, item) =>
              sum + (item.recommendedSellingPrice * item.currentStock),
        );
        final int totalItemsCount = products.fold(
          0,
          (sum, item) => sum + item.currentStock,
        );

        return AppCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimasi Nilai Stok',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(totalValue),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderSubtle),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Produk',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${products.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: AppColors.borderSubtle,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Barang',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalItemsCount pcs',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtonsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Stok Masuk',
            icon: Icons.south_west_rounded,
            iconColor: AppColors.stockIn,
            onTap: () => Navigator.push(
              context,
              SmoothPageRoute(page: const StockInScreen()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            label: 'Stok Keluar',
            icon: Icons.north_east_rounded,
            iconColor: AppColors.stockOut,
            onTap: () => Navigator.push(
              context,
              SmoothPageRoute(page: const StockOutScreen()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            label: 'Opname',
            icon: Icons.fact_check_outlined,
            iconColor: AppColors.warning,
            onTap: () => Navigator.push(
              context,
              SmoothPageRoute(page: StockOpnameScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: 14,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection() {
    return Selector<ProductProvider, List<Product>>(
      selector: (_, p) => p.lowStockItems,
      builder: (context, lowStockItems, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stok Menipis (${lowStockItems.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToTab != null)
                      widget.onNavigateToTab!(1);
                  },
                  child: const Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (lowStockItems.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'Semua stok barang tersedia aman.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              )
            else
              AppCard(
                padding: EdgeInsets.zero,
                borderRadius: 16,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lowStockItems.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderSubtle),
                  itemBuilder: (context, index) {
                    final item = lowStockItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.categoryName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Sisa ${item.currentStock}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warning,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / Min ${item.minimumStock}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Selector<StockProvider, List<ProductLog>>(
      selector: (_, p) => p.productLogs,
      builder: (context, logs, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToTab != null)
                      widget.onNavigateToTab!(2);
                  },
                  child: const Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (logs.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'Belum ada aktivitas stok.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              )
            else
              AppCard(
                padding: EdgeInsets.zero,
                borderRadius: 16,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderSubtle),
                  itemBuilder: (context, index) {
                    final item = logs[index];
                    final isIn = item.productLogType == ProductLogType.stockIn;
                    final isOut =
                        item.productLogType == ProductLogType.stockOut;

                    final Color iconBg = isIn
                        ? AppColors.stockInBg
                        : isOut
                        ? AppColors.stockOutBg
                        : AppColors.warningBg;
                    final Color iconColor = isIn
                        ? AppColors.stockIn
                        : isOut
                        ? AppColors.stockOut
                        : AppColors.warning;
                    final IconData iconData = isIn
                        ? Icons.south_west_rounded
                        : isOut
                        ? Icons.north_east_rounded
                        : Icons.fact_check_outlined;

                    final String qtyText = isIn
                        ? '+${item.stockDifferent} pcs'
                        : isOut
                        ? '-${item.stockDifferent} pcs'
                        : '${item.stockDifferent > 0 ? "+" : ""}${item.stockDifferent} pcs';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(iconData, color: iconColor, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormatter.dayHours(item.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            qtyText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
