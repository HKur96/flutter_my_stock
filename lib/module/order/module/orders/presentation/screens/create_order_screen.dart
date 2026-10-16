import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/extensions.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/core/widgets/barcode_scanner_screen.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/module/orders/presentation/provider/orders_provider.dart';
import 'package:flutter_catat_stok/module/order/module/orders/presentation/widgets/stepper_header_delegate.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/stock/presentation/widgets/product_search_delegate.dart';
import 'package:provider/provider.dart';

class CreateOrderScreen extends StatefulWidget {
  final Future<OrderEntity?> Function({
    required String orderNumber,
    String? marketplace,
    String? customerNote,
    required List<Map<String, dynamic>> items,
  })?
  onCreateOrder;
  final VoidCallback? onCancel;

  const CreateOrderScreen({super.key, this.onCreateOrder, this.onCancel});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final TextEditingController _orderIdController = TextEditingController(
    text: 'ORD-2024-1049',
  );
  final TextEditingController _notesController = TextEditingController(
    text: 'Mohon lapis bubble wrap tebal, kirim sebelum jam 14:00 WIB',
  );

  final _formKey = GlobalKey<FormState>();

  // Reactive State Notifiers - no setState needed!
  final ValueNotifier<int> _indexPage = ValueNotifier(0);
  final ValueNotifier<bool> _reverseSwitch = ValueNotifier(false);
  final ValueNotifier<String> _selectedChannel = ValueNotifier('Shopee');
  final ValueNotifier<bool> _isSaving = ValueNotifier(false);
  final ValueNotifier<List<Product>> _items = ValueNotifier<List<Product>>([]);
  final ValueNotifier<Map<String, int>> _quantities =
      ValueNotifier<Map<String, int>>({});

  final List<String> _channels = [
    'Shopee',
    'Tokopedia',
    'TikTok Shop',
    'Lainnya',
  ];

  @override
  void dispose() {
    _orderIdController.dispose();
    _notesController.dispose();
    _indexPage.dispose();
    _reverseSwitch.dispose();
    _selectedChannel.dispose();
    _isSaving.dispose();
    _items.dispose();
    _quantities.dispose();
    super.dispose();
  }

