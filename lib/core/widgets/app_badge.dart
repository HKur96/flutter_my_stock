import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppBadgeVariant { primary, success, danger, warning, info, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;
  final Color? customBgColor;
  final Color? customTextColor;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
    this.customBgColor,
    this.customTextColor,
  });

  factory AppBadge.success({required String label, IconData? icon}) {
    return AppBadge(
      label: label,
      variant: AppBadgeVariant.success,
      icon: icon,
    );
  }

  factory AppBadge.danger({required String label, IconData? icon}) {
    return AppBadge(
      label: label,
      variant: AppBadgeVariant.danger,
      icon: icon,
    );
  }

  factory AppBadge.warning({required String label, IconData? icon}) {
    return AppBadge(
      label: label,
      variant: AppBadgeVariant.warning,
      icon: icon,
    );
  }

  factory AppBadge.primary({required String label, IconData? icon}) {
    return AppBadge(
      label: label,
      variant: AppBadgeVariant.primary,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final bgColor = customBgColor ?? colors.bgColor;
    final textColor = customTextColor ?? colors.textColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: colors.borderColor != null
            ? Border.all(color: colors.borderColor!, width: 0.8)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _getColors() {
    switch (variant) {
      case AppBadgeVariant.primary:
        return _BadgeColors(
          bgColor: AppColors.primaryLight,
          textColor: AppColors.primary,
          borderColor: AppColors.primaryAccent.withValues(alpha: 0.3),
        );
      case AppBadgeVariant.success:
        return _BadgeColors(
          bgColor: AppColors.stockInBg,
          textColor: AppColors.stockIn,
          borderColor: AppColors.stockInBorder,
        );
      case AppBadgeVariant.danger:
        return _BadgeColors(
          bgColor: AppColors.stockOutBg,
          textColor: AppColors.stockOut,
          borderColor: AppColors.stockOutBorder,
        );
      case AppBadgeVariant.warning:
        return _BadgeColors(
          bgColor: AppColors.warningBg,
          textColor: AppColors.warning,
          borderColor: AppColors.warningBorder,
        );
      case AppBadgeVariant.info:
        return _BadgeColors(
          bgColor: AppColors.infoBg,
          textColor: AppColors.info,
        );
      case AppBadgeVariant.neutral:
        return _BadgeColors(
          bgColor: AppColors.surfaceContainerHigh,
          textColor: AppColors.textSecondary,
          borderColor: AppColors.border,
        );
    }
  }
}

class _BadgeColors {
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;

  _BadgeColors({
    required this.bgColor,
    required this.textColor,
    this.borderColor,
  });
}
