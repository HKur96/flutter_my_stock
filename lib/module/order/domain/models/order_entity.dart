import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_event_entity.dart';
import 'package:flutter_catat_stok/module/order/module/orders/data/models/order_item_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_verification_entity.dart';

class OrderEntity {
  final String id;
  final String userId;
  final String orderNumber;
  final String? marketplace;
  final String? customerNote;
  final OrderStatus status;
  final int version;
  final int? queuePosition;
  final String? cancelReason;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final List<OrderEvent> events;
  final List<OrderVerification> verifications;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.orderNumber,
    this.marketplace,
    this.customerNote,
    this.status = OrderStatus.queued,
    this.version = 1,
    this.queuePosition,
    this.cancelReason,
    this.completedAt,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.events = const [],
    this.verifications = const [],
  });

  int get totalQuantityRequired =>
      items.fold(0, (sum, item) => sum + item.quantityRequired);

  int get totalQuantityPicked =>
      items.fold(0, (sum, item) => sum + item.quantityPicked);

  int get totalItemsCount => items.length;

  int get fullyPickedItemsCount =>
      items.where((item) => item.isFullyPicked).length;

  bool get isAllItemsPicked =>
      items.isNotEmpty && items.every((item) => item.isFullyPicked);

  double get pickingProgress {
    if (totalQuantityRequired == 0) return 0.0;
    return (totalQuantityPicked / totalQuantityRequired).clamp(0.0, 1.0);
  }

  OrderVerification? get latestVerification {
    if (verifications.isEmpty) return null;
    return verifications.reduce((curr, next) =>
        curr.attemptNumber > next.attemptNumber ? curr : next);
  }

  OrderEntity copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    String? marketplace,
    String? customerNote,
    OrderStatus? status,
    int? version,
    int? queuePosition,
    String? cancelReason,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    List<OrderEvent>? events,
    List<OrderVerification>? verifications,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      marketplace: marketplace ?? this.marketplace,
      customerNote: customerNote ?? this.customerNote,
      status: status ?? this.status,
      version: version ?? this.version,
      queuePosition: queuePosition ?? this.queuePosition,
      cancelReason: cancelReason ?? this.cancelReason,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      events: events ?? this.events,
      verifications: verifications ?? this.verifications,
    );
  }
}
