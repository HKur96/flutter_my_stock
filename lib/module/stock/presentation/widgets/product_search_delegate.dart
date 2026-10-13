import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/core/widgets/app_shimmer.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:provider/provider.dart';

class ProductSearchDelegate extends SearchDelegate<Product?> {
  @override
  String get searchFieldLabel => 'Cari nama produk atau SKU...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    return _ProductSearchList(
      query: query,
      onSelected: (product) => close(context, product),
    );
  }
}

class _ProductSearchList extends StatefulWidget {
  const _ProductSearchList({required this.query, required this.onSelected});

  final String query;
  final ValueChanged<Product> onSelected;

  @override
  State<_ProductSearchList> createState() => _ProductSearchListState();
}

class _ProductSearchListState extends State<_ProductSearchList> {
  static const _debounceDuration = Duration(milliseconds: 400);
  static const _limit = 10;

  final _scrollController = ScrollController();
  Timer? _debounce;

  String? get _searchQuery {
    final q = widget.query.trim();
    return q.isEmpty ? null : q;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch awal (tanpa debounce), setelah frame pertama supaya aman dari
    // notifyListeners() saat build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFirstPage());
  }

  @override
  void didUpdateWidget(covariant _ProductSearchList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query.trim() != widget.query.trim()) {
      _debounce?.cancel();
      _debounce = Timer(_debounceDuration, _fetchFirstPage);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchFirstPage() {
    if (!mounted) return;
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    context.read<ProductProvider>().getProductDelegate(
      page: 1,
      limit: _limit,
      searchQuery: _searchQuery,
      isRefresh: true,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 200) return;

    final provider = context.read<ProductProvider>();
    if (provider.isLoadingProductDelegate ||
        provider.isLoadingMoreProductDelegate ||
        !provider.hasMoreProductDelegate) {
      return;
    }

    provider.getProductDelegate(
      page: provider.currentProductDelegatePage + 1,
      limit: _limit,
      searchQuery: _searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.productsDelegate;

    // Loading (halaman pertama)
    if (provider.isLoadingProductDelegate) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _ShimmerBox(width: 40, height: 40),
              SizedBox(width: 12),
              Expanded(child: _ShimmerBox(width: double.infinity, height: 40)),
            ],
          ),
        ),
      );
    }

    // Error (halaman pertama)
    if (provider.productErrorDelegate != null && products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.productErrorDelegate!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _fetchFirstPage,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Kosong
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Produk tidak ditemukan',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    // List + indikator load more
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount:
          products.length + (provider.isLoadingMoreProductDelegate ? 1 : 0),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final p = products[index];
        return _ProductTile(product: p, onTap: () => widget.onSelected(p));
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppShimmer.rectangle(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(10),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: p.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: p.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => AppShimmer.rectangle(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(10),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
      title: Text(
        p.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${p.categoryName} • SKU: ${p.sku}',
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${p.currentStock} ${p.unit.name}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
            ),
          ),
          const Text(
            'Stok Sistem',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
