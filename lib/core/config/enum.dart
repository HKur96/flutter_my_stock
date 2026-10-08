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

  String get displayName => switch(this) {
    ProductLogType.all => 'Semua',
    ProductLogType.create => 'Buat',
    ProductLogType.update => 'Edit',
    ProductLogType.delete => 'Hapus',
    ProductLogType.stockIn => 'Stok Masuk (+)',
    ProductLogType.stockOut => 'Stok Keluar (-)',
  };
}
