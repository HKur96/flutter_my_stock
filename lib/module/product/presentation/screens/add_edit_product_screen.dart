// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/utils/smooth_page_route.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/product/presentation/screens/manage_category_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

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
    _skuController = TextEditingController(text: p?.sku ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _stockController = TextEditingController(
      text: p?.currentStock.toString() ?? '',
    );
    _minStockController = TextEditingController(
      text: p?.minimumStock.toString() ?? '',
    );
    _buyPriceController = TextEditingController(
      text: p != null ? p.purchasePrice.toInt().toString() : '',
    );
    _sellPriceController = TextEditingController(
      text: p != null ? p.recommendedSellingPrice.toInt().toString() : '',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    if (p != null) {
      _selectedCategory = p.categoryName.trim().isNotEmpty
          ? p.categoryName
          : null;
      _selectedUnit = _units.contains(p.unit) ? p.unit : 'Pcs';
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

    final selectedCategoryId = context
        .read<ProductProvider>()
        .categories
        .firstWhere((c) => c.name == _selectedCategory)
        .id;

    if (await context.read<ProductProvider>().addProduct(
      product: Product(
        id: '',
        name: _nameController.text,
        sku: _skuController.text,
        categoryId: selectedCategoryId,
        categoryName: _selectedCategory!,
        currentStock: int.parse(_stockController.text),
        minimumStock: int.parse(_minStockController.text),
        purchasePrice: int.parse(_buyPriceController.text),
        recommendedSellingPrice: int.parse(_sellPriceController.text),
        description: _descriptionController.text,
        unit: _selectedUnit,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    )) {
      if (!mounted) return;
      
      Navigator.pop(context);
    }
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
      bottomNavigationBar: Selector<ProductProvider, bool>(
        selector: (_, p) => p.isLoading,
        builder: (context, isLoading, child) {
          return Container(
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
              onPressed: isLoading ? null : _handleSave,
              child: isLoading
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
          );
        },
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
                  final categoryNames = value.categories
                      .map((c) => c.name)
                      .where((name) => name.trim().isNotEmpty)
                      .toSet()
                      .toList();

                  final String? effectiveCategory =
                      (_selectedCategory != null &&
                          categoryNames.contains(_selectedCategory))
                      ? _selectedCategory
                      : (categoryNames.isNotEmpty ? categoryNames.first : null);

                  final String effectiveUnit = _units.contains(_selectedUnit)
                      ? _selectedUnit
                      : _units.first;

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
                            DropdownButtonFormField<String?>(
                              value: effectiveCategory,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              items: categoryNames
                                  .map(
                                    (name) => DropdownMenuItem<String?>(
                                      value: name,
                                      child: Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
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
                              value: effectiveUnit,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              items: _units
                                  .map(
                                    (u) => DropdownMenuItem<String>(
                                      value: u,
                                      child: Text(u),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedUnit = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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
