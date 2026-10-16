import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_summary.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_card.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_pipeline_scroller.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final OrderPipelineSummary? summary;
  final List<OrderEntity>? orders;
  final VoidCallback? onRefresh;
  final ValueChanged<OrderEntity>? onOrderTap;
  final VoidCallback? onOpenVerificationQueue;
  final VoidCallback? onOpenPackingQueue;

  const OwnerDashboardScreen({
    super.key,
    this.summary,
    this.orders,
    this.onRefresh,
    this.onOrderTap,
    this.onOpenVerificationQueue,
    this.onOpenPackingQueue,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  OrderStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary ?? MockOrderData.sampleSummary;
    final allOrders = widget.orders ?? MockOrderData.sampleOrders;

    final displayedOrders = _selectedStatusFilter == null
        ? allOrders
        : allOrders.where((o) => o.status == _selectedStatusFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Text(
              'Toko Utama (Pusat)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.sync, color: AppColors.primary),
            tooltip: 'Sinkronisasi Realtime',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Notifikasi',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          widget.onRefresh?.call();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Operational Pipeline Scroller (9 statuses)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PIPELINE FULFILLMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${summary.totalActiveOrders} Pesanan Aktif',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              OrderPipelineScroller(
                summary: summary,
                selectedStatus: _selectedStatusFilter,
                onStatusSelected: (status) {
                  setState(() {
                    _selectedStatusFilter = status;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 3. Order List Header & Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedStatusFilter != null
                          ? 'Pesanan ${_selectedStatusFilter!.label}'
                          : 'Daftar Pesanan Terkini',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_selectedStatusFilter != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedStatusFilter = null;
                          });
                        },
                        child: const Text(
                          'Reset Filter',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 4. Orders List
              if (displayedOrders.isEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada pesanan pada status ini',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayedOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = displayedOrders[index];
                    return OrderCard(
                      order: order,
                      onTap: () {
                        widget.onOrderTap?.call(order);
                      },
                      primaryActionLabel:
                          order.status == OrderStatus.waitingVerification
                          ? 'Verifikasi Foto'
                          : 'Detail',
                      onPrimaryAction: () {
                        widget.onOrderTap?.call(order);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
