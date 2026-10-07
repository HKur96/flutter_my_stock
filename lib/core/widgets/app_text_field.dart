import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final TextInputAction textInputAction;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.textInputAction = TextInputAction.next,
  });

  factory AppTextField.password({
    String? label = 'Kata Sandi',
    String? hintText = 'Masukkan kata sandi',
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return AppTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      isPassword: true,
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.textMuted,
      ),
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
    );
  }

  factory AppTextField.search({
    String? hintText = 'Cari...',
    TextEditingController? controller,
    void Function(String)? onChanged,
    VoidCallback? onClear,
    bool hasValue = false,
    void Function(String)? onSubmitted,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return AppTextField(
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
      suffixIcon: hasValue && onClear != null
          ? IconButton(
              icon: const Icon(
                Icons.clear_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
              onPressed: onClear,
            )
          : null,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.label),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
      ],
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;

  const AppDropdownField({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.label),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
