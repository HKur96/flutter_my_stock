import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/presentation/widgets/mock_order_data.dart';

class PackingDetailScreen extends StatefulWidget {
  final OrderEntity? order;
  final VoidCallback? onFinishPacking;

  const PackingDetailScreen({
    super.key,
    this.order,
    this.onFinishPacking,
  });

  @override
  State<PackingDetailScreen> createState() => _PackingDetailScreenState();
}

class _PackingDetailScreenState extends State<PackingDetailScreen> {
  late OrderEntity _order;
  bool _checkBubbleWrap = false;
  bool _checkLabelResi = false;
  bool _checkLakbanKardus = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order ?? MockOrderData.sampleOrders[3];
  }

  bool get _isAllChecklistDone =>
      _checkBubbleWrap && _checkLabelResi && _checkLakbanKardus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Proses Packing #${_order.orderNumber}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              onPressed: _isAllChecklistDone
                  ? () {
                      widget.onFinishPacking?.call();
                      Navigator.pop(context);
                    }
                  : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Selesai Packing (Paket Siap)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            // Packaging standard warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD8B4FE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Color(0xFF6D28D9)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan barang dibungkus aman sesuai standar toko sebelum menyerahkan ke kurir.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4C1D95)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Checklist section
            const Text(
              'Standar Keamanan Packing',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Bubble Wrap Berlapis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Barang rentan/pecah dibungkus minimal 2-3 lapis', style: TextStyle(fontSize: 11)),
                    value: _checkBubbleWrap,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _checkBubbleWrap = val ?? false),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  CheckboxListTile(
                    title: const Text('Label Resi / Marketplace Ditempel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Barcode resi terlihat jelas tanpa tertutup lakban', style: TextStyle(fontSize: 11)),
                    value: _checkLabelResi,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _checkLabelResi = val ?? false),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  CheckboxListTile(
                    title: const Text('Lakban Rapi & Rapat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Kardus/polymailer tertutup rapat dari air/debu', style: TextStyle(fontSize: 11)),
                    value: _checkLakbanKardus,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _checkLakbanKardus = val ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Items checklist
            Text(
              'Isi Barang dalam Paket (${_order.items.length} Macam)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _order.items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.stockIn, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nameSnapshot, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('SKU: ${item.skuSnapshot} • Qty: ${item.quantityRequired} Pcs', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
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
