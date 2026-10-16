import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/module/orders/data/models/order_item_entity.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.userId,
    required super.orderId,
    required super.productId,
    required super.skuSnapshot,
    required super.nameSnapshot,
    super.variantSnapshot,
    required super.locationSnapshot,
    super.photoSnapshot,
    required super.quantityRequired,
    super.quantityPicked = 0,
    super.pickingStatus = PickingStatus.pending,
    super.pickedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Mengecek apakah data picking di-join dari tabel order_item_pickings
    final pickingList = json['order_item_pickings'];
    Map<String, dynamic>? pickingMap;
    if (pickingList is List && pickingList.isNotEmpty) {
      pickingMap = pickingList.first as Map<String, dynamic>;
    } else if (pickingList is Map<String, dynamic>) {
      pickingMap = pickingList;
    }

    final quantityPicked = pickingMap?['quantity_picked'] as int? ??
        json['quantity_picked'] as int? ??
        0;

    final pickingStatusStr = pickingMap?['status'] as String? ??
        json['picking_status'] as String?;
    final pickingStatus = PickingStatus.fromString(pickingStatusStr);

    final pickedAtStr = pickingMap?['picked_at'] as String? ??
        json['picked_at'] as String?;
    final pickedAt = pickedAtStr != null ? DateTime.tryParse(pickedAtStr) : null;

    return OrderItemModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      skuSnapshot: json['sku_snapshot'] as String? ?? '',
      nameSnapshot: json['name_snapshot'] as String? ?? '',
      variantSnapshot: json['variant_snapshot'] as String?,
      locationSnapshot: json['location_snapshot'] as String? ?? 'Gudang Utama',
      photoSnapshot: json['photo_snapshot'] as String?,
      quantityRequired: json['quantity_required'] as int? ?? 1,
      quantityPicked: quantityPicked,
      pickingStatus: pickingStatus,
      pickedAt: pickedAt,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'product_id': productId,
      'sku_snapshot': skuSnapshot,
      'name_snapshot': nameSnapshot,
      'variant_snapshot': variantSnapshot,
      'location_snapshot': locationSnapshot,
      'photo_snapshot': photoSnapshot,
      'quantity_required': quantityRequired,
    };
  }
}
