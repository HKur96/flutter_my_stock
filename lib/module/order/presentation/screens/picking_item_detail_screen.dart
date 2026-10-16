import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/module/orders/data/models/order_item_entity.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';

class PickingItemDetailScreen extends StatefulWidget {
  final OrderItem? item;
  final Function(int quantityPicked, PickingStatus status)? onSavePicking;
  final VoidCallback? onReportIssue;

  const PickingItemDetailScreen({
    super.key,
    this.item,
    this.onSavePicking,
    this.onReportIssue,
  });

  @override
  State<PickingItemDetailScreen> createState() => _PickingItemDetailScreenState();
}

class _PickingItemDetailScreenState extends State<PickingItemDetailScreen> {
  late int _pickedQuantity;
  late OrderItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item ?? MockOrderData.sampleItems[1];
    _pickedQuantity = _item.quantityPicked;
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _pickedQuantity >= _item.quantityRequired;
    final isPartial = _pickedQuantity > 0 && !isDone;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Pengambilan Barang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final status = isDone
                        ? PickingStatus.picked
                        : isPartial
                            ? PickingStatus.partial
                            : PickingStatus.pending;
                    widget.onSavePicking?.call(_pickedQuantity, status);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: Text(
                    isDone ? 'Simpan - Selesai Diambil' : 'Simpan Kuantitas ($_pickedQuantity Pcs)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone ? AppColors.stockIn : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (widget.onReportIssue != null)
                TextButton.icon(
                  onPressed: widget.onReportIssue,
                  icon: const Icon(Icons.report_problem_outlined, color: AppColors.warning, size: 18),
                  label: const Text(
                    'Lapor Barang Kurang / Rusak / Tidak Ketemu',
                    style: TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Large Photo Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 220,
                color: AppColors.surfaceSubtle,
                child: _item.photoSnapshot != null
                    ? Image.network(
                        _item.photoSnapshot!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Location Spotlight Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shelves, color: AppColors.stockIn, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LOKASI RAK FISIK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.stockIn,
                          ),
                        ),
                        Text(
                          _item.locationSnapshot,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Product Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _item.nameSnapshot,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SKU: ${_item.skuSnapshot}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_item.variantSnapshot != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Varian: ${_item.variantSnapshot}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Quantity Picker Stepper
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kuantitas Diambil',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Target: ${_item.quantityRequired} Pcs',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _pickedQuantity > 0
                            ? () {
                                setState(() {
                                  _pickedQuantity--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline, size: 36),
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$_pickedQuantity',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: _pickedQuantity < _item.quantityRequired
                            ? () {
                                setState(() {
                                  _pickedQuantity++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline, size: 36),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isDone)
                    const Text(
                      '✓ Sesuai dengan permintaan pesanan',
                      style: TextStyle(fontSize: 12, color: AppColors.stockIn, fontWeight: FontWeight.w600),
                    )
                  else if (isPartial)
                    const Text(
                      '⚠ Kurang dari kuantitas yang diminta (Partial Picking)',
                      style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
