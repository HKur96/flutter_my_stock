import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_status_badge.dart';

class ReadyCompletedOrderScreen extends StatelessWidget {
  final OrderEntity? order;
  final VoidCallback? onHandoverToCourier;
  final VoidCallback? onBackToHome;

  const ReadyCompletedOrderScreen({
    super.key,
    this.order,
    this.onHandoverToCourier,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final currentOrder = order ?? MockOrderData.sampleOrders[4];
    final isDone = currentOrder.status == OrderStatus.done;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isDone ? 'Pesanan Selesai' : 'Paket Siap Kirim',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: isDone
                ? ElevatedButton(
                    onPressed: onBackToHome ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Kembali ke Beranda'),
                  )
                : ElevatedButton.icon(
                    onPressed: onHandoverToCourier,
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: const Text(
                      'Sudah Diserahkan ke Kurir (Selesai)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.stockIn,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Status Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDone ? AppColors.stockInBg : const Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_circle : Icons.inventory_2,
                size: 64,
                color: isDone ? AppColors.stockIn : const Color(0xFF047857),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              isDone ? 'Pesanan Selesai & Terkirim!' : 'Paket Rapi & Menunggu Kurir',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '#${currentOrder.orderNumber} • ${currentOrder.marketplace ?? "Ekspedisi"}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            OrderStatusBadge(status: currentOrder.status),
            const SizedBox(height: 24),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildRow('Total Barang:', '${currentOrder.totalQuantityRequired} Pcs'),
                  const Divider(color: AppColors.border),
                  _buildRow('Jenis Produk:', '${currentOrder.totalItemsCount} Macam'),
                  const Divider(color: AppColors.border),
                  _buildRow(
                    'Status Mutasi Stok:',
                    isDone ? 'Otomatis Terpotong (Terjual)' : 'Akan dipotong saat diserahkan',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
