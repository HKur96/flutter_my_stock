// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/utils/currency_formatter.dart';
import 'package:flutter_catat_stok/core/widgets/app_text_field.dart';
import 'package:flutter_catat_stok/core/widgets/empty_state_widget.dart';
import 'package:flutter_catat_stok/module/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/smooth_page_route.dart';
import '../../../../core/widgets/app_card.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Semua';
  Timer? _debounceTimer;

  late final user = context.watch<AuthProvider>().user;

  void _loadProducts({int page = 1, bool isRefresh = false}) {
    final provider = context.read<ProductProvider>();
    String? catId;
    if (_selectedCategory != 'Semua') {
      CategoryItem? matchedCat;
      for (var c in provider.categories) {
        if (c.name == _selectedCategory) {
          matchedCat = c;
          break;
        }
      }
      catId = matchedCat?.id;
    }

    provider.getProducts(
      page: page,
      limit: 10,
      searchQuery: _searchController.text,
      categoryId: catId,
      isRefresh: isRefresh,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<ProductProvider>();
      if (provider.hasMoreProduct &&
          !provider.isLoadingMoreProduct &&
          !provider.isLoadingProduct) {
        _loadProducts(page: provider.currentProductPage + 1);
      }
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _loadProducts(page: 1, isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().getCategories();
      _loadProducts(page: 1, isRefresh: true);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Row (Produk, +, User Avatar)
            _buildTopAppBar(),

            // Search Bar & Scan Button Row
            _buildSearchBarAndScan(),
            const SizedBox(height: 12),

            // Category Filter Chips
            _buildFilterChips(),
            const SizedBox(height: 14),

            // Metric Strip (Total Item Aktif & Perlu Restok)
            _buildMetricStrip(),
            const SizedBox(height: 14),

            // Product List Items
            _buildProductList(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarAndScan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              hintText: 'Cari nama atau SKU',
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
                        _loadProducts(page: 1, isRefresh: true);
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Simulasi Scan Barcode SKU')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Selector<ProductProvider, List<String>>(
      selector: (_, p) => p.categoriesChipFilter,
      builder: (_, categories, __) {
        return SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: AppColors.primary,
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
                    setState(() => _selectedCategory = cat);
                    _loadProducts(page: 1, isRefresh: true);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMetricStrip() {
    return Selector<ProductProvider, List<Product>>(
      selector: (_, p) => p.products,
      builder: (context, products, _) {
        final lowStockCount = products.where((p) => p.isLowStock).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Item Aktif',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${products.length} Produk',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: AppColors.primaryAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perlu Restok',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.stockOut,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$lowStockCount Item Tipis',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.stockOut,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: AppColors.stockOut,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final products = productProvider.products;
          final isLoading = productProvider.isLoadingProduct;
          final isLoadingMore = productProvider.isLoadingMoreProduct;

          if (isLoading && products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (products.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _loadProducts(page: 1, isRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: 300,
                  alignment: Alignment.center,
                  child: const EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'Produk tidak ditemukan',
                    subtitle:
                        'Coba ubah kata kunci pencarian atau filter kategori.',
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadProducts(page: 1, isRefresh: true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppCard(
                padding: EdgeInsets.zero,
                borderRadius: 16,
                child: ListView.separated(
                  key: const PageStorageKey('product_list'),
                  controller: _scrollController,
                  itemCount: products.length + (isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderSubtle),
                  itemBuilder: (context, index) {
                    if (index == products.length) {
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

                    final item = products[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          SmoothPageRoute(
                            page: ProductDetailScreen(selectedProduct: item),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.vertical(
                        top: index == 0
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottom: index == products.length - 1
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
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
                                    'SKU: ${item.sku} • ${item.categoryName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Stok ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${item.currentStock}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: item.isLowStock
                                              ? AppColors.stockOut
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.isLowStock
                                      ? 'Menipis • ${CurrencyFormatter.format(item.recommendedSellingPrice.toDouble())}'
                                      : CurrencyFormatter.format(
                                          item.recommendedSellingPrice
                                              .toDouble(),
                                        ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: item.isLowStock
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: item.isLowStock
                                        ? AppColors.stockOut
                                        : AppColors.textMuted,
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
              ),
            ),
          );
        },
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
            'Produk',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(page: const AddEditProductScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
