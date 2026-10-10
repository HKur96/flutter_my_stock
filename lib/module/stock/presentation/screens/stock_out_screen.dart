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
  final _selectedProduct = ValueNotifier<Product?>(null);
  final _quantity = ValueNotifier(1);
  final _reasonType = ValueNotifier('Terjual');
  final _isLoading = ValueNotifier(false);

  final _qtyController = TextEditingController(text: '1');
  final _noteController = TextEditingController();

  final List<String> _reasons = [
    'Terjual',
    'Rusak',
    'Kadaluarsa',
    'Pemakaian Toko',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedProduct.value = widget.initialProduct;
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    _selectedProduct.dispose();
    _quantity.dispose();
    _reasonType.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _openProductSearch(List<Product> products) async {
    final selected = await showSearch<Product?>(
      context: context,
      delegate: ProductSearchDelegate(products),
    );
    if (selected != null) {
      _selectedProduct.value = selected;
      _quantity.value = 1;
      _qtyController.text = '1';
    }
  }

  void _incrementQty(int amount) {
    final maxStock = _selectedProduct.value?.currentStock ?? 999;
    if (_quantity.value + amount <= maxStock) {
      _quantity.value += amount;
      _qtyController.text = _quantity.value.toString();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah melebihi stok yang tersedia ($maxStock)!'),
        ),
      );
    }
  }

  void _decrementQty() {
    if (_quantity.value > 1) {
      _quantity.value--;
      _qtyController.text = _quantity.value.toString();
    }
  }

  void _handleSaveStockOut() async {
    if (_selectedProduct.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu!')),
      );
      return;
    }

    if (_quantity.value > _selectedProduct.value!.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah melebihi stok yang tersedia (${_selectedProduct.value!.currentStock})!',
          ),
        ),
      );
      return;
    }

    _isLoading.value = true;

    final currentUser = await LocalStorageService().getUser();
    if (currentUser == null) {
      if (mounted) _isLoading.value = false;
      return;
    }

    if (!mounted) return;

    final response = await context.read<StockProvider>().stockOut(
      StockTransactionDto(
        userId: currentUser.id,
        productId: _selectedProduct.value!.id,
        type: StockTransactionType.stockOut,
        quantity: _quantity.value,
        reason: _reasonType.value,
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
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stok Keluar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: Listenable.merge([_selectedProduct, _isLoading]),
        builder: (context, child) {
          if (_selectedProduct.value == null) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: _isLoading.value ? null : _handleSaveStockOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: _isLoading.value
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: _isLoading.value
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
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<Product?>(
          valueListenable: _selectedProduct,
          builder: (context, selectedProduct, child) {
            final products = context.watch<ProductProvider>().products;
            final currentStock = selectedProduct?.currentStock ?? 0;
            final unit = selectedProduct?.unit ?? UnitType.pcs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Product Card
                _buildProductSelection(
                  selectedProduct,
                  products,
                  currentStock,
                  unit.name,
                ),
                const SizedBox(height: 16),

                if (selectedProduct != null) ...[
                  // Kuantitas Keluar Card
                  _buildQuantityCard(unit.name, currentStock),
                  const SizedBox(height: 16),

                  // Alasan Pengeluaran Stok Card
                  _buildReasonCard(),
                  const SizedBox(height: 16),

                  // Catatan Operasional Card
                  _buildOperationalNote(),
                  const SizedBox(height: 16),

                  // Ringkasan Sisa Saldo Stok Card
                  _buildRemainingStockCard(selectedProduct, unit.name),
                ],
              ],
            );
          },
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
                          _quantity.value = n;
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
          ValueListenableBuilder<String>(
            valueListenable: _reasonType,
            builder: (context, reasonType, _) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3.2,
                children: _reasons.map((r) {
                  final isSelected = reasonType == r;
                  return InkWell(
                    onTap: () => _reasonType.value = r,
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
              );
            },
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
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(
              hintText: 'cth: Pelanggan borongan, atau pecah saat bor',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingStockCard(Product selectedProduct, String unit) {
    return ValueListenableBuilder<int>(
      valueListenable: _quantity,
      builder: (context, quantity, _) {
        final currentStock = selectedProduct.currentStock;
        final remainingStock = currentStock - quantity;

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
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
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
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
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '-$quantity $unit',
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
      },
    );
  }

  Widget _buildProductSelection(
    Product? selectedProduct,
    List<Product> products,
    int currentStock,
    String unit,
  ) {
    if (selectedProduct == null) {
      return AppCard(
        onTap: () => _openProductSearch(products),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Produk Stok Keluar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ketuk untuk mencari produk yang akan di-stock keluar',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      );
    }

    return AppCard(
      onTap: () => _openProductSearch(products),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      selectedProduct.categoryName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SKU: ${selectedProduct.sku}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  selectedProduct.name,
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
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
