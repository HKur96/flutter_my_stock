import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/module/stock/domain/models/product_log.dart';

class ProductLogModel extends ProductLog {
  ProductLogModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.productLogType,
    required super.pic,
    super.note,
    required super.oldData,
    required super.newData,
    required super.createdAt,
    required super.unit,
  });

  factory ProductLogModel.fromJson(Map<String, dynamic> json) {
    return ProductLogModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productLogType: ProductLogType.fromValue(json['action'] ?? ''),
      pic: json['pic'] ?? 'User',
      note: json['note'],
      oldData: json['old_data'] != null
          ? Map<String, dynamic>.from(json['old_data'])
          : {},
      newData: json['new_data'] != null
          ? Map<String, dynamic>.from(json['new_data'])
          : {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      unit: json['products']['unit'] ?? 'pcs',
    );
  }
}
