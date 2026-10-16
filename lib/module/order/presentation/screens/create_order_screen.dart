import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/core/widgets/barcode_scanner_screen.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/module/orders/presentation/provider/orders_provider.dart';
import 'package:flutter_catat_stok/module/product/presentation/provider/product_provider.dart';
import 'package:provider/provider.dart';

class CreateOrderItem {
  final String productId;
  final String name;
  final String sku;
  final String? variant;
  final String location;
  final String? photoUrl;
  final int maxStock;
  int quantity;

  CreateOrderItem({
    required this.productId,
    required this.name,
    required this.sku,
    this.variant,
    this.location = 'Gudang Utama',
    this.photoUrl,
    required this.maxStock,
    this.quantity = 1,
  });

  Map<String, dynamic> toOrderItemMap() {
    return {
      'product_id': productId,
      'sku_snapshot': sku,
      'name_snapshot': name,
      'variant_snapshot': variant,
      'location_snapshot': location,
      'photo_snapshot': photoUrl,
      'quantity_required': quantity,
    };
  }
}

class CreateOrderScreen extends StatefulWidget {
  final Future<OrderEntity?> Function({
    required String orderNumber,
    String? marketplace,
    String? customerNote,
    required List<Map<String, dynamic>> items,
  })? onCreateOrder;
  final VoidCallback? onCancel;

  const CreateOrderScreen({
    super.key,
    this.onCreateOrder,
    this.onCancel,
  });

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
  final TextEditingController _quickSearchController = TextEditingController();

  String _selectedChannel = 'Shopee';
  bool _isSaving = false;

  // Status notification toast
  String? _toastMessage;
  String? _toastTitle;
  IconData? _toastIcon;
  Color _toastBgColor = AppColors.surfaceContainer;
  Color _toastTextColor = AppColors.textPrimary;
  Color _toastIconColor = AppColors.primary;
  bool _showToast = false;

  final List<String> _channels = [
    'Shopee',
    'Tokopedia',
    'TikTok Shop',
    'Lainnya',
  ];

