import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_verification_entity.dart';

class OrderVerificationModel extends OrderVerification {
  const OrderVerificationModel({
    required super.id,
    required super.userId,
    required super.orderId,
    required super.attemptNumber,
    super.photoUrl,
    required super.result,
    required super.verifiedBy,
    required super.createdAt,
    super.verificationItems = const [],
  });

  factory OrderVerificationModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_verification_items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map<OrderVerificationItem>(
          (item) => OrderVerificationItemModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return OrderVerificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      attemptNumber: json['attempt_number'] as int? ?? 1,
      photoUrl: json['photo_url'] as String?,
      result: VerificationResult.fromString(json['result'] as String?),
      verifiedBy: json['verified_by'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      verificationItems: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'attempt_number': attemptNumber,
      'photo_url': photoUrl,
      'result': result.value,
      'verified_by': verifiedBy,
    };
  }
}

class OrderVerificationItemModel extends OrderVerificationItem {
  const OrderVerificationItemModel({
    required super.id,
    required super.userId,
    required super.verificationId,
    required super.orderItemId,
    required super.reason,
    super.note,
    super.itemName,
    super.itemSku,
  });

  factory OrderVerificationItemModel.fromJson(Map<String, dynamic> json) {
    return OrderVerificationItemModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      verificationId: json['verification_id'] as String? ?? '',
      orderItemId: json['order_item_id'] as String? ?? '',
      reason: VerificationReason.fromString(json['reason'] as String?),
      note: json['note'] as String?,
      itemName: json['item_name'] as String?,
      itemSku: json['item_sku'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'verification_id': verificationId,
      'order_item_id': orderItemId,
      'reason': reason.value,
      'note': note,
    };
  }
}
