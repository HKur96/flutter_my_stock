import 'package:flutter/material.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/product_log.dart';

class LogItemCard extends StatelessWidget {
  final ProductLog item;

  const LogItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isIn = item.productLogType == ProductLogType.stockIn;
    final isStockTransaction =
        item.productLogType == ProductLogType.stockIn ||
        item.productLogType == ProductLogType.stockOut;

    // Config per log type
    final IconData iconData;
    final Color iconColor;
    final Color iconBgColor;

    switch (item.productLogType) {
      case ProductLogType.stockIn:
        iconData = Icons.arrow_downward_rounded;
        iconColor = AppColors.stockIn;
        iconBgColor = AppColors.stockInBg;
        break;
      case ProductLogType.stockOut:
        iconData = Icons.arrow_upward_rounded;
        iconColor = AppColors.stockOut;
        iconBgColor = AppColors.stockOutBg;
        break;
      case ProductLogType.create:
        iconData = Icons.add_circle_outline_rounded;
        iconColor = AppColors.primaryAccent;
        iconBgColor = AppColors.primaryLight;
        break;
      case ProductLogType.update:
        iconData = Icons.edit_outlined;
        iconColor = AppColors.warning;
        iconBgColor = AppColors.warningBg;
        break;
      case ProductLogType.delete:
        iconData = Icons.delete_outline_rounded;
        iconColor = AppColors.stockOut;
        iconBgColor = AppColors.stockOutBg;
        break;
      default:
        iconData = Icons.info_outline_rounded;
        iconColor = AppColors.textMuted;
        iconBgColor = AppColors.inputBg;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${item.sku}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isStockTransaction)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isIn ? AppColors.stockInBg : AppColors.stockOutBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isIn ? AppColors.stockInBorder : AppColors.stockOutBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${isIn ? "+" : ""}${item.stockDifferent}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isIn ? AppColors.stockIn : AppColors.stockOut,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.productLogType.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ),
            ],
          ),
          if ((item.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Catatan: ${item.note}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.pic.isEmpty ? 'System' : item.pic,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.dayHours(item.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
