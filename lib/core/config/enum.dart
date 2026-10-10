enum PickCategoryType { initial, manage }

enum ProductLogType {
  all,
  create,
  update,
  delete,
  stockIn,
  stockOut;

  static ProductLogType fromValue(String value) {
    switch (value.replaceAll('_', '').toUpperCase()) {
      case 'CREATE':
        return ProductLogType.create;
      case 'UPDATE':
        return ProductLogType.update;
      case 'DELETE':
        return ProductLogType.delete;
      case 'STOCKIN':
        return ProductLogType.stockIn;
      case 'STOCKOUT':
        return ProductLogType.stockOut;
      default:
        return ProductLogType.create;
    }
  }

  String get displayName => switch (this) {
    ProductLogType.all => 'Semua',
    ProductLogType.create => 'Buat',
    ProductLogType.update => 'Edit',
    ProductLogType.delete => 'Hapus',
    ProductLogType.stockIn => 'Stok Masuk (+)',
    ProductLogType.stockOut => 'Stok Keluar (-)',
  };
}

enum StockTransactionType {
  stockIn,
  stockOut,
  opname;

  static String toValue(StockTransactionType type) {
    switch (type) {
      case StockTransactionType.stockIn:
        return 'IN';
      case StockTransactionType.stockOut:
        return 'OUT';
      case StockTransactionType.opname:
        return 'OPNAME';
    }
  }

  static StockTransactionType fromValue(String value) {
    switch (value) {
      case 'IN':
        return StockTransactionType.stockIn;
      case 'OUT':
        return StockTransactionType.stockOut;
      case 'OPNAME':
        return StockTransactionType.opname;
      default:
        return StockTransactionType.opname;
    }
  }
}

enum UnitType { pcs, unit, bungkus, rim, box, kg, liter;
  static UnitType fromValue(String value) {
    switch (value.toUpperCase()) {
      case 'PCS':
        return UnitType.pcs;
      case 'UNIT':
        return UnitType.unit;
      case 'BUNGKUS':
        return UnitType.bungkus;
      case 'RIM':
        return UnitType.rim;
      case 'BOX':
        return UnitType.box;
      case 'KG':
        return UnitType.kg;
      case 'LITER':
        return UnitType.liter;
      default:
        return UnitType.pcs;
    }
  }
   }
