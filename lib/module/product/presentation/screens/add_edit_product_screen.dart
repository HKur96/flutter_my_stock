// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/utils/currency_formatter.dart';
import 'package:flutter_catat_stok/core/utils/currency_input_formatter.dart';
import 'package:flutter_catat_stok/core/utils/smooth_page_route.dart';
import 'package:flutter_catat_stok/core/widgets/app_card.dart';
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
  late TextEditingController _buyPriceController;
  late TextEditingController _sellPriceController;
  late TextEditingController _descriptionController;

  final ValueNotifier<String?> _selectedCategory = ValueNotifier<String?>(null);
  final ValueNotifier<UnitType> _selectedUnit = ValueNotifier<UnitType>(
    UnitType.pcs,
  );
  final ValueNotifier<int> _minStock = ValueNotifier(4);

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _skuController = TextEditingController(text: p?.sku ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _stockController = TextEditingController(
      text: p?.currentStock.toString() ?? '0',
    );
    _minStock.value = p?.minimumStock ?? 4;
    _buyPriceController = TextEditingController(
      text: p != null ? p.purchasePrice.toInt().toString() : '',
    );
    _sellPriceController = TextEditingController(
      text: p != null ? p.recommendedSellingPrice.toInt().toString() : '',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    if (p != null) {
      _selectedCategory.value = p.categoryName.trim().isNotEmpty
          ? p.categoryName
          : null;
      _selectedUnit.value = p.unit;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCategoryAndInit();
    });
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _stockController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _descriptionController.dispose();
    _selectedCategory.dispose();
    _selectedUnit.dispose();
    _minStock.dispose();
    super.dispose();
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
      if (_selectedCategory.value == null ||
          !provider.categories.any((c) => c.name == _selectedCategory.value)) {
        _selectedCategory.value = provider.categories.first.name;
      }
    }
  }

  void _handleAddProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedCategoryId = context
        .read<ProductProvider>()
        .categories
        .firstWhere((c) => c.name == _selectedCategory.value)
        .id;

    if (await context.read<ProductProvider>().addProduct(
      product: Product(
        id: '',
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        categoryId: selectedCategoryId,
        categoryName: _selectedCategory.value!,
        currentStock: int.tryParse(_stockController.text) ?? 0,
        minimumStock: _minStock.value,
        purchasePrice: int.parse(
          _buyPriceController.text.replaceAll('.', ''),
        ).toDouble(),
        recommendedSellingPrice: int.parse(
          _sellPriceController.text.replaceAll('.', ''),
        ).toDouble(),
        description: _descriptionController.text.trim(),
        unit: _selectedUnit.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    )) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _handleEditProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedCategoryId = context
        .read<ProductProvider>()
        .categories
        .firstWhere((c) => c.name == _selectedCategory.value)
        .id;

    if (await context.read<ProductProvider>().updateProduct(
      product: Product(
        id: widget.product!.id,
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        categoryId: selectedCategoryId,
        categoryName: _selectedCategory.value!,
        currentStock: int.tryParse(_stockController.text) ?? 0,
        minimumStock: _minStock.value,
        purchasePrice: int.parse(
          _buyPriceController.text.replaceAll('.', ''),
        ).toDouble(),
        recommendedSellingPrice: int.parse(
          _sellPriceController.text.replaceAll('.', ''),
        ).toDouble(),
        description: _descriptionController.text.trim(),
        unit: _selectedUnit.value,
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
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppColors.surfaceContainer,
                    side: BorderSide.none,
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Selector<ProductProvider, bool>(
                  selector: (_, p) => p.isLoading,
                  builder: (context, isLoading, child) {
                    return ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : isEdit
                          ? _handleEditProduct
                          : _handleAddProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: isLoading
                          ? const SizedBox.shrink()
                          : const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      label: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Produk'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name Field (Match Stitch 08_tambah_produk)
              _buildFieldLabel('Nama Produk *'),
              TextFormField(
                controller: _nameController,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(
                  hintText: 'Indomie Goreng 85g',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Nama produk wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),

              Row(
                spacing: 14,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Field
                        _buildFieldLabel('Kategori *'),
                        ValueListenableBuilder<String?>(
                          valueListenable: _selectedCategory,
                          builder: (context, catVal, _) {
                            final categories = context
                                .watch<ProductProvider>()
                                .categories;
                            return DropdownButtonFormField<String>(
                              value: catVal,
                              isExpanded: true,
                              items: categories.map((c) {
                                return DropdownMenuItem(
                                  value: c.name,
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => _selectedCategory.value = val,
                              validator: (val) =>
                                  val == null ? 'Pilih kategori' : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        // SKU Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFieldLabel('SKU (Kode Produk)'),
                            const Text(
                              'Opsional',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _skuController,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          decoration: InputDecoration(
                            hintText: 'MKN-001',
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                final generated =
                                    'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                                _skuController.text = generated;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                spacing: 14,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Buy Price Field
                        _buildFieldLabel('Harga Beli (Modal) *'),
                        TextFormField(
                          controller: _buyPriceController,
                          keyboardType: TextInputType.number,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          inputFormatters: [CurrencyInputFormatter()],
                          decoration: const InputDecoration(
                            prefixText: 'Rp ',
                            hintText: '0',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Harga beli wajib diisi'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recommended Sell Price Field
                        _buildFieldLabel('Harga Jual Disarankan *'),
                        TextFormField(
                          controller: _sellPriceController,
                          keyboardType: TextInputType.number,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          inputFormatters: [CurrencyInputFormatter()],
                          decoration: const InputDecoration(
                            prefixText: 'Rp ',
                            hintText: '0',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Harga jual wajib diisi'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Estimasi Margin Pill Box (Match Stitch 08_tambah_produk)
              ListenableBuilder(
                listenable: Listenable.merge([
                  _buyPriceController,
                  _sellPriceController,
                ]),
                builder: (context, _) {
                  final buyPrice =
                      double.tryParse(
                        _buyPriceController.text.replaceAll('.', ''),
                      ) ??
                      0.0;
                  final sellPrice =
                      double.tryParse(
                        _sellPriceController.text.replaceAll('.', ''),
                      ) ??
                      0.0;
                  final margin = sellPrice - buyPrice;
                  final marginPercent = buyPrice > 0
                      ? ((margin / buyPrice) * 100).toInt()
                      : 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              size: 16,
                              color: AppColors.stockIn,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Estimasi Margin:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.stockIn,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              CurrencyFormatter.format(margin),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.stockInBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+$marginPercent%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.stockIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Satuan Barang *'),
              ValueListenableBuilder<UnitType>(
                valueListenable: _selectedUnit,
                builder: (context, selectedUnit, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 8,
                            children: UnitType.values.map((x) {
                              final selected = x == selectedUnit;
                              return ChoiceChip(
                                selected: selected,
                                onSelected: (value) {
                                  _selectedUnit.value = x;
                                },
                                label: Text(
                                  x.name,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                selectedColor: AppColors.primary,
                                disabledColor: Colors.white,
                                side: selected
                                    ? null
                                    : BorderSide(color: Colors.grey.shade300),
                                showCheckmark: false,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Minimum Stock Stepper Card (Match Stitch 08_tambah_produk)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stok Minimum Batas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Pemberitahuan saat stok mencapai batas ini',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            final value = _minStock.value;
                            if (value > 1) {
                              _minStock.value = value - 1;
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48,
                            height: 44,
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
                        ListenableBuilder(
                          listenable: Listenable.merge([
                            _minStock,
                            _selectedUnit,
                          ]),
                          builder: (_, __) {
                            return Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${_minStock.value}  ${_selectedUnit.value.name}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            final value = _minStock.value;
                            _minStock.value = value + 1;
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Initial Stock In Rack Card (Match Stitch 08_tambah_produk)
              if (!isEdit) ...[
                AppCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.stockInBg,
                  borderColor: AppColors.stockInBorder,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stok Awal di Rak',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'HANYA SAAT TAMBAH',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ValueListenableBuilder<UnitType>(
                        valueListenable: _selectedUnit,
                        builder: (context, selectedUnit, child) {
                          return TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: InputDecoration(
                              suffixText: selectedUnit.name,
                              hintText: '0',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
