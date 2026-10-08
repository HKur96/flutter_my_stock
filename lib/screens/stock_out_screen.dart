import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../module/product/presentation/provider/product_provider.dart';

class StockOutScreen extends StatefulWidget {
  final Product? initialProduct;

  const StockOutScreen({super.key, this.initialProduct});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  Product? _selectedProduct;
  int _quantity = 1;
  final _qtyController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  final _dateController = TextEditingController(text: '07 Okt 2026, 10:15');
  String _reasonType = 'Penjualan Retail';
  bool _isLoading = false;

  final List<String> _reasons = [
    'Penjualan Retail',
    'Penjualan Wholesale / B2B',
    'Barang Rusak / Cacat',
    'Kadaluarsa',
    'Penggunaan Internal',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProduct =
        widget.initialProduct ?? context.read<ProductProvider>().products.first;
  }

  void _incrementQty() {
    final maxStock = _selectedProduct?.currentStock ?? 999;
    if (_quantity < maxStock) {
      setState(() {
        _quantity++;
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
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Berhasil mengeluarkan $_quantity ${_selectedProduct?.unit ?? "Pcs"} stok ${_selectedProduct?.name}!',
        ),
        backgroundColor: AppColors.stockOut,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catat Stok Keluar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleSaveStockOut,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.stockOut),
          icon: _isLoading
              ? const SizedBox.shrink()
              : const Icon(Icons.check_rounded, color: Colors.white),
          label: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text('Simpan Stok Keluar'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.stockOutBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.stockOut.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: AppColors.stockOut,
                    radius: 20,
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengeluaran Stok / Barang Keluar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Jumlah stok akan berkurang secara otomatis setelah disimpan.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Select Product Dropdown
            const Text(
              'Pilih Produk',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Selector<ProductProvider, List<Product>>(
              selector: (_, p) => p.products,
              builder: (_, products, _) {
                return DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                  items: products.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(
                        '${p.name} (${p.sku})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProduct = val;
                      _quantity = 1;
                      _qtyController.text = '1';
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Product Selected Preview Card
            if (_selectedProduct != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(10),
                    //   child: Image.network(
                    //     _selectedProduct!.imageUrl,
                    //     width: 50,
                    //     height: 50,
                    //     fit: BoxFit.cover,
                    //     errorBuilder: (_, __, ___) => Container(
                    //       width: 50,
                    //       height: 50,
                    //       color: AppColors.inputBg,
                    //       child: const Icon(
                    //         Icons.inventory_2_outlined,
                    //         color: AppColors.textMuted,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedProduct!.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Tersedia: ${_selectedProduct!.currentStock} ${_selectedProduct!.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedProduct!.isLowStock
                                  ? AppColors.stockOut
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Reason / Category Dropdown
            const Text(
              'Alasan Stok Keluar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _reasonType,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.list_alt_rounded,
                  color: AppColors.textMuted,
                ),
              ),
              items: _reasons
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _reasonType = val);
              },
            ),
            const SizedBox(height: 16),

            // Quantity Counter Row
            const Text(
              'Jumlah Keluar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: _decrementQty,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.remove_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (val) {
                      final n = int.tryParse(val);
                      if (n != null &&
                          n > 0 &&
                          n <= (_selectedProduct?.currentStock ?? 999)) {
                        _quantity = n;
                      }
                    },
                    decoration: InputDecoration(
                      suffixText: _selectedProduct?.unit ?? 'Pcs',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _incrementQty,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.stockOutBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.stockOut.withOpacity(0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.stockOut,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Picker Field
            const Text(
              'Tanggal & Waktu Transaksi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes / Customer Input
            const Text(
              'Catatan / Keterangan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Dikirim ke cabang Surabaya',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
