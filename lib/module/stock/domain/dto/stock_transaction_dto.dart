import 'package:flutter_catat_stok/core/config/enum.dart';

class StockTransactionDto {
  final String userId;
  final String productId;
  final StockTransactionType type;
  final int? quantity;
  final int? adjustment;
  final int? stockBefore;
  final int? stockAfter;
  final DateTime createdAt;
  final num? purchasePrice;
  final String? reason;
  final String? note;

  const StockTransactionDto({
    required this.userId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.createdAt,
    this.adjustment,
    this.stockBefore,
    this.stockAfter,
    this.purchasePrice,
    this.reason,
    this.note,
  });

  Map<String, dynamic> toJSON() {
    return {
      'user_id': userId,
      'product_id': productId,
      'type': type.name,
      'created_at': createdAt,
      'quantity': quantity,
      'adjustment': adjustment,
      'stock_before': stockBefore,
      'stock_after': stockAfter,
      'purchase_price': purchasePrice,
      'reason': reason,
      'note': note,
    };
  }
}
