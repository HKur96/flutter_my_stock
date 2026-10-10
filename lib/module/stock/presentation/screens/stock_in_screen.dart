// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/services/local_storage_service.dart';
import 'package:flutter_catat_stok/core/utils/currency_formatter.dart';
import 'package:flutter_catat_stok/core/utils/currency_input_formatter.dart';
import 'package:flutter_catat_stok/core/widgets/app_card.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/stock/domain/dto/stock_transaction_dto.dart';
import 'package:flutter_catat_stok/module/stock/presentation/provider/stock_provider.dart';
import 'package:flutter_catat_stok/module/stock/presentation/widgets/product_search_delegate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';

class StockInScreen extends StatefulWidget {
  final Product? initialProduct;

  const StockInScreen({super.key, this.initialProduct});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final _selectedProduct = ValueNotifier<Product?>(null);
  final _quantity = ValueNotifier(12);
  final _isLoading = ValueNotifier(false);

  final _qtyController = TextEditingController(text: '12');
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedProduct.value = widget.initialProduct;
      if (widget.initialProduct != null) {
        _priceController.text = CurrencyInputFormatter.formatNumber(
          widget.initialProduct!.purchasePrice,
        );
      }
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _selectedProduct.dispose();
    _isLoading.dispose();
    _quantity.dispose();
    super.dispose();
  }

  void _incrementQty(int amount) {
    _quantity.value += amount;
    _qtyController.text = _quantity.value.toString();
  }

  void _decrementQty() {
    if (_quantity.value > 1) {
      _quantity.value--;
      _qtyController.text = _quantity.value.toString();
    }
  }

  Future<void> _openProductSearch(List<Product> products) async {
    final selected = await showSearch<Product?>(
      context: context,
      delegate: ProductSearchDelegate(products),
    );
    if (selected != null) {
      _selectedProduct.value = selected;
      _priceController.text = CurrencyInputFormatter.formatNumber(
        selected.purchasePrice,
      );
    }
  }

  void _handleSaveStockIn() async {
    if (_selectedProduct.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu!')),
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

    final buyPrice =
        int.tryParse(_priceController.text.replaceAll('.', '')) ??
        _selectedProduct.value!.purchasePrice.toInt();

    final response = await context.read<StockProvider>().stockIn(
      StockTransactionDto(
        userId: currentUser.id,
        productId: _selectedProduct.value!.id,
        type: StockTransactionType.stockIn,
        quantity: _quantity.value,
        purchasePrice: buyPrice.toDouble(),
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
        title: const Text('Stok Masuk'),
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
                onPressed: _isLoading.value ? null : _handleSaveStockIn,
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
                    : const Text('Simpan Stok Masuk'),
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
            final currentStock = _selectedProduct.value?.currentStock ?? 0;
            final unit = _selectedProduct.value?.unit ?? 'pcs';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Product Preview Card (Match Stitch 07_stok_masuk)
                _buildProductSelection(
                  selectedProduct,
                  products,
                  currentStock,
                  unit,
                ),
                const SizedBox(height: 16),

                if (selectedProduct != null) ...[
                  // Quantity Input Card (Match Stitch 07_stok_masuk)
                  _buildQuantityInput(unit),
                  const SizedBox(height: 16),

                  // Price Input Card
                  _buildPriceInput(),
                  const SizedBox(height: 16),

                  // Notes Input Card
                  _buildNotesInput(),
                  const SizedBox(height: 16),

                  // Automatic Summary Card (Match Stitch 07_stok_masuk)
                  _buildSummaryCard(selectedProduct, unit),
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

  Widget _buildProductSelection(
    Product? selectedProduct,
    List<Product> products,
    int currentStock,
    String unit,
  ) {
    return AppCard(
      onTap: () => _openProductSearch(products),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedProduct != null) ...[
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
                ],
                Text(
                  selectedProduct?.name ?? 'Pilih Produk',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (selectedProduct != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.stockInBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Stok saat ini: $currentStock $unit',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.stockIn,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildQuantityInput(String unit) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah Barang Masuk ($unit) *',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Siap ditambah',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.stockIn,
                  fontWeight: FontWeight.w600,
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
                        if (n != null && n > 0) _quantity.value = n;
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
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Pintasan Cepat:',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildQuickChip('+5', () => _incrementQty(5)),
              const SizedBox(width: 6),
              _buildQuickChip('+10', () => _incrementQty(10)),
              const SizedBox(width: 6),
              _buildQuickChip('+20', () => _incrementQty(20)),
              const SizedBox(width: 6),
              _buildQuickChip('+40', () => _incrementQty(40)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Harga Beli Satuan *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0'),
            inputFormatters: [CurrencyInputFormatter()],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Kulakan (Opsional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'cth: Kulakan Toko Grosir Jaya Makmur, faktur #...',
              prefixIcon: Icon(Icons.store_outlined, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Product selectedProduct, String unit) {
    return ListenableBuilder(
      listenable: Listenable.merge([_quantity, _priceController]),
      builder: (context, _) {
        int stock = selectedProduct.currentStock;
        int newStock = stock + _quantity.value;
        double price = _priceController.text.isEmpty
            ? 0
            : double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0;
        int totalCost = (price * _quantity.value).round();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.stockInBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stockInBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppColors.stockIn,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'RINGKASAN OTOMATIS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.stockIn,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Stok akan menjadi:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$newStock $unit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Total Biaya Kulakan:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(totalCost.toDouble()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
