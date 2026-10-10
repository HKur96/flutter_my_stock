import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Brand & Accents (Stitch Warm Utilitarian & Dark Teal)
  static const Color primary = Color(0xFF00433D); // Deep Teal
  static const Color primaryAccent = Color(0xFF005C55); // Primary Container
  static const Color primaryLight = Color(0xFFA7F0E6); // Light Mint Tint
  static const Color primaryDark = Color(0xFF00201D);

  // Stock Mutations
  static const Color stockIn = Color(0xFF006D30); // Emerald Green
  static const Color stockInBg = Color(0xFFE8F8ED); // Emerald Light Subtlety
  static const Color stockInBorder = Color(0xFF98F4A7);

  static const Color stockOut = Color(0xFFA50710); // Rich Crimson Red
  static const Color stockOutBg = Color(0xFFFDE8E8); // Crimson Light Subtlety
  static const Color stockOutBorder = Color(0xFFFFDAD6);

  // States & Warnings
  static const Color warning = Color(0xFFB45309); // Amber
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color info = Color(0xFF005323);
  static const Color infoBg = Color(0xFFE8F8ED);

  // Neutral Surfaces & Backgrounds (Warm Canvas)
  static const Color background = Color(0xFFFBF9F2); // Warm Utilitarian Canvas
  static const Color surface = Color(0xFFFBF9F2);
  static const Color surfaceCard = Colors.white;
  static const Color surfaceContainer = Color(0xFFEFEEE7);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E1);
  static const Color surfaceSubtle = Color(0xFFF5F4ED);

  // Typography
  static const Color textPrimary = Color(0xFF1B1C18); // Charcoal Slate
  static const Color textSecondary = Color(0xFF3F4947);
  static const Color textMuted = Color(0xFF6F7977);
  static const Color textOnPrimary = Colors.white;

  // Borders & Dividers
  static const Color border = Color(0xFFE4E2DC); // Hairline border
  static const Color borderSubtle = Color(0xFFEFEEE7);
  static const Color inputBg = Color(0xFFFFFFFF);

  static Color shimmerBaseColor = Colors.grey.shade300;
  static Color shimmerHighlightColor = Colors.grey.shade100;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryAccent,
        surface: AppColors.surfaceCard,
        error: AppColors.stockOut,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 20),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.stockOut),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.stockOut, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
