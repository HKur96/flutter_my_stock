import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_card.dart';

class PackingQueueScreen extends StatelessWidget {
  final List<OrderEntity>? orders;
  final ValueChanged<OrderEntity>? onPackingOrder;
  final VoidCallback? onRefresh;

  const PackingQueueScreen({
    super.key,
    this.orders,
    this.onPackingOrder,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final allOrders = orders ?? MockOrderData.sampleOrders;
    final packingOrders = allOrders
        .where((o) => o.status == OrderStatus.verified || o.status == OrderStatus.packing)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Antrean Packing',
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
        child: packingOrders.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.stockIn),
                    SizedBox(height: 12),
                    Text(
                      'Tidak Ada Antrean Packing',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Semua pesanan yang terverifikasi sudah dipacking.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: packingOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = packingOrders[index];
                  return OrderCard(
                    order: order,
                    primaryActionLabel: order.status == OrderStatus.packing
                        ? 'Lanjut Packing'
                        : 'Mulai Packing',
                    onPrimaryAction: () => onPackingOrder?.call(order),
                    onTap: () => onPackingOrder?.call(order),
                  );
                },
              ),
      ),
    );
  }
}
