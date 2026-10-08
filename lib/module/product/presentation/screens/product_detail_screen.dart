// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/utils/currency_formatter.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/smooth_page_route.dart';
import '../../../../screens/stock_in_screen.dart';
import '../../../../screens/stock_out_screen.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: AddEditProductScreen(product: product)),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(
                      page: StockInScreen(initialProduct: product),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.stockIn,
                ),
                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                label: const Text('Stok Masuk'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(
                      page: StockOutScreen(initialProduct: product),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.stockOut,
                ),
                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                label: const Text('Stok Keluar'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image Container
            // Center(
            //   child: Container(
            //     width: double.infinity,
            //     height: 220,
            //     decoration: BoxDecoration(
            //       color: AppColors.surface,
            //       borderRadius: BorderRadius.circular(20),
            //       border: Border.all(color: AppColors.border),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black.withOpacity(0.04),
            //           blurRadius: 12,
            //           offset: const Offset(0, 4),
            //         ),
            //       ],
            //     ),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(20),
            //       child: Image.network(
            //         product.imageUrl,
            //         fit: BoxFit.cover,
            //         errorBuilder: (_, __, ___) => const Icon(
            //           Icons.inventory_2_outlined,
            //           size: 80,
            //           color: AppColors.textMuted,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),

            // Category & Low Stock Tag Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.categoryName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: product.isLowStock
                        ? AppColors.stockOutBg
                        : AppColors.stockInBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.isLowStock ? '⚠️ Stok Menipis' : '✓ Stok Aman',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: product.isLowStock
                          ? AppColors.stockOut
                          : AppColors.stockIn,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Name & SKU
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${product.sku}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Current Stock Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jumlah Stok Saat Ini',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${product.currentStock}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: product.isLowStock
                                  ? AppColors.stockOut
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.unit,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Minimum Stok',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.minimumStock} ${product.unit}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pricing Info Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Beli',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(product.purchasePrice.toDouble()),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Jual',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(product.recommendedSellingPrice.toDouble()),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description Box
            const Text(
              'Deskripsi Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                product.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
