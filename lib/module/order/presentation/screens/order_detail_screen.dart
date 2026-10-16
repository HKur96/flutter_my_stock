import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_status_badge.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_timeline_tile.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderEntity? order;
  final VoidCallback? onStartPicking;
  final VoidCallback? onVerifyPhoto;
  final VoidCallback? onPacking;
  final VoidCallback? onHandoverCourier;
  final VoidCallback? onEditOrder;
  final VoidCallback? onCancelOrder;
  final VoidCallback? onViewTimeline;

  const OrderDetailScreen({
    super.key,
    this.order,
    this.onStartPicking,
    this.onVerifyPhoto,
    this.onPacking,
    this.onHandoverCourier,
    this.onEditOrder,
    this.onCancelOrder,
    this.onViewTimeline,
  });

  @override
  Widget build(BuildContext context) {
    final currentOrder = order ?? MockOrderData.sampleActiveOrder;
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm').format(currentOrder.createdAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Detail Pesanan #${currentOrder.orderNumber}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (currentOrder.status != OrderStatus.done &&
              currentOrder.status != OrderStatus.cancelled)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') onEditOrder?.call();
                if (val == 'cancel') onCancelOrder?.call();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Pesanan'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Batalkan Pesanan', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(currentOrder),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentOrder.marketplace ?? 'Marketplace Order',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#${currentOrder.orderNumber}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      OrderStatusBadge(status: currentOrder.status),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCol('Waktu Masuk', dateStr),
                      _buildInfoCol('Versi Sistem', 'v${currentOrder.version}'),
                      if (currentOrder.queuePosition != null)
                        _buildInfoCol('Antrean', '#${currentOrder.queuePosition}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Customer Note if available
            if (currentOrder.customerNote != null &&
                currentOrder.customerNote!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2, size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Catatan Pembeli:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentOrder.customerNote!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 3. Items Checklist Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Barang (${currentOrder.items.length} SKU • ${currentOrder.totalQuantityRequired} Pcs)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${currentOrder.fullyPickedItemsCount}/${currentOrder.totalItemsCount} Siap',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 4. Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentOrder.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = currentOrder.items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      // Photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: AppColors.surfaceSubtle,
                          child: item.photoSnapshot != null
                              ? Image.network(
                                  item.photoSnapshot!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 20,
                                    color: AppColors.textMuted,
                                  ),
                                )
                              : const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nameSnapshot,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.skuSnapshot} • ${item.variantSnapshot ?? "Standar"}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Lokasi: ${item.locationSnapshot}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Qty
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.quantityPicked} / ${item.quantityRequired} Pcs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: item.isFullyPicked
                                  ? AppColors.stockIn
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            item.isFullyPicked
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: item.isFullyPicked
                                ? AppColors.stockIn
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 5. Activity Timeline Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Pesanan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onViewTimeline != null)
                  TextButton(
                    onPressed: onViewTimeline,
                    child: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (currentOrder.events.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentOrder.events.take(3).length,
                itemBuilder: (context, index) {
                  final ev = currentOrder.events[index];
                  final isLast = index == currentOrder.events.take(3).length - 1;
                  return OrderTimelineTile(event: ev, isLast: isLast);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomActionBar(OrderEntity order) {
    if (order.status == OrderStatus.queued && onStartPicking != null) {
      return _buildBottomBarContainer(
        ElevatedButton.icon(
          onPressed: onStartPicking,
          icon: const Icon(Icons.shopping_basket_outlined),
          label: const Text('Mulai Ambil Barang (Picking)'),
          style: _primaryButtonStyle,
        ),
      );
    } else if (order.status == OrderStatus.waitingVerification && onVerifyPhoto != null) {
      return _buildBottomBarContainer(
        ElevatedButton.icon(
          onPressed: onVerifyPhoto,
          icon: const Icon(Icons.verified_outlined),
          label: const Text('Buka Layar Verifikasi Foto'),
          style: _primaryButtonStyle,
        ),
      );
    } else if (order.status == OrderStatus.verified && onPacking != null) {
      return _buildBottomBarContainer(
        ElevatedButton.icon(
          onPressed: onPacking,
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Mulai Packing Paket'),
          style: _primaryButtonStyle,
        ),
      );
    } else if (order.status == OrderStatus.ready && onHandoverCourier != null) {
      return _buildBottomBarContainer(
        ElevatedButton.icon(
          onPressed: onHandoverCourier,
          icon: const Icon(Icons.local_shipping_outlined),
          label: const Text('Serahkan Paket ke Kurir'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.stockIn,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }
    return null;
  }

  Widget _buildBottomBarContainer(Widget child) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: child,
        ),
      ),
    );
  }

  ButtonStyle get _primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );

  Widget _buildInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
