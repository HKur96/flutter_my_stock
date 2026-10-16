import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/extensions.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/core/widgets/app_card.dart';
import 'package:flutter_catat_stok/core/widgets/app_circle_avatar.dart';
import 'package:flutter_catat_stok/core/widgets/app_shimmer.dart';
import 'package:flutter_catat_stok/core/widgets/app_text_field.dart';
import 'package:flutter_catat_stok/core/widgets/empty_state_widget.dart';
import 'package:flutter_catat_stok/module/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/module/orders/presentation/provider/orders_provider.dart';
import 'package:flutter_catat_stok/module/order/presentation/screens/create_order_screen.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/order_card.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Semua';
  Timer? _debounceTimer;

  late final user = context.watch<AuthProvider>().user;

  void _loadOrders({int page = 1, bool isRefresh = false}) {
    final provider = context.read<OrdersProvider>();
    OrderStatus? status;
    if (_selectedCategory != 'Semua') {
      for (var s in OrderStatus.values) {
        if (s.label == _selectedCategory) {
          status = s;
          break;
        }
      }
    }

    provider.getOrders(
      page: page,
      limit: 10,
      searchQuery: _searchController.text,
      status: status,
      isRefresh: isRefresh,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<OrdersProvider>();
      if (provider.hasMoreOrder &&
          !provider.isLoadingMoreOrder &&
          !provider.isLoadingOrder) {
        _loadOrders(page: provider.currentOrderPage + 1);
      }
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _loadOrders(page: 1, isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders(page: 1, isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah Pesanan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () async {
          final res = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
          );
          if (res == true) {
            _loadOrders(page: 1, isRefresh: true);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar (Orders, User Avatar)
            _buildTopAppBar(),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 12),

            // Filter Chips
            _buildFilterChips(),
            const SizedBox(height: 14),

            // Orders List Items
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Order',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Row(children: [AppCircleAvatar(name: user?.name.initials ?? 'U')]),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              hintText: 'Cari no. order atau marketplace',
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        _loadOrders(page: 1, isRefresh: true);
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Selector<OrdersProvider, List<String>>(
      selector: (_, p) => p.pickingChipFilter,
      builder: (context, filters, _) {
        return SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final catName = filters[index];
              final isSelected = _selectedCategory == catName;
              return ChoiceChip(
                label: Text(catName),
                selected: isSelected,
                selectedColor: AppColors.primary,
                showCheckmark: false,
                backgroundColor: AppColors.surfaceCard,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: isSelected
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.border, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                visualDensity: VisualDensity.compact,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = catName);
                    _loadOrders(page: 1, isRefresh: true);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOrdersList() {
    return Expanded(
      child: Consumer<OrdersProvider>(
        builder: (context, productProvider, _) {
          final orders = productProvider.orders;
          final isLoading = productProvider.isLoadingOrder;
          final isLoadingMore = productProvider.isLoadingMoreOrder;

          if (isLoading && orders.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppCard(
                padding: EdgeInsets.zero,
                borderRadius: 16,
                child: ListView.separated(
                  itemCount: 6,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderSubtle),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppShimmer.rectangle(width: 140, height: 14),
                                const SizedBox(height: 6),
                                AppShimmer.rectangle(width: 110, height: 12),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppShimmer.rectangle(width: 60, height: 14),
                              const SizedBox(height: 6),
                              AppShimmer.rectangle(width: 70, height: 12),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }

          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _loadOrders(page: 1, isRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: EmptyStateWidget(
                  imagePath: 'assets/images/empty_product.png',
                  title: 'Pesanan tidak ditemukan',
                  subtitle:
                      'Coba ubah kata kunci pencarian atau filter status.',
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadOrders(page: 1, isRefresh: true),
            child: ListView.separated(
              key: const PageStorageKey('orders_list'),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: orders.length + (isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == orders.length) {
                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppShimmer.rectangle(width: 130, height: 14),
                              const SizedBox(height: 6),
                              AppShimmer.rectangle(width: 100, height: 12),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppShimmer.rectangle(width: 55, height: 14),
                            const SizedBox(height: 6),
                            AppShimmer.rectangle(width: 65, height: 12),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                final order = orders[index];

                return OrderCard(
                  order: order,
                  onTap: () {
                    // widget.onOrderTap?.call(order);
                  },
                  primaryActionLabel:
                      order.status == OrderStatus.waitingVerification
                      ? 'Verifikasi Foto'
                      : 'Detail',
                  onPrimaryAction: () {
                    // widget.onOrderTap?.call(order);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
