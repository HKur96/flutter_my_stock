import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, danger, success, warning }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? customBackgroundColor;
  final Color? customForegroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.customBackgroundColor,
    this.customForegroundColor,
  });

  // Factory Constructors for Quick Usage
  factory AppButton.primary({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  factory AppButton.secondary({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  factory AppButton.outline({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.outline,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  factory AppButton.danger({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.danger,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  factory AppButton.small({
    required String text,
    VoidCallback? onPressed,
    AppButtonVariant variant = AppButtonVariant.primary,
    bool isLoading = false,
    IconData? prefixIcon,
    Color? customBackgroundColor,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: variant,
      size: AppButtonSize.small,
      isLoading: isLoading,
      isFullWidth: false,
      prefixIcon: prefixIcon,
      customBackgroundColor: customBackgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    final height = _getHeight();

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: size == AppButtonSize.small ? 14 : 18,
            height: size == AppButtonSize.small ? 14 : 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: colors.foreground,
            ),
          ),
          const SizedBox(width: 8),
        ] else ...[
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: size == AppButtonSize.small ? 16 : 20, color: colors.foreground),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: textStyle.copyWith(color: colors.foreground),
          ),
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            Icon(suffixIcon, size: size == AppButtonSize.small ? 16 : 20, color: colors.foreground),
          ],
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: customBackgroundColor ?? colors.background,
          foregroundColor: customForegroundColor ?? colors.foreground,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size == AppButtonSize.small ? 8 : 12),
            side: colors.borderSide,
          ),
        ),
        child: buttonContent,
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case AppButtonVariant.primary:
        return _ButtonColors(
          background: AppColors.primary,
          foreground: Colors.white,
          borderSide: BorderSide.none,
        );
      case AppButtonVariant.secondary:
        return _ButtonColors(
          background: AppColors.primaryLight,
          foreground: AppColors.primary,
          borderSide: BorderSide.none,
        );
      case AppButtonVariant.outline:
        return _ButtonColors(
          background: AppColors.surface,
          foreground: AppColors.textPrimary,
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        );
      case AppButtonVariant.danger:
        return _ButtonColors(
          background: AppColors.stockOut,
          foreground: Colors.white,
          borderSide: BorderSide.none,
        );
      case AppButtonVariant.success:
        return _ButtonColors(
          background: AppColors.stockIn,
          foreground: Colors.white,
          borderSide: BorderSide.none,
        );
      case AppButtonVariant.warning:
        return _ButtonColors(
          background: AppColors.warning,
          foreground: Colors.white,
          borderSide: BorderSide.none,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 34;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 54;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.buttonSmall;
      case AppButtonSize.medium:
      case AppButtonSize.large:
        return AppTypography.button;
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final BorderSide borderSide;

  _ButtonColors({
    required this.background,
    required this.foreground,
    required this.borderSide,
  });
}
