import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:intl/intl.dart';

class VerificationQueueScreen extends StatelessWidget {
  final List<OrderEntity>? orders;
  final ValueChanged<OrderEntity>? onVerifyOrder;
  final VoidCallback? onRefresh;

  const VerificationQueueScreen({
    super.key,
    this.orders,
    this.onVerifyOrder,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final allOrders = orders ?? MockOrderData.sampleOrders;
    final verificationOrders = allOrders
        .where((o) =>
            o.status == OrderStatus.waitingVerification ||
            o.status == OrderStatus.rePicking)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Antrean Verifikasi Foto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.sync, color: AppColors.primary),
            tooltip: 'Sinkronkan',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          onRefresh?.call();
        },
        child: verificationOrders.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_outlined, size: 56, color: AppColors.stockIn),
                    SizedBox(height: 12),
                    Text(
                      'Tidak Ada Pesanan Menunggu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Semua foto hasil picking sudah diverifikasi.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: verificationOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = verificationOrders[index];
                  final timeStr = DateFormat('HH:mm').format(order.updatedAt);
                  final photoUrl = order.latestVerification?.photoUrl;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: order.status == OrderStatus.waitingVerification
                            ? AppColors.warningBorder
                            : const Color(0xFFFFB4AB),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: order.status == OrderStatus.waitingVerification
                                    ? AppColors.warningBg
                                    : const Color(0xFFFFDAD6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status == OrderStatus.waitingVerification
                                    ? 'MENUNGGU VERIFIKASI'
                                    : 'SEDANG RE-PICKING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: order.status == OrderStatus.waitingVerification
                                      ? AppColors.warning
                                      : const Color(0xFFBA1A1A),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Masuk: $timeStr',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo preview
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 72,
                                height: 72,
                                color: AppColors.surfaceSubtle,
                                child: photoUrl != null
                                    ? Image.network(photoUrl, fit: BoxFit.cover)
                                    : const Icon(Icons.photo_camera, color: AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '#${order.orderNumber}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${order.marketplace ?? "Marketplace"} • ${order.totalItemsCount} SKU (${order.totalQuantityRequired} Pcs)',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Items: ${order.items.map((e) => e.nameSnapshot).take(2).join(", ")}...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => onVerifyOrder?.call(order),
                            icon: const Icon(Icons.fact_check_outlined, size: 16),
                            label: const Text('Periksa & Cocokkan Foto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
