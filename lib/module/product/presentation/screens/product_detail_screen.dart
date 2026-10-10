// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/utils/currency_formatter.dart';
import 'package:flutter_catat_stok/core/widgets/app_card.dart';
import 'package:flutter_catat_stok/core/widgets/app_dialog_confirmation.dart';
import 'package:flutter_catat_stok/module/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/stock/presentation/provider/stock_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/smooth_page_route.dart';
import '../../../stock/presentation/screens/stock_in_screen.dart';
import '../../../stock/presentation/screens/stock_out_screen.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product selectedProduct;

  const ProductDetailScreen({super.key, required this.selectedProduct});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final user = context.watch<AuthProvider>().user;
  final ScrollController _scrollController = ScrollController();

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<StockProvider>();
      if (provider.hasDetailMore &&
          !provider.isDetailLoadingMore &&
          !provider.isDetailLoading) {
        provider.getProductDetailLogs(
          productId: widget.selectedProduct.id,
          page: provider.detailCurrentPage + 1,
          limit: 10,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().selectedProduct = widget.selectedProduct;
      context.read<StockProvider>().getProductDetailLogs(
            productId: widget.selectedProduct.id,
            page: 1,
            limit: 10,
            isRefresh: true,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ProductProvider, Product?>(
      selector: (_, p) => p.selectedProduct,
      builder: (context, selectedProduct, _) {
        final p = selectedProduct ?? widget.selectedProduct;
        final buyPrice = p.purchasePrice.toDouble();
        final sellPrice = p.recommendedSellingPrice.toDouble();
        final margin = sellPrice - buyPrice;
        final marginPercent = buyPrice > 0
            ? ((margin / buyPrice) * 100).toInt()
            : 0;
        final totalStockValue = sellPrice * p.currentStock;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppbar(p),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Product Header Card (Match Stitch 09_detail_produk)
                _buildProductHeaderCard(
                  p,
                  buyPrice,
                  sellPrice,
                  margin,
                  marginPercent,
                  totalStockValue,
                ),
                const SizedBox(height: 14),

                // Quick Actions Row (Masuk, Keluar, Opname)
                _buildQuickActions(p),
                const SizedBox(height: 16),

                // Struktur Harga & Valuasi Card (Match Stitch 09_detail_produk)
                _buildPriceAndValuation(
                  p,
                  buyPrice,
                  sellPrice,
                  margin,
                  marginPercent,
                  totalStockValue,
                ),
                const SizedBox(height: 20),

                // Riwayat Stok Section (Match Stitch 09_detail_produk)
                _buildStockHistory(p),
                const SizedBox(height: 24),

                // Danger Option (Delete / Disable)
                _buildDeleteButton(p),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppbar(Product p) {
    return AppBar(
      title: const Text('Detail Produk'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              SmoothPageRoute(page: AddEditProductScreen(product: p)),
            );
          },
          child: const Text(
            'Ubah',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductHeaderCard(
    Product p,
    double buyPrice,
    double sellPrice,
    double margin,
    int marginPercent,
    double totalStockValue,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  p.categoryName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                'SKU: ${p.sku}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            p.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Fisik Tersedia',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${p.currentStock}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: p.isLowStock
                                ? AppColors.stockOut
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' ${p.unit}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.isLowStock
                          ? AppColors.stockOutBg
                          : AppColors.stockInBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      p.isLowStock ? '⚠️ Stok Menipis' : '✓ Stok Aman',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: p.isLowStock
                            ? AppColors.stockOut
                            : AppColors.stockIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Min. ${p.minimumStock} ${p.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Product p) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              SmoothPageRoute(page: StockInScreen(initialProduct: p)),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
              backgroundColor: AppColors.surfaceCard,
              foregroundColor: AppColors.stockIn,
              side: const BorderSide(color: AppColors.stockInBorder),
            ),
            icon: const Icon(Icons.south_west_rounded, size: 16),
            label: const Text('Masuk', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              SmoothPageRoute(page: StockOutScreen(initialProduct: p)),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
              foregroundColor: AppColors.stockOut,
              backgroundColor: AppColors.surfaceCard,
              side: const BorderSide(color: AppColors.stockOutBorder),
            ),
            icon: const Icon(Icons.north_east_rounded, size: 16),
            label: const Text('Keluar', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
              foregroundColor: AppColors.warning,
              backgroundColor: AppColors.surfaceCard,
              side: const BorderSide(color: AppColors.warningBorder),
            ),
            icon: const Icon(Icons.fact_check_outlined, size: 16),
            label: const Text('Opname', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndValuation(
    Product p,
    double buyPrice,
    double sellPrice,
    double margin,
    int marginPercent,
    double totalStockValue,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Struktur Harga & Valuasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'Satuan (${p.unit})',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harga Beli Rata-rata',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(buyPrice),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harga Jual Disarankan',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(sellPrice),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimasi Margin Satuan',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  Text(
                    CurrencyFormatter.format(margin),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.stockInBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+$marginPercent% untung',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.stockIn,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Nilai Stok',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${p.currentStock} ${p.unit} × ${CurrencyFormatter.format(sellPrice)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.format(totalStockValue),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockHistory(Product p) {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, _) {
        final productLogs = stockProvider.productDetailLogs;
        final isLoading = stockProvider.isDetailLoading;
        final isLoadingMore = stockProvider.isDetailLoadingMore;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Riwayat Stok',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Semua pergerakan barang untuk produk ini',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${productLogs.length} Mutasi',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoading && productLogs.isEmpty)
              const AppCard(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (productLogs.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'Belum ada riwayat mutasi untuk produk ini.',
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
                  itemCount: productLogs.length + (isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderSubtle),
                  itemBuilder: (context, index) {
                    if (index == productLogs.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final log = productLogs[index];
                    final isIn = log.productLogType == ProductLogType.stockIn;
                    final isOut = log.productLogType == ProductLogType.stockOut;

                    final Color pillBg = isIn
                        ? AppColors.stockInBg
                        : isOut
                        ? AppColors.stockOutBg
                        : AppColors.warningBg;
                    final Color pillTextColor = isIn
                        ? AppColors.stockIn
                        : isOut
                        ? AppColors.stockOut
                        : AppColors.warning;

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pillBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        log.productLogType.displayName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: pillTextColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormatter.dayHours(log.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (log.note ?? '').isEmpty
                                      ? (log.pic.isEmpty
                                            ? "Catatan Kasir"
                                            : log.pic)
                                      : log.note!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isIn
                                    ? "+"
                                    : isOut
                                    ? "-"
                                    : ""}${log.stockDifferent} ${p.unit}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: pillTextColor,
                                ),
                              ),
                            ],
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

  Widget _buildDeleteButton(Product p) {
    return Center(
      child: TextButton(
        onPressed: () => AppDialogConfirmation.show(
          context,
          title: 'Hapus Produk?',
          subtitle:
              'Apakah Anda yakin ingin menghapus produk ini dari katalog?',
          cancelText: 'Batal',
          confirmText: 'Hapus',
          onConfirm: () async {
            if (await context.read<ProductProvider>().deleteProduct(p.id)) {
              Navigator.of(context).pop();
            }
          },
        ),
        child: const Text(
          'Hapus Produk Dari Katalog',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.stockOut,
          ),
        ),
      ),
    );
  }
}
