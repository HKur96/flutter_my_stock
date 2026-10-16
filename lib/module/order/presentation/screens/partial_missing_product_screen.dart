import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/module/orders/data/models/order_item_entity.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';

class PartialMissingProductScreen extends StatefulWidget {
  final OrderItem? item;
  final Function(VerificationReason reason, String note, int availableQty)? onSubmitReport;

  const PartialMissingProductScreen({
    super.key,
    this.item,
    this.onSubmitReport,
  });

  @override
  State<PartialMissingProductScreen> createState() => _PartialMissingProductScreenState();
}

class _PartialMissingProductScreenState extends State<PartialMissingProductScreen> {
  late OrderItem _item;
  VerificationReason _selectedReason = VerificationReason.missingQuantity;
  final TextEditingController _noteController = TextEditingController();
  int _availableQty = 0;

  @override
  void initState() {
    super.initState();
    _item = widget.item ?? MockOrderData.sampleItems[1];
    _availableQty = _item.quantityPicked;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lapor Kendala Barang',
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
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onSubmitReport?.call(
                  _selectedReason,
                  _noteController.text.trim(),
                  _availableQty,
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.send),
              label: const Text(
                'Kirim Laporan ke Owner',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Warning Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error_outline, color: Color(0xFFBA1A1A)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Laporan ini akan langsung memberi tahu Owner untuk menentukan tindakan revisi pesanan.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF410002)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Item Info Card
            Container(
              padding: const EdgeInsets.all(14),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${_item.skuSnapshot} • Lokasi: ${_item.locationSnapshot}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Diminta: ${_item.quantityRequired} Pcs',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Select Reason
            const Text(
              'Jenis Kendala',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildReasonRadio(
              VerificationReason.missingQuantity,
              'Stok Kurang / Tidak Lengkap',
              'Barang hanya ada sebagian di rak',
            ),
            _buildReasonRadio(
              VerificationReason.wrongItem,
              'Fisik Kosong / Salah Varian',
              'Barang di rak tidak cocok dengan deskripsi varian',
            ),
            _buildReasonRadio(
              VerificationReason.damagedItem,
              'Fisik Rusak / Cacat',
              'Kemasan bocor, penyok, atau tidak layak kirim',
            ),
            _buildReasonRadio(
              VerificationReason.other,
              'Kendala Lainnya',
              'Tuliskan keterangan detail di bawah',
            ),
            const SizedBox(height: 16),

            // 4. Available quantity stepper if missing
            if (_selectedReason == VerificationReason.missingQuantity) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah Fisik yang Ditemukan:'),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _availableQty > 0
                              ? () => setState(() => _availableQty--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$_availableQty',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _availableQty < _item.quantityRequired
                              ? () => setState(() => _availableQty++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 5. Note text field
            const Text(
              'Catatan Tambahan untuk Owner',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Di rak B-04 hanya tersisa 2 pcs, dus satunya basah...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonRadio(VerificationReason reason, String title, String subtitle) {
    final isSelected = _selectedReason == reason;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedReason = reason;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceSubtle : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<VerificationReason>(
                value: reason,
                groupValue: _selectedReason,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
