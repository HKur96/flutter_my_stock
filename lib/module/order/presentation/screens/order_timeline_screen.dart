import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_event_entity.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_timeline_tile.dart';

class OrderTimelineScreen extends StatelessWidget {
  final OrderEntity? order;
  final List<OrderEvent>? events;

  const OrderTimelineScreen({
    super.key,
    this.order,
    this.events,
  });

  @override
  Widget build(BuildContext context) {
    final currentOrder = order ?? MockOrderData.sampleActiveOrder;
    final eventList = events ?? currentOrder.events;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Timeline #${currentOrder.orderNumber}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_toggle_off, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Trail #${currentOrder.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${currentOrder.marketplace ?? "Marketplace"} • Versi v${currentOrder.version}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Jejak Perjalanan Pesanan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (eventList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Belum ada log aktivitas untuk pesanan ini.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: eventList.length,
                itemBuilder: (context, index) {
                  final ev = eventList[index];
                  final isLast = index == eventList.length - 1;
                  return OrderTimelineTile(event: ev, isLast: isLast);
                },
              ),
          ],
        ),
      ),
    );
  }
}
