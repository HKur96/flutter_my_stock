import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/module/orders/data/models/order_item_entity.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/picking_item_tile.dart';

class PickingScreen extends StatefulWidget {
  final OrderEntity? order;
  final Function(OrderItem item, int quantityPicked, PickingStatus status)? onItemPickingChanged;
  final VoidCallback? onCompletePickingAndUploadPhoto;
  final ValueChanged<OrderItem>? onReportItemIssue;

  const PickingScreen({
    super.key,
    this.order,
    this.onItemPickingChanged,
    this.onCompletePickingAndUploadPhoto,
    this.onReportItemIssue,
  });

  @override
  State<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  late OrderEntity _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order ?? MockOrderData.sampleActiveOrder;
  }

  void _markItemPicked(OrderItem item) {
    final newQty = item.isFullyPicked ? 0 : item.quantityRequired;
    final newStatus = item.isFullyPicked ? PickingStatus.pending : PickingStatus.picked;

    setState(() {
      final index = _order.items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        final updated = _order.items[index].copyWith(
          quantityPicked: newQty,
          pickingStatus: newStatus,
          pickedAt: newStatus == PickingStatus.picked ? DateTime.now() : null,
        );
        final newItems = List<OrderItem>.from(_order.items);
        newItems[index] = updated;
        _order = _order.copyWith(items: newItems);
      }
    });

    widget.onItemPickingChanged?.call(item, newQty, newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final items = _order.items;
    final pickedCount = _order.fullyPickedItemsCount;
    final totalCount = _order.totalItemsCount;
    final isAllPicked = _order.isAllItemsPicked;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sesi Picking #${_order.orderNumber}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_order.marketplace ?? "Marketplace"} • Antrean FIFO',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isAllPicked)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text(
                        'Pastikan seluruh barang sudah diambil sebelum memotret',
                        style: TextStyle(fontSize: 11, color: AppColors.warning),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isAllPicked
                      ? widget.onCompletePickingAndUploadPhoto
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selesaikan seluruh item terlebih dahulu.'),
                            ),
                          );
                        },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text(
                    'Ambil Foto Bukti Verifikasi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAllPicked ? AppColors.primary : AppColors.border,
                    foregroundColor: isAllPicked ? Colors.white : AppColors.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Progress Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progres: $pickedCount dari $totalCount Barang Selesai',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${(_order.pickingProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _order.pickingProgress,
                      backgroundColor: AppColors.surfaceContainer,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAllPicked ? AppColors.stockIn : AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Instructions / Location Guidance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.directions_walk, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tips: Ambil barang berurutan dari Rak A ke Rak C untuk rute tercepat.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Picking Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return PickingItemTile(
                  item: item,
                  itemNumber: index + 1,
                  totalItems: items.length,
                  onMarkPicked: () => _markItemPicked(item),
                  onReportIssue: () => widget.onReportItemIssue?.call(item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
