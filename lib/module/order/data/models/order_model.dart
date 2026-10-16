import 'package:flutter_catat_stok/module/order/data/models/order_event_model.dart';
import 'package:flutter_catat_stok/module/order/data/models/order_item_model.dart';
import 'package:flutter_catat_stok/module/order/data/models/order_verification_model.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.orderNumber,
    super.marketplace,
    super.customerNote,
    super.status = OrderStatus.queued,
    super.version = 1,
    super.queuePosition,
    super.cancelReason,
    super.completedAt,
    super.cancelledAt,
    required super.createdAt,
    required super.updatedAt,
    super.items = const [],
    super.events = const [],
    super.verifications = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse order_items
    final rawItems = json['order_items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map<OrderItemModel>(
          (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    // Parse order_events
    final rawEvents = json['order_events'] as List<dynamic>? ?? [];
    final events = rawEvents
        .map<OrderEventModel>(
          (e) => OrderEventModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    // Parse order_verifications
    final rawVerifications = json['order_verifications'] as List<dynamic>? ?? [];
    final verifications = rawVerifications
        .map<OrderVerificationModel>(
          (v) => OrderVerificationModel.fromJson(v as Map<String, dynamic>),
        )
        .toList();

    return OrderModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? '',
      marketplace: json['marketplace'] as String?,
      customerNote: json['customer_note'] as String?,
      status: OrderStatus.fromString(json['status'] as String?),
      version: json['version'] as int? ?? 1,
      queuePosition: json['queue_position'] as int?,
      cancelReason: json['cancel_reason'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      items: items,
      events: events,
      verifications: verifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'marketplace': marketplace,
      'customer_note': customerNote,
      'status': status.value,
      'version': version,
      'queue_position': queuePosition,
      'cancel_reason': cancelReason,
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }
}
