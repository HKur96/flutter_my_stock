import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/core/utils/date_formatter.dart';

class ProductLog {
  final String id;
  final String productId;
  final String productName;
  final String unit;
  final ProductLogType productLogType;
  final String pic;
  final String? note;
  final Map<String, dynamic> oldData;
  final Map<String, dynamic> newData;
  final DateTime createdAt;

  const ProductLog({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.productLogType,
    required this.pic,
    this.note,
    required this.oldData,
    required this.newData,
    required this.createdAt,
  });

  String get displayCreatedAt => DateFormatter.dayHours(createdAt);

  String get newStock =>
      (newData['current_stock'] ?? oldData['current_stock'] ?? 0).toString();
  String get sku => (newData['sku'] ?? oldData['sku'] ?? productId).toString();

  int get stockDifferent {
    final oldStock = oldData['current_stock'] as int? ?? 0;
    final newStock = newData['current_stock'] as int? ?? 0;
    return newStock - oldStock;
  }

  ProductLog copyWith({
    String? id,
    String? productId,
    String? productName,
    ProductLogType? productLogType,
    String? pic,
    String? note,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    DateTime? createdAt,
  }) {
    return ProductLog(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unit: unit,
      productLogType: productLogType ?? this.productLogType,
      pic: pic ?? this.pic,
      note: note ?? this.note,
      oldData: oldData ?? this.oldData,
      newData: newData ?? this.newData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
