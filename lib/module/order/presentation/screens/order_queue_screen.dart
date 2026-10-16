import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_card.dart';

class OrderQueueScreen extends StatefulWidget {
  final List<OrderEntity>? orders;
  final ValueChanged<OrderEntity>? onOrderTap;
  final VoidCallback? onAddOrder;
  final VoidCallback? onRefresh;

  const OrderQueueScreen({
    super.key,
    this.orders,
    this.onOrderTap,
    this.onAddOrder,
    this.onRefresh,
  });

  @override
  State<OrderQueueScreen> createState() => _OrderQueueScreenState();
}

class _OrderQueueScreenState extends State<OrderQueueScreen> {
  String _selectedTab = 'Semua Antrean';

  final List<String> _tabs = [
    'Semua Antrean',
    'Menunggu Pick',
    'Verifikasi',
    'Packing',
    'Siap Kirim',
  ];

  @override
  Widget build(BuildContext context) {
    final allOrders = widget.orders ?? MockOrderData.sampleOrders;

    final filteredOrders = allOrders.where((order) {
      if (_selectedTab == 'Menunggu Pick') {
        return order.status == OrderStatus.queued || order.status == OrderStatus.picking;
      } else if (_selectedTab == 'Verifikasi') {
        return order.status == OrderStatus.waitingVerification ||
            order.status == OrderStatus.rePicking;
      } else if (_selectedTab == 'Packing') {
        return order.status == OrderStatus.packing;
      } else if (_selectedTab == 'Siap Kirim') {
        return order.status == OrderStatus.ready;
      }
      return order.status != OrderStatus.done && order.status != OrderStatus.cancelled;
    }).toList();

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
        actions: [
          IconButton(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.sync, color: AppColors.primary),
            tooltip: 'Sinkronkan',
          ),
        ],
      ),
      floatingActionButton: widget.onAddOrder != null
          ? FloatingActionButton.extended(
              onPressed: widget.onAddOrder,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Input Pesanan'),
            )
          : null,
      body: Column(
        children: [
          // Filter horizontal tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceSubtle,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTab = tab;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                widget.onRefresh?.call();
              },
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 48, color: AppColors.stockIn),
                          const SizedBox(height: 12),
                          const Text(
                            'Semua Antrean Bersih!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tidak ada pesanan menunggu pada filter ini.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          if (widget.onAddOrder != null) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: widget.onAddOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Tambah Pesanan Baru'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return OrderCard(
                          order: order,
                          onTap: () => widget.onOrderTap?.call(order),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
