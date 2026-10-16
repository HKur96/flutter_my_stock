import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/order/module/orders/data/models/order_item_entity.dart';

class PickingItemTile extends StatelessWidget {
  final OrderItem item;
  final int itemNumber;
  final int totalItems;
  final VoidCallback? onMarkPicked;
  final VoidCallback? onAdjustQuantity;
  final VoidCallback? onReportIssue;
  final VoidCallback? onTap;
  final bool isRePick;

  const PickingItemTile({
    super.key,
    required this.item,
    required this.itemNumber,
    required this.totalItems,
    this.onMarkPicked,
    this.onAdjustQuantity,
    this.onReportIssue,
    this.onTap,
    this.isRePick = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = item.isFullyPicked;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDone ? AppColors.surfaceSubtle : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRePick
                ? const Color(0xFFBA1A1A)
                : isDone
                    ? AppColors.border
                    : AppColors.primaryLight,
            width: isRePick ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Item sequence & location badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isRePick
                        ? const Color(0xFFFFDAD6)
                        : isDone
                            ? AppColors.stockInBg
                            : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isRePick
                        ? 'PERLU DI-REPICK'
                        : 'BARANG $itemNumber DARI $totalItems',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isRePick
                          ? const Color(0xFFBA1A1A)
                          : isDone
                              ? AppColors.stockIn
                              : AppColors.primary,
                    ),
                  ),
                ),
                // Location badge (Rak)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shelves, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        item.locationSnapshot,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle row: Product photo & info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail foto
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surfaceSubtle,
                    child: item.photoSnapshot != null && item.photoSnapshot!.isNotEmpty
                        ? Image.network(
                            item.photoSnapshot!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.textMuted,
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.textMuted,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name, SKU, variant
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nameSnapshot,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SKU: ${item.skuSnapshot}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (item.variantSnapshot != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.variantSnapshot!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress / Quantity counter
                      RichText(
                        text: TextSpan(
                          text: 'Diambil: ',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: '${item.quantityPicked} ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDone ? AppColors.stockIn : AppColors.primary,
                              ),
                            ),
                            TextSpan(
                              text: '/ ${item.quantityRequired} Pcs',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom action bar
            Row(
              children: [
                if (onReportIssue != null && !isDone)
                  IconButton(
                    onPressed: onReportIssue,
                    icon: const Icon(Icons.report_problem_outlined, color: AppColors.warning, size: 20),
                    tooltip: 'Lapor Kurang / Rusak',
                  ),
                if (onAdjustQuantity != null && !isDone)
                  OutlinedButton(
                    onPressed: onAdjustQuantity,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: const Text('Sebagian', style: TextStyle(fontSize: 11)),
                  ),
                const Spacer(),
                if (onMarkPicked != null)
                  ElevatedButton.icon(
                    onPressed: onMarkPicked,
                    icon: Icon(
                      isDone ? Icons.check : Icons.done_all,
                      size: 16,
                    ),
                    label: Text(isDone ? 'Sudah Diambil' : 'Tandai Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDone ? AppColors.stockIn : AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
