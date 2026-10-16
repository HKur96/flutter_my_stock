import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/module/orders/data/models/order_item_entity.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/picking_item_tile.dart';

class RePickingScreen extends StatelessWidget {
  final OrderEntity? order;
  final VoidCallback? onUploadNewPhoto;
  final ValueChanged<OrderItem>? onRePickItem;

  const RePickingScreen({
    super.key,
    this.order,
    this.onUploadNewPhoto,
    this.onRePickItem,
  });

  @override
  Widget build(BuildContext context) {
    final currentOrder = order ?? MockOrderData.sampleOrders[2];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Re-picking #${currentOrder.orderNumber}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFBA1A1A),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onUploadNewPhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Kirim Foto Ulang ke Owner',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Re-picking Instruction Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB4AB)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.replay_circle_filled, color: Color(0xFFBA1A1A), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KOREKSI TARGET RE-PICKING',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Color(0xFFBA1A1A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Anda hanya perlu menukar barang yang ditandai merah di bawah. Barang yang sudah centang hijau TIDAK PERLU diambil ulang.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF410002)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Items list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentOrder.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = currentOrder.items[index];
                final isNeedRePick = index == 1; // Demo: item ke-2 butuh re-pick

                return PickingItemTile(
                  item: item,
                  itemNumber: index + 1,
                  totalItems: currentOrder.items.length,
                  isRePick: isNeedRePick,
                  onMarkPicked: () => onRePickItem?.call(item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
