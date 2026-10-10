// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/services/local_storage_service.dart';
import 'package:flutter_catat_stok/core/utils/currency_formatter.dart';
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
  Product? _selectedProduct;
  int _quantity = 10;
  final _qtyController = TextEditingController(text: '10');
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_selectedProduct != null) {
      _selectedProduct = widget.initialProduct;
      _priceController.text = _selectedProduct!.purchasePrice
          .toInt()
          .toString();
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _incrementQty(int amount) {
    setState(() {
      _quantity += amount;
      _qtyController.text = _quantity.toString();
    });
  }

  void _decrementQty() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _qtyController.text = _quantity.toString();
      });
    }
  }

  Future<void> _openProductSearch(List<Product> products) async {
    final selected = await showSearch<Product?>(
      context: context,
      delegate: ProductSearchDelegate(products),
    );
    if (selected != null) {
      setState(() {
        _selectedProduct = selected;
        _priceController.text = selected.purchasePrice.toInt().toString();
      });
    }
  }

  void _handleSaveStockIn() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu!')),
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

    final buyPrice =
        int.tryParse(_priceController.text.replaceAll('.', '')) ??
        _selectedProduct!.purchasePrice.toInt();

    final response = await context.read<StockProvider>().stockIn(
      StockTransactionDto(
        userId: currentUser.id,
        productId: _selectedProduct!.id,
        type: StockTransactionType.stockIn,
        quantity: _quantity,
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final currentStock = _selectedProduct?.currentStock ?? 0;
    final newStock = currentStock + _quantity;
    final unit = _selectedProduct?.unit ?? 'pcs';
    final buyPrice =
        int.tryParse(_priceController.text.replaceAll('.', '')) ??
        (_selectedProduct?.purchasePrice.toInt() ?? 0);
    final totalCost = buyPrice * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stok Masuk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Cari Produk',
            onPressed: () => _openProductSearch(products),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSaveStockIn,
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
                : const Text('Simpan Stok Masuk'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Product Preview Card (Match Stitch 07_stok_masuk)
            AppCard(
              onTap: () => _openProductSearch(products),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
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
                        Row(
                          children: [
                            Text(
                              _selectedProduct?.categoryName ?? 'Kategori',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SKU: ${_selectedProduct?.sku ?? "-"}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
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
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => _openProductSearch(products),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Input Card (Match Stitch 07_stok_masuk)
            AppCard(
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
                                if (n != null && n > 0)
                                  setState(() => _quantity = n);
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
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                          ),
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
            ),
            const SizedBox(height: 16),

            // Price Input Card
            AppCard(
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
                    decoration: const InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '0',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes Input Card
            AppCard(
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
                      hintText:
                          'cth: Kulakan Toko Grosir Jaya Makmur, faktur #...',
                      prefixIcon: Icon(Icons.store_outlined, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Automatic Summary Card (Match Stitch 07_stok_masuk)
            Container(
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
            ),
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
}
