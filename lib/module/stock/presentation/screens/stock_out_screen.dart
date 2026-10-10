// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/services/local_storage_service.dart';
import 'package:flutter_catat_stok/core/widgets/app_card.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/stock/domain/dto/stock_transaction_dto.dart';
import 'package:flutter_catat_stok/module/stock/presentation/provider/stock_provider.dart';
import 'package:flutter_catat_stok/module/stock/presentation/widgets/product_search_delegate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product/presentation/provider/product_provider.dart';

class StockOutScreen extends StatefulWidget {
  final Product? initialProduct;

  const StockOutScreen({super.key, this.initialProduct});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  Product? _selectedProduct;
  int _quantity = 15;
  final _qtyController = TextEditingController(text: '15');
  final _noteController = TextEditingController();
  String _reasonType = 'Terjual';
  bool _isLoading = false;

  final List<String> _reasons = [
    'Terjual',
    'Rusak',
    'Kadaluarsa',
    'Pemakaian Toko',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _selectedProduct = widget.initialProduct;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _openProductSearch(List<Product> products) async {
    final selected = await showSearch<Product?>(
      context: context,
      delegate: ProductSearchDelegate(products),
    );
    if (selected != null) {
      setState(() {
        _selectedProduct = selected;
        _quantity = 1;
        _qtyController.text = '1';
      });
    }
  }

  void _incrementQty(int amount) {
    final maxStock = _selectedProduct?.currentStock ?? 999;
    if (_quantity + amount <= maxStock) {
      setState(() {
        _quantity += amount;
        _qtyController.text = _quantity.toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah melebihi stok yang tersedia ($maxStock)!'),
        ),
      );
    }
  }

  void _decrementQty() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _qtyController.text = _quantity.toString();
      });
    }
  }

  void _handleSaveStockOut() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu!')),
      );
      return;
    }

    if (_quantity > _selectedProduct!.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah melebihi stok yang tersedia (${_selectedProduct!.currentStock})!',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentUser = await LocalStorageService().getUser();
    if (currentUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;

    final response = await context.read<StockProvider>().stockOut(
      StockTransactionDto(
        userId: currentUser.id,
        productId: _selectedProduct!.id,
        type: StockTransactionType.stockOut,
        quantity: _quantity,
        reason: _reasonType,
        createdAt: DateTime.now(),
        note: _noteController.text.trim(),
      ),
    );

    if (!mounted) return;

    if (response) {
      await context.read<ProductProvider>().getProducts();
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final currentStock = _selectedProduct?.currentStock ?? 0;
    final remainingStock = currentStock - _quantity;
    final unit = _selectedProduct?.unit ?? 'pcs';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stok Keluar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSaveStockOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: _isLoading
                ? const SizedBox.shrink()
                : const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
            label: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Simpan Stok Keluar'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Product Card (Match Stitch 03_stok_keluar_modern)
            _buildProductSelection(products, currentStock, unit),
            const SizedBox(height: 16),

            if (_selectedProduct != null) ...[
              // Kuantitas Keluar Card (Match Stitch 03_stok_keluar_modern)
              _buildQuantityCard(unit, currentStock),
              const SizedBox(height: 16),

              // Alasan Pengeluaran Stok Card (Match Stitch 03_stok_keluar_modern 2x2 grid)
              _buildReasonCard(),
              const SizedBox(height: 16),

              // Catatan Operasional Card
              _buildOperationalNote(),
              const SizedBox(height: 16),

              // Ringkasan Sisa Saldo Stok Card (Match Stitch 03_stok_keluar_modern)
              _buildRemainingStockCard(remainingStock, _quantity, unit),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityCard(String unit, int currentStock) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kuantitas Keluar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Satuan: $unit',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: _decrementQty,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.remove_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      onChanged: (val) {
                        final n = int.tryParse(val);
                        if (n != null && n > 0 && n <= currentStock) {
                          setState(() => _quantity = n);
                        }
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _incrementQty(1),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Penambahan Cepat (+):',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildQuickChip('+1', () => _incrementQty(1)),
              const SizedBox(width: 6),
              _buildQuickChip('+5', () => _incrementQty(5)),
              const SizedBox(width: 6),
              _buildQuickChip('+10', () => _incrementQty(10)),
              const SizedBox(width: 6),
              _buildQuickChip('+20', () => _incrementQty(20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alasan Pengeluaran Stok',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.2,
            children: _reasons.map((r) {
              final isSelected = _reasonType == r;
              return InkWell(
                onTap: () => setState(() => _reasonType = r),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalNote() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catatan Operasional',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Opsional',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'cth: Pelanggan borongan, atau pecah saat bor',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingStockCard(
    int remainingStock,
    int quantity,
    String unit,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Sisa Saldo Stok',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: remainingStock >= 0
                      ? AppColors.stockInBg
                      : AppColors.stockOutBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  remainingStock >= 0 ? '✓ Stok Aman' : '⚠️ Stok Defisit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: remainingStock >= 0
                        ? AppColors.stockIn
                        : AppColors.stockOut,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimasi stok sisa:',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$remainingStock $unit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total berkurang:',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '-$_quantity $unit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.stockOut,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelection(
    List<Product> products,
    int currentStock,
    String unit,
  ) {
    return AppCard(
      onTap: () => _openProductSearch(products),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedProduct?.categoryName ?? "Kategori"} • ${_selectedProduct?.sku ?? "-"}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedProduct?.name ?? 'Pilih Produk...',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok saat ini: $currentStock $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _openProductSearch(products),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Ganti', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