  late List<CreateOrderItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _getSampleItems();
    _showToastBanner(
      title: 'Nomor Pesanan Disalin',
      desc: 'Nomor "ORD-2024-1049" disalin ke papan klip.',
      icon: Icons.check,
      bg: AppColors.surfaceContainer,
      text: AppColors.textPrimary,
      iconColor: AppColors.primary,
    );
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _notesController.dispose();
    _quickSearchController.dispose();
    super.dispose();
  }

  List<CreateOrderItem> _getSampleItems() {
    return [
      CreateOrderItem(
        productId: 'prod-1',
        name: 'Indomie Goreng Spesial 85g',
        sku: 'IND-GRG-SP-85',
        variant: 'Standar',
        location: 'Rak A-02',
        photoUrl:
            'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=400',
        maxStock: 48,
        quantity: 4,
      ),
      CreateOrderItem(
        productId: 'prod-2',
        name: 'Minyak Goreng Bimoli Klasik 2L',
        sku: 'BIM-2L-PC',
        variant: 'Botol 2L',
        location: 'Rak B-04',
        photoUrl:
            'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400',
        maxStock: 12,
        quantity: 2,
      ),
      CreateOrderItem(
        productId: 'prod-3',
        name: 'Gulaku Gula Pasir Kuning 1kg',
        sku: 'GLK-KNG-1KG',
        variant: 'Kuning 1kg',
        location: 'Rak C-01',
        photoUrl:
            'https://images.unsplash.com/photo-1581441363689-1f3c3c414635?w=400',
        maxStock: 30,
        quantity: 5,
      ),
    ];
  }

  void _showToastBanner({
    required String title,
    required String desc,
    required IconData icon,
    Color bg = AppColors.surfaceContainer,
    Color text = AppColors.textPrimary,
    Color iconColor = AppColors.primary,
  }) {
    setState(() {
      _toastTitle = title;
      _toastMessage = desc;
      _toastIcon = icon;
      _toastBgColor = bg;
      _toastTextColor = text;
      _toastIconColor = iconColor;
      _showToast = true;
    });
  }

  int get _totalSkuCount => _items.length;
  int get _totalItemQuantity => _items.fold(0, (sum, e) => sum + e.quantity);

  void _copyOrderId() {
    final text = _orderIdController.text.trim();
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      _showToastBanner(
        title: 'Nomor Pesanan Disalin',
        desc: 'Nomor "$text" disalin ke papan klip.',
        icon: Icons.check,
        bg: AppColors.surfaceContainer,
        text: AppColors.textPrimary,
        iconColor: AppColors.primary,
      );
    }
  }

  Future<void> _scanOrderBarcode() async {
    try {
      final code = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
      );
      if (code != null && code.isNotEmpty) {
        _orderIdController.text = code;
        _showToastBanner(
          title: 'Barcode Terpindai',
          desc: 'Nomor resi otomatis diisi: $code',
          icon: Icons.qr_code_scanner,
          bg: AppColors.stockInBg,
          text: AppColors.stockIn,
          iconColor: AppColors.stockIn,
        );
      }
    } catch (_) {
      final simulatedId =
          'MP-${(100000 + (DateTime.now().millisecondsSinceEpoch % 900000))}';
      _orderIdController.text = simulatedId;
      _showToastBanner(
        title: 'Barcode Terpindai (Simulasi)',
        desc: 'Nomor resi otomatis diisi: $simulatedId',
        icon: Icons.qr_code_scanner,
        bg: AppColors.stockInBg,
        text: AppColors.stockIn,
        iconColor: AppColors.stockIn,
      );
    }
  }

  void _adjustQty(int index, int delta) {
    setState(() {
      final item = _items[index];
      final newQty = item.quantity + delta;
      if (newQty >= 1 && newQty <= item.maxStock) {
        item.quantity = newQty;
      }
    });
  }

  void _removeItem(int index) {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
    });
    _showToastBanner(
      title: 'Produk Dihapus',
      desc: '"${removed.name}" telah dihapus dari pesanan.',
      icon: Icons.delete_outline,
      bg: AppColors.surfaceContainer,
      text: AppColors.textPrimary,
      iconColor: AppColors.stockOut,
    );
  }

  void _restoreSampleItems() {
    setState(() {
      _items = _getSampleItems();
    });
    _showToastBanner(
      title: 'Demo Dimuat Ulang',
      desc: '3 produk demo berhasil ditambahkan kembali.',
      icon: Icons.refresh,
      bg: AppColors.infoBg,
      text: AppColors.info,
      iconColor: AppColors.info,
    );
  }

  void _openAddProductBottomSheet() {
    final productProvider = context.read<ProductProvider>();
    final catalog = productProvider.products;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = catalog.where((p) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return p.name.toLowerCase().contains(q) ||
                  p.sku.toLowerCase().contains(q);
            }).toList();

            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Produk dari Gudang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama produk atau SKU...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.surfaceSubtle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 40,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  catalog.isEmpty
                                      ? 'Katalog produk kosong'
                                      : 'Produk tidak ditemukan',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: AppColors.border),
                            itemBuilder: (context, idx) {
                              final p = filtered[idx];
                              final isAlreadyInOrder = _items
                                  .any((item) => item.productId == p.id);

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  'SKU: ${p.sku} • Stok: ${p.currentStock}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                trailing: isAlreadyInOrder
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.stockInBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Ditambahkan',
                                          style: TextStyle(
                                            color: AppColors.stockIn,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _addProductToOrder(
                                            productId: p.id,
                                            name: p.name,
                                            sku: p.sku,
                                            variant: 'Standar',
                                            stock: p.currentStock,
                                            photoUrl: p.imageUrl,
                                          );
                                        },
                                        child: const Text('Tambah'),
                                      ),
                              );
                            },
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

  void _addProductToOrder({
    required String productId,
    required String name,
    required String sku,
    String? variant,
    required int stock,
    String? photoUrl,
  }) {
    final existingIndex = _items.indexWhere((i) => i.productId == productId);
    if (existingIndex != -1) {
      _adjustQty(existingIndex, 1);
      _showToastBanner(
        title: 'Kuantitas Ditingkatkan',
        desc: 'Jumlah item "$name" ditambah 1 pcs.',
        icon: Icons.check,
        bg: AppColors.surfaceContainer,
        text: AppColors.textPrimary,
        iconColor: AppColors.primary,
      );
    } else {
      setState(() {
        _items.add(
          CreateOrderItem(
            productId: productId,
            name: name,
            sku: sku,
            variant: variant ?? 'Standar',
            location: 'Gudang Utama',
            photoUrl: photoUrl,
            maxStock: stock > 0 ? stock : 99,
            quantity: 1,
          ),
        );
      });
      _showToastBanner(
        title: 'Produk Ditambahkan',
        desc: '"$name" berhasil masuk ke pesanan.',
        icon: Icons.add_circle_outline,
        bg: AppColors.stockInBg,
        text: AppColors.stockIn,
        iconColor: AppColors.stockIn,
      );
    }
  }

  Future<void> _handleSaveOrder() async {
    final orderNum = _orderIdController.text.trim();
    if (orderNum.isEmpty) {
      _showToastBanner(
        title: 'Validasi Gagal',
        desc: 'Nomor Pesanan wajib diisi.',
        icon: Icons.warning_amber_rounded,
        bg: AppColors.warningBg,
        text: AppColors.warning,
        iconColor: AppColors.warning,
      );
      return;
    }

    if (_items.isEmpty) {
      _showToastBanner(
        title: 'Validasi Gagal',
        desc: 'Wajib menambahkan minimal 1 produk sebelum menyimpan pesanan.',
        icon: Icons.warning_amber_rounded,
        bg: AppColors.warningBg,
        text: AppColors.warning,
        iconColor: AppColors.warning,
      );
      return;
    }

    setState(() => _isSaving = true);
    _showToastBanner(
      title: 'Menyimpan Pesanan...',
      desc: 'Mengirim data ke sistem dan memperbarui antrean picking.',
      icon: Icons.sync,
      bg: AppColors.surfaceContainer,
      text: AppColors.textPrimary,
      iconColor: AppColors.primary,
    );

    try {
      final itemsPayload = _items.map((e) => e.toOrderItemMap()).toList();

      if (widget.onCreateOrder != null) {
        await widget.onCreateOrder!(
          orderNumber: orderNum,
          marketplace: _selectedChannel,
          customerNote: _notesController.text.trim(),
          items: itemsPayload,
        );
      } else {
        // Fallback to OrdersProvider
        final provider = context.read<OrdersProvider>();
        await provider.createOrder(
          orderNumber: orderNum,
          marketplace: _selectedChannel,
          customerNote: _notesController.text.trim(),
          items: itemsPayload,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan #$orderNum berhasil dibuat dan masuk antrean!'),
          backgroundColor: AppColors.stockIn,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showToastBanner(
        title: 'Gagal Menyimpan',
        desc: 'Terjadi kesalahan: $e',
        icon: Icons.error_outline,
        bg: AppColors.stockOutBg,
        text: AppColors.stockOut,
        iconColor: AppColors.stockOut,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Notification Toast
            if (_showToast && _toastMessage != null) ...[
              _buildToastNotification(),
              const SizedBox(height: 12),
            ],

            // Section 1: Informasi Pesanan
            _buildOrderInfoSection(),
            const SizedBox(height: 16),

            // Section 2: Daftar Produk Pesanan
            _buildProductListSection(),
            const SizedBox(height: 16),

            // Section 3: Ringkasan Pesanan
            _buildOrderSummarySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildToastNotification() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _toastBgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_toastIcon, size: 20, color: _toastIconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _toastTitle ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _toastTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _toastMessage ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: _toastTextColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.close,
              size: 16,
              color: _toastTextColor.withValues(alpha: 0.6),
            ),
            onPressed: () => setState(() => _showToast = false),
          ),
        ],
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
                    onPressed: _copyOrderId,
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
          GridView.builder(
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
              final isSelected = _selectedChannel == channel;

              return InkWell(
                onTap: () => setState(() => _selectedChannel = channel),
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
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Daftar Produk Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _openAddProductBottomSheet,
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
                      Icon(
                        Icons.add,
                        size: 16,
                        color: AppColors.primaryAccent,
                      ),
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

          const SizedBox(height: 12),

          // Quick Search / Scan Bar
          TextField(
            controller: _quickSearchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari nama produk atau SKU...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textMuted,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Scan Barcode Produk',
                onPressed: () async {
                  final code = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BarcodeScannerScreen(),
                    ),
                  );
                  if (code != null) {
                    _quickSearchController.text = code;
                  }
                },
              ),
              filled: true,
              fillColor: AppColors.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // System Rule Note
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warningBg.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock_outline, size: 16, color: AppColors.warning),
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

          // Product Rows or Empty State
          if (_items.isEmpty)
            _buildEmptyProductState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final item = _items[idx];
                return _buildProductRow(item, idx);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyProductState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 24,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Belum ada produk dipilih',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cari dan tambahkan produk dari katalog stok gudang melalui tombol di atas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryAccent,
              elevation: 0,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: _restoreSampleItems,
            icon: const Icon(Icons.replay, size: 16),
            label: const Text('Muat Ulang Item Demo'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(CreateOrderItem item, int index) {
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
                        if (item.variant != null) ...[
                          Text(
                            'Varian: ${item.variant}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Text('•',
                              style: TextStyle(color: AppColors.border)),
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
                        const Text('•',
                            style: TextStyle(color: AppColors.border)),
                        Text(
                          'Stok: ${item.maxStock} pcs',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.stockIn,
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
                onPressed: () => _removeItem(index),
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
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () => _adjustQty(index, -1),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
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
                      onPressed: () => _adjustQty(index, 1),
                    ),
                  ],
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
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
                        '$_totalSkuCount SKU',
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
                        '$_totalItemQuantity Pcs',
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
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(80, 48),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: AppColors.textPrimary,
              ),
              onPressed: () {
                widget.onCancel?.call();
                Navigator.pop(context);
              },
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSaving ? null : _handleSaveOrder,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Pesanan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
