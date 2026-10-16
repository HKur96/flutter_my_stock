import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  final List<OrderEntity>? orders;
  final ValueChanged<OrderEntity>? onOrderTap;
  final VoidCallback? onRefresh;

  const OrderHistoryScreen({
    super.key,
    this.orders,
    this.onOrderTap,
    this.onRefresh,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = widget.orders ?? MockOrderData.sampleOrders;
    final query = _searchController.text.trim().toLowerCase();

    final filtered = allOrders.where((o) {
      final matchesSearch = query.isEmpty ||
          o.orderNumber.toLowerCase().contains(query) ||
          (o.marketplace?.toLowerCase().contains(query) ?? false);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Selesai') {
        return o.status == OrderStatus.done;
      } else if (_selectedFilter == 'Dibatalkan') {
        return o.status == OrderStatus.cancelled;
      }
      return o.status == OrderStatus.done || o.status == OrderStatus.cancelled;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Pesanan',
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
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari no. pesanan atau marketplace...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Semua', 'Selesai', 'Dibatalkan'].map((f) {
                    final isSelected = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceSubtle,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = f);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                widget.onRefresh?.call();
              },
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text('Belum ada riwayat pesanan', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = filtered[index];
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
