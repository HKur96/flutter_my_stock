import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_summary.dart';

class OrderPipelineScroller extends StatelessWidget {
  final OrderPipelineSummary summary;
  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?>? onStatusSelected;

  const OrderPipelineScroller({
    super.key,
    required this.summary,
    this.selectedStatus,
    this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _PipelineItem(OrderStatus.queued, summary.queuedCount),
      _PipelineItem(OrderStatus.picking, summary.pickingCount),
      _PipelineItem(OrderStatus.waitingVerification, summary.waitingVerificationCount),
      _PipelineItem(OrderStatus.rePicking, summary.rePickingCount),
      _PipelineItem(OrderStatus.verified, summary.verifiedCount),
      _PipelineItem(OrderStatus.packing, summary.packingCount),
      _PipelineItem(OrderStatus.ready, summary.readyCount),
      _PipelineItem(OrderStatus.done, summary.doneCount),
      _PipelineItem(OrderStatus.cancelled, summary.cancelledCount),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items.map((item) {
          final isSelected = selectedStatus == item.status;
          final isFlagged = (item.status == OrderStatus.waitingVerification ||
                  item.status == OrderStatus.rePicking) &&
              item.count > 0;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                if (onStatusSelected != null) {
                  onStatusSelected!(isSelected ? null : item.status);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(minWidth: 78),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isFlagged
                          ? (item.status == OrderStatus.waitingVerification
                              ? AppColors.warningBg
                              : const Color(0xFFFFDAD6))
                          : AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isFlagged
                            ? (item.status == OrderStatus.waitingVerification
                                ? AppColors.warningBorder
                                : const Color(0xFFFFB4AB))
                            : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.status.value,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isSelected
                            ? Colors.white
                            : isFlagged
                                ? (item.status == OrderStatus.waitingVerification
                                    ? AppColors.warning
                                    : const Color(0xFFBA1A1A))
                                : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.count}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isFlagged
                                    ? (item.status == OrderStatus.waitingVerification
                                        ? AppColors.warning
                                        : const Color(0xFFBA1A1A))
                                    : AppColors.textPrimary,
                          ),
                        ),
                        if (isFlagged)
                          Icon(
                            item.status == OrderStatus.waitingVerification
                                ? Icons.warning_amber_rounded
                                : Icons.priority_high_rounded,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : (item.status == OrderStatus.waitingVerification
                                    ? AppColors.warning
                                    : const Color(0xFFBA1A1A)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PipelineItem {
  final OrderStatus status;
  final int count;

  _PipelineItem(this.status, this.count);
}
