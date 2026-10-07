// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/utils/smooth_page_route.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/product/presentation/screens/manage_category_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/mock_data.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductItem? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _skuController;
  late TextEditingController _nameController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _buyPriceController;
  late TextEditingController _sellPriceController;
  late TextEditingController _descriptionController;

  String? _selectedCategory;
  String _selectedUnit = 'Pcs';
  bool _isLoading = false;

  final List<String> _units = [
    'Pcs',
    'Unit',
    'Bungkus',
    'Rim',
    'Box',
    'Kg',
    'Liter',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _skuController = TextEditingController(
      text:
          p?.sku ??
          'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    _nameController = TextEditingController(text: p?.name ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '0');
    _minStockController = TextEditingController(
      text: p?.minStock.toString() ?? '5',
    );
    _buyPriceController = TextEditingController(
      text: p != null ? p.buyPrice.toInt().toString() : '',
    );
    _sellPriceController = TextEditingController(
      text: p != null ? p.sellPrice.toInt().toString() : '',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    if (p != null) {
      _selectedCategory = p.category;
      _selectedUnit = p.unit;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCategoryAndInit();
    });
  }

  Future<void> _checkCategoryAndInit() async {
    final provider = context.read<ProductProvider>();
    if (provider.categories.isEmpty) {
      await provider.getCategories();
    }

    if (!mounted) return;

    if (provider.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan buat kategori terlebih dahulu sebelum menambah produk.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      Navigator.pushReplacement(
        context,
        SmoothPageRoute(
          page: const ManageCategoryScreen(type: PickCategoryType.initial),
        ),
      );
    } else {
      if (_selectedCategory == null ||
          !provider.categories.any((c) => c.name == _selectedCategory)) {
        setState(() {
          _selectedCategory = provider.categories.first.name;
        });
      }
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

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
          widget.product != null
              ? 'Produk berhasil diperbarui!'
              : 'Produk baru berhasil disimpan!',
        ),
        backgroundColor: AppColors.stockIn,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk Baru'),
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
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Produk'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Area
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 36,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Foto Produk',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SKU Field with Scanner
              const Text(
                'Kode SKU',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  hintText: 'Contoh: SKU-ELK-001',
                  prefixIcon: const Icon(
                    Icons.qr_code_rounded,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Simulasi Scan Barcode SKU'),
                        ),
                      );
                    },
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'SKU wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Product Name
              const Text(
                'Nama Produk',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nama produk lengkap',
                  prefixIcon: Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Nama produk wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // Category & Unit Row
              Consumer<ProductProvider>(
                builder: (context, value, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                             DropdownButtonFormField<String>(
                                value: (value.categories.any((c) => c.name == _selectedCategory))
                                    ? _selectedCategory
                                    : (value.categories.isNotEmpty ? value.categories.first.name : null),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                items: value.categories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.name,
                                        child: Text(
                                          c.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedCategory = val);
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Satuan Unit',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              items: _units
                                  .map(
                                    (u) =>
                                        DropdownMenuItem(value: u, child: Text(u)),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedUnit = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 16),

              // Stock & Min Stock Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stok Awal',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Min. Stok Alert',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _minStockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '5'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pricing Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Beli (Rp)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _buyPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Jual (Rp)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _sellPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                'Deskripsi (Opsional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan catatan detail mengenai produk...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
