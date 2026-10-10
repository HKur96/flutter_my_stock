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
  Product? _selectedProduct;
  int _actualStock = 0;
  int _systemStock = 0;
  String? _selectedReason;
  final _noteController = TextEditingController();
  bool _isLoading = false;

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
    if (widget.initialProduct != null) {
      _selectedProduct = widget.initialProduct;
      _systemStock = _selectedProduct!.currentStock;
      _actualStock = _systemStock;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  int get _variance => _actualStock - _systemStock;
  double get _varianceValue =>
      _selectedProduct != null
          ? _variance * _selectedProduct!.purchasePrice.toDouble()
          : 0;

  bool get _isVarianceZero => _variance == 0;
  bool get _isDeficit => _variance < 0;

  bool get _canSubmit {
    if (_selectedProduct == null) return false;
    if (_isVarianceZero) return true;
    return _selectedReason != null;
  }

  void _onProductSelected(Product product) {
    setState(() {
      _selectedProduct = product;
      _systemStock = product.currentStock;
      _actualStock = _systemStock;
      _selectedReason = null;
      _noteController.clear();
    });
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
    if (_selectedProduct == null) return;
    setState(() => _actualStock++);
  }

  void _decrement() {
    if (_selectedProduct == null) return;
    if (_actualStock > 0) {
      setState(() => _actualStock--);
    }
  }

  void _setActualStock(int value) {
    if (_selectedProduct == null) return;
    setState(() => _actualStock = value);
  }

  void _selectReason(String reason) {
    setState(() => _selectedReason = reason);
  }

  Future<void> _handleSubmit() async {
    if (_selectedProduct == null) {
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

    setState(() => _isLoading = true);

    final currentUser = await LocalStorageService().getUser();
    if (currentUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;

    final adjustment = _variance;
    bool success = false;

    if (adjustment > 0) {
      success = await context.read<StockProvider>().stockIn(
        StockTransactionDto(
          userId: currentUser.id,
          productId: _selectedProduct!.id,
          type: StockTransactionType.opname,
          quantity: adjustment,
          createdAt: DateTime.now(),
          reason: _selectedReason,
          note: 'Opname: ${_noteController.text.trim()}',
        ),
      );
    } else if (adjustment < 0) {
      success = await context.read<StockProvider>().stockOut(
        StockTransactionDto(
          userId: currentUser.id,
          productId: _selectedProduct!.id,
          type: StockTransactionType.opname,
          quantity: adjustment.abs(),
          createdAt: DateTime.now(),
          reason: _selectedReason,
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                _buildProductSelectorCard(),
                const SizedBox(height: 12),
                if (_selectedProduct != null) ...[
                  _buildStepperCard(),
                  const SizedBox(height: 12),
                  _buildVarianceCard(),
                  const SizedBox(height: 12),
                  if (!_isVarianceZero) ...[
                    _buildReasonSelector(),
                    const SizedBox(height: 12),
                  ],
                  _buildNoteInput(),
                ],
              ],
            ),
          ),
          if (_selectedProduct != null) _buildBottomBar(),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Stok Opname'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Cari Produk',
          onPressed: _openProductSearch,
        ),
        if (_selectedProduct != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
              color: AppColors.surfaceCard,
            ),
            child: Text(
              _selectedProduct!.sku,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
      ],
    );
  }

  // ── Product Selector Card ───────────────────────────────────────────
  Widget _buildProductSelectorCard() {
    final p = _selectedProduct;

    if (p == null) {
      return AppCard(
        onTap: _openProductSearch,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text(
                  'Ganti',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // System stock reference bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      '$_systemStock',
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
  }

  // ── Stepper Card ────────────────────────────────────────────────────
  Widget _buildStepperCard() {
    final unit = _selectedProduct?.unit ?? 'pcs';
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
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
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
                _buildStepperButton(
                  icon: Icons.remove,
                  onTap: _decrement,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$_actualStock',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                          letterSpacing: -1,
                          height: 1,
                        ),
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
                _buildStepperButton(
                  icon: Icons.add,
                  onTap: _increment,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPresetButton(label: '0 (Nol)', value: 0),
              const SizedBox(width: 8),
              _buildPresetButton(
                label: '$_systemStock (Sistem)',
                value: _systemStock,
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
    final unit = _selectedProduct?.unit ?? 'pcs';
    final purchasePrice = _selectedProduct?.purchasePrice.toDouble() ?? 0;

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              Text(
                _selectedReason == null ? 'Wajib diisi' : 'Dipilih',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _selectedReason == null
                      ? AppColors.stockOut
                      : AppColors.stockIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasons.map((reason) {
              final isSelected = _selectedReason == reason;
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
            onChanged: (_) => setState(() {}),
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
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Keterangan audit internal',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '${_noteController.text.length}/$_maxNoteLength',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
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
            child: ElevatedButton(
              onPressed: (_isLoading || !_canSubmit) ? null : _handleSubmit,
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
              child: _isLoading
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
            ),
          ),
        ),
      ),
    );
  }
}
