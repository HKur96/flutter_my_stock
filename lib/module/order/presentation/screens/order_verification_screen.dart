import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/module/orders/data/models/order_item_entity.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';

class OrderVerificationScreen extends StatefulWidget {
  final OrderEntity? order;
  final VoidCallback? onApproveAll;
  final Function(List<Map<String, dynamic>> rejectedItems)? onRejectMismatch;
  final VoidCallback? onRequestRetakePhoto;

  const OrderVerificationScreen({
    super.key,
    this.order,
    this.onApproveAll,
    this.onRejectMismatch,
    this.onRequestRetakePhoto,
  });

  @override
  State<OrderVerificationScreen> createState() => _OrderVerificationScreenState();
}

class _OrderVerificationScreenState extends State<OrderVerificationScreen> {
  late OrderEntity _order;
  final Map<String, _ItemCheckResult> _checkedResults = {};

  @override
  void initState() {
    super.initState();
    _order = widget.order ?? MockOrderData.sampleOrders[1];
    for (var item in _order.items) {
      _checkedResults[item.id] = _ItemCheckResult(isMatch: true);
    }
  }

  void _showMismatchDialog(OrderItem item) {
    VerificationReason selectedReason = VerificationReason.wrongItem;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tandai Masalah: ${item.nameSnapshot}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border),
                  const Text('Pilih Alasan Ketidaksesuaian:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<VerificationReason>(
                    value: selectedReason,
                    items: VerificationReason.values.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r.label, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedReason = val);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceSubtle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Catatan Koreksi untuk Operator:'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Yang diambil ukuran S, seharusnya M...',
                      filled: true,
                      fillColor: AppColors.surfaceSubtle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _checkedResults[item.id] = _ItemCheckResult(
                            isMatch: false,
                            reason: selectedReason,
                            note: noteController.text.trim(),
                          );
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBA1A1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Simpan Masalah Item'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _order.latestVerification?.photoUrl ??
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=800';

    final hasMismatch = _checkedResults.values.any((r) => !r.isMatch);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Verifikasi Order #${_order.orderNumber}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      final rejectedList = _checkedResults.entries
                          .where((e) => !e.value.isMatch)
                          .map((e) => {
                                'order_item_id': e.key,
                                'reason': e.value.reason?.value ?? 'WRONG_ITEM',
                                'note': e.value.note ?? '',
                              })
                          .toList();

                      if (rejectedList.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tandai setidaknya satu item bermasalah terlebih dahulu.'),
                          ),
                        );
                        return;
                      }

                      widget.onRejectMismatch?.call(rejectedList);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFBA1A1A),
                      side: const BorderSide(color: Color(0xFFBA1A1A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Ada Masalah',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: hasMismatch
                        ? null
                        : () {
                            widget.onApproveAll?.call();
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Semua Sesuai (Lanjut)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.stockIn,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
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
            // 1. Photo Viewer with zoom capability
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.5,
                    child: Image.network(
                      photoUrl,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 240,
                        color: AppColors.surfaceSubtle,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.zoom_in, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Cubit untuk Zoom',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Retake photo trigger
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: widget.onRequestRetakePhoto,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Foto Buram? Minta Foto Ulang', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Checklist Header
            const Text(
              'Cocokkan Barang dengan Foto',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Periksa fisik barang pada foto. Jika ada varian atau jumlah salah, tandai item bersangkutan.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            // 3. Checklist Items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _order.items[index];
                final check = _checkedResults[item.id] ?? _ItemCheckResult(isMatch: true);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: check.isMatch ? Colors.white : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: check.isMatch ? AppColors.border : const Color(0xFFBA1A1A),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: check.isMatch,
                        activeColor: AppColors.stockIn,
                        onChanged: (val) {
                          if (val == true) {
                            setState(() {
                              _checkedResults[item.id] = _ItemCheckResult(isMatch: true);
                            });
                          } else {
                            _showMismatchDialog(item);
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nameSnapshot,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SKU: ${item.skuSnapshot} • Qty: ${item.quantityRequired} Pcs',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            if (item.variantSnapshot != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Varian: ${item.variantSnapshot}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            if (!check.isMatch) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFDAD6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Masalah: ${check.reason?.label ?? "Salah Barang"} • ${check.note ?? ""}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFBA1A1A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (check.isMatch)
                        IconButton(
                          onPressed: () => _showMismatchDialog(item),
                          icon: const Icon(Icons.edit_note, color: AppColors.textMuted),
                          tooltip: 'Tandai Salah',
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCheckResult {
  final bool isMatch;
  final VerificationReason? reason;
  final String? note;

  _ItemCheckResult({required this.isMatch, this.reason, this.note});
}
