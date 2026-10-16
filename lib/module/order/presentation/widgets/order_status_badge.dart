import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isDense;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDense ? 6 : 10,
        vertical: isDense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: status.badgeColor,
        borderRadius: BorderRadius.circular(isDense ? 4 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: isDense ? 12 : 14,
            color: status.textColor,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.textColor,
              fontSize: isDense ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
