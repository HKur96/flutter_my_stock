// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/widgets/empty_state_widget.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';
import 'package:flutter_catat_stok/module/stock/presentation/provider/stock_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ValueNotifier<ProductLogType> _selectedFilter = ValueNotifier(
    ProductLogType.all,
  );
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  void _loadData({
    int page = 1,
    bool isRefresh = false,
  }) {
    final filter = _selectedFilter.value == ProductLogType.all
        ? null
        : _selectedFilter.value;
    context.read<StockProvider>().getProductLogs(
          page: page,
          limit: 10,
          searchQuery: _searchController.text,
          filterType: filter,
          isRefresh: isRefresh,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<StockProvider>();
      if (provider.hasMore &&
          !provider.isLoadingMore &&
          !provider.isLoading) {
        _loadData(page: provider.currentPage + 1);
      }
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _loadData(page: 1, isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(page: 1, isRefresh: true);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _selectedFilter.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Transaksi Stok',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _showSearch
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _showSearch = !_showSearch;
                            if (!_showSearch) {
                              _searchController.clear();
                              _loadData(page: 1, isRefresh: true);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar Input (If toggled)
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari produk, catatan, atau pencatat...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _loadData(page: 1, isRefresh: true);
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),

            // Sub Header (Period Dropdown & Count)
            Selector<StockProvider, List<ProductLog>>(
              selector: (_, p) => p.productLogs,
              builder: (context, logs, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Semua Riwayat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${logs.length} MUTASI',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Filter Chips Bar (Semua, Masuk, Keluar, Opname)
            ValueListenableBuilder<ProductLogType>(
              valueListenable: _selectedFilter,
              builder: (context, selectedFilter, _) {
                final filterList = [
                  ProductLogType.all,
                  ProductLogType.stockIn,
                  ProductLogType.stockOut,
                  ProductLogType.update,
                ];

                return SizedBox(
                  height: 34,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: filterList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final type = filterList[index];
                      final isSelected = selectedFilter == type;
                      final label = type == ProductLogType.update
                          ? 'Opname'
                          : type.displayName;

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceCard,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                        side: isSelected
                            ? BorderSide.none
                            : const BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        visualDensity: VisualDensity.compact,
                        onSelected: (selected) {
                          if (selected) {
                            _selectedFilter.value = type;
                            _loadData(page: 1, isRefresh: true);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Summary Bar (Total Masuk, Total Keluar, Net Aliran)
            Selector<StockProvider, List<ProductLog>>(
              selector: (_, p) => p.productLogs,
              builder: (context, logs, _) {
                int totalIn = 0;
                int totalOut = 0;

                for (var log in logs) {
                  if (log.productLogType == ProductLogType.stockIn) {
                    totalIn += log.stockDifferent;
                  } else if (log.productLogType == ProductLogType.stockOut) {
                    totalOut += log.stockDifferent;
                  }
                }
                final netFlow = totalIn - totalOut;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    borderRadius: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Total Masuk',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+$totalIn pcs',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.stockIn,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: AppColors.borderSubtle,
                        ),
                        Column(
                          children: [
                            const Text(
                              'Total Keluar',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '-$totalOut pcs',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.stockOut,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: AppColors.borderSubtle,
                        ),
                        Column(
                          children: [
                            const Text(
                              'Net Aliran',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${netFlow >= 0 ? "+" : ""}$netFlow pcs',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: netFlow >= 0
                                    ? AppColors.stockIn
                                    : AppColors.stockOut,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // History Log List
            Expanded(
              child: Consumer<StockProvider>(
                builder: (context, stockProvider, _) {
                  final logs = stockProvider.productLogs;
                  final isLoading = stockProvider.isLoading;
                  final isLoadingMore = stockProvider.isLoadingMore;

                  if (isLoading && logs.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (logs.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async => _loadData(page: 1, isRefresh: true),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: const EmptyStateWidget(
                            icon: Icons.history_toggle_off_rounded,
                            title: 'Tidak ada riwayat aktivitas',
                            subtitle:
                                'Belum ada catatan mutasi stok yang sesuai.',
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadData(page: 1, isRefresh: true),
                    child: ListView.separated(
                      key: const PageStorageKey('history_screen'),
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                      itemCount: logs.length + (isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == logs.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }

                        final item = logs[index];
                        final isIn =
                            item.productLogType == ProductLogType.stockIn;
                        final isOut =
                            item.productLogType == ProductLogType.stockOut;

                        final Color iconBg = isIn
                            ? AppColors.stockInBg
                            : isOut
                                ? AppColors.stockOutBg
                                : AppColors.warningBg;
                        final Color iconColor = isIn
                            ? AppColors.stockIn
                            : isOut
                                ? AppColors.stockOut
                                : AppColors.warning;
                        final IconData iconData = isIn
                            ? Icons.south_west_rounded
                            : isOut
                                ? Icons.north_east_rounded
                                : Icons.balance_rounded;

                        final String badgeLabel = isIn
                            ? 'IN'
                            : isOut
                                ? 'OUT'
                                : 'ADJ';

                        return AppCard(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 14,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  iconData,
                                  color: iconColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${DateFormatter.dayHours(item.createdAt)} • ${item.pic.isEmpty ? "Kasir Utama" : item.pic}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    if ((item.note ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Catatan: ${item.note}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: iconBg,
                                      borderRadius: BorderRadius.circular(
                                        6,
                                      ),
                                    ),
                                    child: Text(
                                      badgeLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${isIn ? "+" : isOut ? "-" : ""}${item.stockDifferent} pcs',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: iconColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
