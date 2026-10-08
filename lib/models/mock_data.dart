class StockTransaction {
  final String id;
  final String productName;
  final String sku;
  final String type; // 'IN' or 'OUT'
  final int qty;
  final String date;
  final String note;
  final String createdBy;

  StockTransaction({
    required this.id,
    required this.productName,
    required this.sku,
    required this.type,
    required this.qty,
    required this.date,
    required this.note,
    required this.createdBy,
  });
}

class MockData {
  static final List<StockTransaction> transactions = [
    StockTransaction(
      id: 'TRX-8821',
      productName: 'Wireless Mouse Logitech M330',
      sku: 'SKU-ELK-001',
      type: 'IN',
      qty: 20,
      date: '07 Okt 2026, 09:30',
      note: 'Restock dari distributor resmi',
      createdBy: 'Admin Stok',
    ),
    StockTransaction(
      id: 'TRX-8820',
      productName: 'Keyboard Mechanical Keychron K2',
      sku: 'SKU-ELK-002',
      type: 'OUT',
      qty: 5,
      date: '06 Okt 2026, 16:45',
      note: 'Pengiriman pesanan toko B2B',
      createdBy: 'Admin Stok',
    ),
    StockTransaction(
      id: 'TRX-8819',
      productName: 'Kopi Arabika Gayo 250g',
      sku: 'SKU-FNB-001',
      type: 'OUT',
      qty: 12,
      date: '06 Okt 2026, 14:10',
      note: 'Penjualan retail langsung',
      createdBy: 'Kasir',
    ),
    StockTransaction(
      id: 'TRX-8818',
      productName: 'Kertas HVS A4 80gsm PaperOne',
      sku: 'SKU-OFF-001',
      type: 'IN',
      qty: 50,
      date: '05 Okt 2026, 11:20',
      note: 'Pembelian inventaris kantor',
      createdBy: 'Admin Stok',
    ),
  ];
}