  Future<void> _scanOrderBarcode() async {
    try {
      final code = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
      );
      if (code != null && code.isNotEmpty) {
        _orderIdController.text = code;
      }
    } catch (_) {
      final simulatedId =
          'MP-${(100000 + (DateTime.now().millisecondsSinceEpoch % 900000))}';
      _orderIdController.text = simulatedId;
    }
  }

  void _adjustQty(Product product, int delta) {
    final currentQty = _quantities.value[product.id] ?? 1;
    final newQty = currentQty + delta;
    final maxStock = product.currentStock > 0 ? product.currentStock : 99;
    if (newQty >= 1 && newQty <= maxStock) {
      final updated = Map<String, int>.from(_quantities.value);
      updated[product.id] = newQty;
      _quantities.value = updated;
    }
  }

  void _removeItem(Product product) {
    final currentList = List<Product>.of(_items.value);
    currentList.removeWhere((p) => p.id == product.id);
    final updated = Map<String, int>.from(_quantities.value);
    updated.remove(product.id);
    _quantities.value = updated;
    _items.value = currentList;
  }

  void _openProductSearch() async {
    final selected = await showSearch<Product?>(
      context: context,
      delegate: ProductSearchDelegate(),
    );

    if (!mounted) return;

    if (selected != null) {
      _addProductToOrder(selected);
    }
  }

  void _addProductToOrder(Product product) {
    final currentList = List<Product>.of(_items.value);
    final existingIndex = currentList.indexWhere((i) => i.id == product.id);
    if (existingIndex != -1) {
      final currentQty = _quantities.value[product.id] ?? 1;
      final maxStock = product.currentStock > 0 ? product.currentStock : 99;
      if (currentQty < maxStock) {
        final updated = Map<String, int>.from(_quantities.value);
        updated[product.id] = currentQty + 1;
        _quantities.value = updated;
      }
    } else {
      currentList.add(product);
      final updated = Map<String, int>.from(_quantities.value);
      updated[product.id] = 1;
      _quantities.value = updated;
      _items.value = currentList;
    }
  }

  Future<void> _handleSaveOrder() async {
    final orderNum = _orderIdController.text.trim();
    if (orderNum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor Pesanan wajib diisi.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_items.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wajib menambahkan minimal 1 produk sebelum menyimpan pesanan.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    _isSaving.value = true;

    try {
      final itemsPayload = _items.value.map((product) {
        final qty = _quantities.value[product.id] ?? 1;
        return {
          'product_id': product.id,
          'sku_snapshot': product.sku,
          'name_snapshot': product.name,
          'variant_snapshot': product.unit.name.isNotEmpty
              ? product.unit.name
              : 'Standar',
          'location_snapshot': 'Gudang Utama',
          'photo_snapshot': product.imageUrl,
          'quantity_required': qty,
        };
      }).toList();

      if (widget.onCreateOrder != null) {
        await widget.onCreateOrder!(
          orderNumber: orderNum,
          marketplace: _selectedChannel.value,
          customerNote: _notesController.text.trim(),
          items: itemsPayload,
        );
      } else {
        final provider = context.read<OrdersProvider>();
        await provider.createOrder(
          orderNumber: orderNum,
          marketplace: _selectedChannel.value,
          customerNote: _notesController.text.trim(),
          items: itemsPayload,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pesanan #$orderNum berhasil dibuat dan masuk antrean!',
          ),
          backgroundColor: AppColors.stockIn,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pesanan: $e'),
          backgroundColor: AppColors.stockOut,
        ),
      );
    } finally {
      if (mounted) {
        _isSaving.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            widget.onCancel?.call();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Tambah Pesanan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [_buildStepperHeader(), _buildFormBody()],
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field 1: Order ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Nomor Pesanan ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: AppColors.stockOut),
                    ),
                  ],
                ),
              ),
              const Text(
                'Wajib diisi',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _orderIdController,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: MP-8910248',
              filled: true,
              fillColor: AppColors.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    color: AppColors.textSecondary,
                    tooltip: 'Salin ID',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    color: AppColors.primaryAccent,
                    tooltip: 'Scan Barcode Resi',
                    onPressed: _scanOrderBarcode,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Masukkan kode pesanan marketplace atau scan barcode fisik airway bill / label paket.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Field 2: Marketplace Channel Selector
          Row(
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Saluran Marketplace ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: AppColors.stockOut),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: _selectedChannel,
            builder: (context, selectedChannel, _) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _channels.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 44,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) {
                  final channel = _channels[idx];
                  final isSelected = selectedChannel == channel;

                  return InkWell(
                    onTap: () => _selectedChannel.value = channel,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryAccent
                            : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.border,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              channel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Field 3: Order Notes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Catatan Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Opsional',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText:
                  'Mohon lapis bubble wrap tebal, kirim sebelum jam 14:00 WIB...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Produk Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: _openProductSearch,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add, size: 16, color: AppColors.primaryAccent),
                      SizedBox(width: 4),
                      Text(
                        'Tambah Produk',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Product Rows or Empty State (Granular rebuild via ValueListenableBuilder)
          ValueListenableBuilder<List<Product>>(
            valueListenable: _items,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 36,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada produk dipilih',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ketuk tombol "+ Tambah Produk" di atas untuk mencari.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 12),

                  // System Rule Note
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Aturan Sistem: Produk duplikat dicegah otomatis. Cukup sesuaikan kuantitas pada daftar item.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      return _buildProductRow(item);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(Product item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        if (item.categoryName.isNotEmpty) ...[
                          Text(
                            'Kategori: ${item.categoryName}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Text(
                            '•',
                            style: TextStyle(color: AppColors.border),
                          ),
                        ],
                        Text(
                          'SKU: ${item.sku}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          '•',
                          style: TextStyle(color: AppColors.border),
                        ),
                        Text(
                          'Stok: ${item.currentStock} ${item.unit.name.isNotEmpty ? item.unit.name : 'pcs'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.isLowStock
                                ? AppColors.stockOut
                                : AppColors.stockIn,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                tooltip: 'Hapus produk',
                onPressed: () => _removeItem(item),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah Pengambilan:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: ValueListenableBuilder<Map<String, int>>(
                  valueListenable: _quantities,
                  builder: (context, quantities, _) {
                    final qty = quantities[item.id] ?? 1;
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () => _adjustQty(item, -1),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '$qty',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () => _adjustQty(item, 1),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String>(
            valueListenable: _selectedChannel,
            builder: (context, selectedChannel, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Channel Terpilih',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedChannel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<Product>>(
            valueListenable: _items,
            builder: (context, items, _) {
              final skuCount = items.length;
              return ValueListenableBuilder<Map<String, int>>(
                valueListenable: _quantities,
                builder: (context, quantities, _) {
                  final totalQty = items.fold<int>(
                    0,
                    (sum, p) => sum + (quantities[p.id] ?? 1),
                  );

                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Jenis Produk',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$skuCount SKU',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Kuantitas Fisik',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$totalQty Pcs',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pending_actions_rounded,
                  size: 20,
                  color: AppColors.primaryAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          const Text(
                            'Status Awal Pesanan:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Antrean Pesanan (Perlu Picking)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pesanan baru langsung dicatat ke antrean gudang tanpa otomatis memulai sesi picking fisik sebelum diambil oleh staf picker.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _indexPage,
              builder: (context, indexPage, child) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: (indexPage == 0)
                    ? const SizedBox.shrink()
                    : TextButton.icon(
                        key: const ValueKey('btn_kembali'),
                        onPressed: () {
                          _reverseSwitch.value = true;
                          _indexPage.value -= 1;
                        },
                        icon: const Icon(Icons.chevron_left_rounded),
                        label: const Text('Kembali'),
                        style: TextButton.styleFrom(
                          foregroundColor: context.onBackground,
                        ),
                      ),
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _indexPage,
              builder: (context, indexPage, _) {
                if (indexPage > 1) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _isSaving,
                    builder: (context, isSaving, _) {
                      return ElevatedButton(
                        key: const ValueKey('btn_simpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isSaving ? null : _handleSaveOrder,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSaving) ...[
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ] else ...[
                              const Icon(Icons.save_outlined, size: 18),
                              const SizedBox(width: 6),
                            ],
                            Text(isSaving ? 'Menyimpan...' : 'Simpan Pesanan'),
                          ],
                        ),
                      );
                    },
                  );
                }

                return TextButton(
                  key: const ValueKey('btn_selanjutnya'),
                  onPressed: () {
                    _reverseSwitch.value = false;
                    _indexPage.value += 1;
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.onBackground,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Selanjutnya'),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right),
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

  ValueListenableBuilder<int> _buildStepperHeader() {
    return ValueListenableBuilder(
      valueListenable: _indexPage,
      builder: (_, indexPage, __) {
        return SliverPersistentHeader(
          pinned: true,
          delegate: StepperHeaderDelegate(indexPage),
        );
      },
    );
  }

  Widget _buildFormBody() {
    return Form(
      key: _formKey,
      child: ValueListenableBuilder<int>(
        valueListenable: _indexPage,
        builder: (context, indexPage, child) => PageTransitionSwitcher(
          duration: const Duration(milliseconds: 150),
          reverse: _reverseSwitch.value,
          layoutBuilder: (entries) {
            Widget builder = Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
              child: Stack(alignment: Alignment.topCenter, children: entries),
            );
            return SliverToBoxAdapter(child: builder);
          },
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: context.background,
              child: child,
            );
          },
          child: (indexPage == 0)
              ? _buildOrderInfoSection()
              : (indexPage == 1)
              ? _buildProductListSection()
              : _buildOrderSummarySection(),
        ),
      ),
    );
  }
}
