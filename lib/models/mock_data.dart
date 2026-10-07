
class ProductItem {
  final String id;
  final String sku;
  final String name;
  final String category;
  final int stock;
  final int minStock;
  final double buyPrice;
  final double sellPrice;
  final String unit;
  final String imageUrl;
  final String description;

  ProductItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.stock,
    required this.minStock,
    required this.buyPrice,
    required this.sellPrice,
    required this.unit,
    required this.imageUrl,
    required this.description,
  });

  bool get isLowStock => stock <= minStock;
}

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
  static final List<ProductItem> products = [
    ProductItem(
      id: 'p1',
      sku: 'SKU-ELK-001',
      name: 'Wireless Mouse Logitech M330',
      category: 'Elektronik',
      stock: 45,
      minStock: 10,
      buyPrice: 150000,
      sellPrice: 210000,
      unit: 'Pcs',
      imageUrl: 'https://picsum.photos/200/200?random=1',
      description:
          'Mouse wireless senyap dengan teknologi 2.4GHz dan daya tahan baterai hingga 24 bulan.',
    ),
    ProductItem(
      id: 'p2',
      sku: 'SKU-ELK-002',
      name: 'Keyboard Mechanical Keychron K2',
      category: 'Elektronik',
      stock: 3,
      minStock: 5,
      buyPrice: 950000,
      sellPrice: 1350000,
      unit: 'Unit',
      imageUrl: 'https://picsum.photos/200/200?random=2',
      description:
          'Keyboard mekanik bluetooth 75% layout dengan Gateron Red Switch.',
    ),
    ProductItem(
      id: 'p3',
      sku: 'SKU-FNB-001',
      name: 'Kopi Arabika Gayo 250g',
      category: 'Makanan & Minuman',
      stock: 8,
      minStock: 15,
      buyPrice: 45000,
      sellPrice: 65000,
      unit: 'Bungkus',
      imageUrl: 'https://picsum.photos/200/200?random=3',
      description:
          'Biji kopi sangrai Arabika dari dataran tinggi Gayo Aceh dengan cita rasa asam lembut.',
    ),
    ProductItem(
      id: 'p4',
      sku: 'SKU-OFF-001',
      name: 'Kertas HVS A4 80gsm PaperOne',
      category: 'Peralatan Kantor',
      stock: 62,
      minStock: 20,
      buyPrice: 42000,
      sellPrice: 52000,
      unit: 'Rim',
      imageUrl: 'https://picsum.photos/200/200?random=4',
      description:
          'Kertas HVS berkualitas tinggi ukuran A4 isi 500 lembar per rim.',
    ),
    ProductItem(
      id: 'p5',
      sku: 'SKU-FSH-001',
      name: 'Kaos Polos Cotton Combed 30s',
      category: 'Pakaian & Fashion',
      stock: 2,
      minStock: 10,
      buyPrice: 30000,
      sellPrice: 55000,
      unit: 'Pcs',
      imageUrl: 'https://picsum.photos/200/200?random=5',
      description:
          'Kaos bahan katun combed 30s nyaman, adem, dan menyerap keringat.',
    ),
  ];

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
