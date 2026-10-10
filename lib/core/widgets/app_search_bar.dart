import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textMuted,
          size: 20,
        ),
        suffixIcon: hasQuery
            ? IconButton(
                icon: const Icon(
                  Icons.cancel_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
