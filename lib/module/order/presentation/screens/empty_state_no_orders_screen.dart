import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';

class EmptyStateNoOrdersScreen extends StatelessWidget {
  final VoidCallback? onAddOrder;
  final VoidCallback? onRefresh;
  final bool isOwner;

  const EmptyStateNoOrdersScreen({
    super.key,
    this.onAddOrder,
    this.onRefresh,
    this.isOwner = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Antrean Pesanan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration circular badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Antrean Pesanan Kosong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tidak ada pesanan aktif yang perlu diproses saat ini. Semua barang telah terselesaikan atau belum ada order baru masuk.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 32),

              if (isOwner && onAddOrder != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onAddOrder,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Input Pesanan Marketplace',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (onRefresh != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Tarik Refresh Data Terbaru'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
