import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';

class OrderVerification {
  final String id;
  final String userId;
  final String orderId;
  final int attemptNumber;
  final String? photoUrl;
  final VerificationResult result;
  final String verifiedBy;
  final DateTime createdAt;
  final List<OrderVerificationItem> verificationItems;

  const OrderVerification({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.attemptNumber,
    this.photoUrl,
    required this.result,
    required this.verifiedBy,
    required this.createdAt,
    this.verificationItems = const [],
  });
}

class OrderVerificationItem {
  final String id;
  final String userId;
  final String verificationId;
  final String orderItemId;
  final VerificationReason reason;
  final String? note;
  final String? itemName;
  final String? itemSku;

  const OrderVerificationItem({
    required this.id,
    required this.userId,
    required this.verificationId,
    required this.orderItemId,
    required this.reason,
    this.note,
    this.itemName,
    this.itemSku,
  });
}
