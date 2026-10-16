import 'package:flutter_catat_stok/module/order/domain/models/order_event_entity.dart';

class OrderEventModel extends OrderEvent {
  const OrderEventModel({
    required super.id,
    required super.userId,
    required super.orderId,
    required super.eventType,
    super.actorId,
    super.actorName,
    super.metadata = const {},
    required super.createdAt,
  });

  factory OrderEventModel.fromJson(Map<String, dynamic> json) {
    // Profil aktor jika di-join dari profiles
    String? actorName;
    if (json['profiles'] != null && json['profiles'] is Map<String, dynamic>) {
      actorName = json['profiles']['name'] as String?;
    }

    return OrderEventModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      eventType: json['event_type'] as String? ?? 'UNKNOWN',
      actorId: json['actor_id'] as String?,
      actorName: actorName,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'event_type': eventType,
      'actor_id': actorId,
      'metadata': metadata,
    };
  }
}
