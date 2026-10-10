// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/services/local_storage_service.dart';
import 'package:flutter_catat_stok/core/utils/currency_formatter.dart';
import 'package:flutter_catat_stok/core/widgets/app_card.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:flutter_catat_stok/module/stock/domain/dto/stock_transaction_dto.dart';
import 'package:flutter_catat_stok/module/stock/presentation/provider/stock_provider.dart';
import 'package:flutter_catat_stok/module/stock/presentation/widgets/product_search_delegate.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/theme/app_theme.dart';

class StockOpnameScreen extends StatefulWidget {
  final Product? initialProduct;

  const StockOpnameScreen({super.key, this.initialProduct});

  @override
  State<StockOpnameScreen> createState() => _StockOpnameScreenState();
}

class _StockOpnameScreenState extends State<StockOpnameScreen> {
  final _selectedProduct = ValueNotifier<Product?>(null);
  final _actualStock = ValueNotifier<int>(0);
  final _systemStock = ValueNotifier<int>(0);
  final _selectedReason = ValueNotifier<String?>(null);
  final _noteController = TextEditingController();
  final _isLoading = ValueNotifier<bool>(false);

  static const int _maxNoteLength = 120;

  static const List<String> _reasons = [
    'Hilang / Tidak Ditemukan',
    'Rusak / Bocor',
    'Salah Catat Masuk',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialProduct != null) {
        _selectedProduct.value = widget.initialProduct;
        _systemStock.value = widget.initialProduct!.currentStock;
        _actualStock.value = _systemStock.value;
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _selectedProduct.dispose();
    _actualStock.dispose();
    _systemStock.dispose();
    _selectedReason.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  int get _variance => _actualStock.value - _systemStock.value;
  double get _varianceValue => _selectedProduct.value != null
      ? _variance * _selectedProduct.value!.purchasePrice.toDouble()
      : 0;

  bool get _isVarianceZero => _variance == 0;
  bool get _isDeficit => _variance < 0;

  bool get _canSubmit {
    if (_selectedProduct.value == null) return false;
    if (_isVarianceZero) return true;
    return _selectedReason.value != null;
  }

  void _onProductSelected(Product product) {
    _selectedProduct.value = product;
    _systemStock.value = product.currentStock;
    _actualStock.value = product.currentStock;
    _selectedReason.value = null;
    _noteController.clear();
  }

  Future<void> _openProductSearch() async {
    final products = context.read<ProductProvider>().products;
    final selected = await showSearch<Product?>(
      context: context,
      delegate: ProductSearchDelegate(products),
    );
    if (selected != null) {
      _onProductSelected(selected);
    }
  }

  void _increment() {
    if (_selectedProduct.value == null) return;
    _actualStock.value++;
  }

  void _decrement() {
    if (_selectedProduct.value == null) return;
    if (_actualStock.value > 0) {
      _actualStock.value--;
    }
  }

  void _setActualStock(int value) {
    if (_selectedProduct.value == null) return;
    _actualStock.value = value;
  }

  void _selectReason(String reason) {
    _selectedReason.value = reason;
  }

  Future<void> _handleSubmit() async {
    if (_selectedProduct.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu!')),
      );
      return;
    }

    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alasan selisih terlebih dahulu!')),
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

    final adjustment = _variance;
    bool success = false;

    if (adjustment > 0) {
      success = await context.read<StockProvider>().stockIn(
        StockTransactionDto(
          userId: currentUser.id,
          productId: _selectedProduct.value!.id,
          type: StockTransactionType.opname,
          quantity: adjustment,
          createdAt: DateTime.now(),
          reason: _selectedReason.value,
          note: 'Opname: ${_noteController.text.trim()}',
        ),
      );
    } else if (adjustment < 0) {
      success = await context.read<StockProvider>().stockOut(
        StockTransactionDto(
          userId: currentUser.id,
          productId: _selectedProduct.value!.id,
          type: StockTransactionType.opname,
          quantity: adjustment.abs(),
          createdAt: DateTime.now(),
          reason: _selectedReason.value,
          note: 'Opname: ${_noteController.text.trim()}',
        ),
      );
    } else {
      success = true;
    }

    if (!mounted) return;

    if (success) {
      await context.read<ProductProvider>().getProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opname berhasil disimpan!'),
          backgroundColor: AppColors.stockIn,
        ),
      );
      Navigator.pop(context);
    } else {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      bottomNavigationBar: ListenableBuilder(
        listenable: Listenable.merge([
          _selectedProduct,
          _isLoading,
          _actualStock,
          _systemStock,
          _selectedReason,
        ]),
        builder: (context, _) {
          if (_selectedProduct.value == null) {
            return const SizedBox.shrink();
          }

          return _buildBottomBar();
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: ValueListenableBuilder<Product?>(
          valueListenable: _selectedProduct,
          builder: (context, selectedProduct, _) {
            return Column(
              children: [
                _buildProductSelectorCard(),
                const SizedBox(height: 12),
                if (selectedProduct != null) ...[
                  _buildStepperCard(),
                  const SizedBox(height: 12),
                  _buildVarianceCard(),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: _actualStock,
                    builder: (context, actualStock, _) {
                      if (_isVarianceZero) return const SizedBox.shrink();
                      return Column(
                        children: [
                          _buildReasonSelector(),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                  _buildNoteInput(),
                  const SizedBox(height: 40),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Stok Opname'),
      actions: [
        ValueListenableBuilder<Product?>(
          valueListenable: _selectedProduct,
          builder: (context, selectedProduct, _) {
            if (selectedProduct == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
                color: AppColors.surfaceCard,
              ),
              child: Text(
                selectedProduct.sku,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Product Selector Card ───────────────────────────────────────────
  Widget _buildProductSelectorCard() {
    return ListenableBuilder(
      listenable: Listenable.merge([_selectedProduct, _systemStock]),
      builder: (context, _) {
        final p = _selectedProduct.value;

        if (p == null) {
          return AppCard(
            onTap: _openProductSearch,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Produk Opname',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ketuk untuk mencari produk yang akan di-opname',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              p.categoryName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '•',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              p.sku,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (p.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            p.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openProductSearch,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: const Text(
                      'Ganti',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // System stock reference bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Stok Sistem Tercatat',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${_systemStock.value}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'monospace',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.unit,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
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

  // ── Stepper Card ────────────────────────────────────────────────────
  Widget _buildStepperCard() {
    final unit = _selectedProduct.value?.unit ?? 'pcs';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'HITUNG STOK FISIK AKTUAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Verifikasi hitungan fisik langsung di rak',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildStepperButton(icon: Icons.remove, onTap: _decrement),
                Expanded(
                  child: Column(
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _actualStock,
                        builder: (context, actualStock, _) {
                          return Text(
                            '$actualStock',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'monospace',
                              letterSpacing: -1,
                              height: 1,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStepperButton(icon: Icons.add, onTap: _increment),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPresetButton(label: '0 (Nol)', value: 0),
              const SizedBox(width: 8),
              ValueListenableBuilder<int>(
                valueListenable: _systemStock,
                builder: (context, systemStock, _) {
                  return _buildPresetButton(
                    label: '$systemStock (Sistem)',
                    value: systemStock,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Icon(icon, size: 24, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildPresetButton({required String label, required int value}) {
    return Material(
      color: AppColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => _setActualStock(value),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Variance Card ───────────────────────────────────────────────────
  Widget _buildVarianceCard() {
    return ListenableBuilder(
      listenable: Listenable.merge([_actualStock, _systemStock]),
      builder: (context, _) {
        final unit = _selectedProduct.value?.unit ?? 'pcs';
        final purchasePrice =
            _selectedProduct.value?.purchasePrice.toDouble() ?? 0;

        final Color bgColor;
        final Color accentColor;
        final IconData statusIcon;
        final String statusText;

        if (_isVarianceZero) {
          bgColor = AppColors.stockInBg;
          accentColor = AppColors.stockIn;
          statusIcon = Icons.verified_outlined;
          statusText = 'Stok Sesuai (Akurat)';
        } else if (_isDeficit) {
          bgColor = AppColors.warningBg;
          accentColor = AppColors.warning;
          statusIcon = Icons.warning_amber_rounded;
          statusText = 'Stok Fisik Lebih Sedikit';
        } else {
          bgColor = AppColors.stockInBg;
          accentColor = AppColors.stockIn;
          statusIcon = Icons.add_circle_outline;
          statusText = 'Stok Fisik Berlebih (Surplus)';
        }

        final String qtyText;
        final String valueText;
        if (_isVarianceZero) {
          qtyText = '0 $unit';
          valueText = 'Rp0';
        } else if (_isDeficit) {
          qtyText = '$_variance $unit';
          valueText = '-${CurrencyFormatter.format(_varianceValue.abs())}';
        } else {
          qtyText = '+$_variance $unit';
          valueText = '+${CurrencyFormatter.format(_varianceValue.abs())}';
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, size: 20, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'HPP @${CurrencyFormatter.format(purchasePrice)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kuantitas Selisih',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            qtyText,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              fontFamily: 'monospace',
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nilai Penyesuaian',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            valueText,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              fontFamily: 'monospace',
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Reason Selector ─────────────────────────────────────────────────
  Widget _buildReasonSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alasan Selisih',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: _selectedReason,
                builder: (context, selectedReason, _) {
                  return Text(
                    selectedReason == null ? 'Wajib diisi' : 'Dipilih',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selectedReason == null
                          ? AppColors.stockOut
                          : AppColors.stockIn,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<String?>(
            valueListenable: _selectedReason,
            builder: (context, selectedReason, _) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reasons.map((reason) {
                  final isSelected = selectedReason == reason;
                  return Material(
                    color: isSelected
                        ? AppColors.primaryAccent
                        : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap: () => _selectReason(reason),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                        ),
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

  // ── Audit Note Input ────────────────────────────────────────────────
  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Pemeriksaan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLength: _maxNoteLength,
            decoration: InputDecoration(
              hintText: 'cth: Ditemukan 2 botol bocor di gudang belakang',
              filled: true,
              fillColor: AppColors.surfaceSubtle,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Keterangan audit internal',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                ListenableBuilder(
                  listenable: _noteController,
                  builder: (context, _) {
                    return Text(
                      '${_noteController.text.length}/$_maxNoteLength',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Submit Bar ───────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 48,
            child: ListenableBuilder(
              listenable: Listenable.merge([
                _isLoading,
                _selectedProduct,
                _actualStock,
                _systemStock,
                _selectedReason,
              ]),
              builder: (context, _) {
                final isLoading = _isLoading.value;
                final canSubmit = _canSubmit;

                return ElevatedButton(
                  onPressed: (isLoading || !canSubmit) ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceContainer,
                    disabledForegroundColor: AppColors.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Penyesuaian Opname',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
