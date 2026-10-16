import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';

class OrderItem {
  final String id;
  final String userId;
  final String orderId;
  final String productId;
  final String skuSnapshot;
  final String nameSnapshot;
  final String? variantSnapshot;
  final String locationSnapshot;
  final String? photoSnapshot;
  final int quantityRequired;
  final int quantityPicked;
  final PickingStatus pickingStatus;
  final DateTime? pickedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderItem({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.productId,
    required this.skuSnapshot,
    required this.nameSnapshot,
    this.variantSnapshot,
    required this.locationSnapshot,
    this.photoSnapshot,
    required this.quantityRequired,
    this.quantityPicked = 0,
    this.pickingStatus = PickingStatus.pending,
    this.pickedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFullyPicked => quantityPicked >= quantityRequired;
  int get remainingQuantity => (quantityRequired - quantityPicked).clamp(0, quantityRequired);

  OrderItem copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? productId,
    String? skuSnapshot,
    String? nameSnapshot,
    String? variantSnapshot,
    String? locationSnapshot,
    String? photoSnapshot,
    int? quantityRequired,
    int? quantityPicked,
    PickingStatus? pickingStatus,
    DateTime? pickedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      skuSnapshot: skuSnapshot ?? this.skuSnapshot,
      nameSnapshot: nameSnapshot ?? this.nameSnapshot,
      variantSnapshot: variantSnapshot ?? this.variantSnapshot,
      locationSnapshot: locationSnapshot ?? this.locationSnapshot,
      photoSnapshot: photoSnapshot ?? this.photoSnapshot,
      quantityRequired: quantityRequired ?? this.quantityRequired,
      quantityPicked: quantityPicked ?? this.quantityPicked,
      pickingStatus: pickingStatus ?? this.pickingStatus,
      pickedAt: pickedAt ?? this.pickedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
