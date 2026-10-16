// Mockup design size
import 'dart:math';

import 'package:flutter/material.dart';

const mockupHeight = 852;
const mockupWidth = 393;

extension StringX on String {
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return '';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

extension ScreenUtil on BuildContext {
  // Device information
  double get dw => MediaQuery.of(this).size.width;

  double get dh => MediaQuery.of(this).size.height;

  double get dAspectRatio => MediaQuery.of(this).size.aspectRatio;

  double get statusBarHeight => MediaQuery.of(this).viewPadding.top;

  double get bottomBarHeight => MediaQuery.of(this).viewPadding.bottom;

  double get dPixelRatio => MediaQuery.of(this).devicePixelRatio;

  double get dts => MediaQuery.of(this).textScaleFactor;

  Orientation get orientation => MediaQuery.of(this).orientation;

  bool get isPortrait => orientation == Orientation.portrait;

  bool get isLandscape => orientation == Orientation.landscape;

  // Pixel Perfect Ratio
  double get sw => mockupWidth / dw;

  double get sh => mockupHeight / dh;

  double get ts => dw / mockupWidth;

  double get textScale14 => min(ts, 1.4);

  double get textScale12 => min(ts, 1.2);

  double get textScale11 => min(ts, 1.1);

  double dp(double size) => size / mockupWidth * dw;

  double h(double size) => size / mockupHeight * dh;

  double res(double sizeM, double sizeL) => (isMobile) ? sizeM : sizeL;

  ThemeData get themeData => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Responsive Helper
  bool get isMobile => dw < 600;

  bool get isTablet => dw >= 600;

  bool get isDesktop => dw >= 1100;

  // Padding
  double get pd => isMobile ? 16.0 : 32.0;

  // Text and Color Theme data
  TextTheme get text => Theme.of(this).textTheme;

  Color get primaryColor => Theme.of(this).colorScheme.primary;

  Color get primaryContainer => Theme.of(this).colorScheme.primaryContainer;

  Color get inversePrimary => Theme.of(this).colorScheme.inversePrimary;

  Color get secondaryColor => Theme.of(this).colorScheme.secondary;

  Color get secondaryContainer => Theme.of(this).colorScheme.secondaryContainer;

  Color get tertiaryColor => Theme.of(this).colorScheme.tertiary;

  Color get tertiaryContainer => Theme.of(this).colorScheme.tertiaryContainer;

  Color get surface => Theme.of(this).colorScheme.surface;

  Color get surfaceVariant => Theme.of(this).colorScheme.surfaceVariant;

  Color get inverseSurface => Theme.of(this).colorScheme.inverseSurface;

  Color get errorColor => Theme.of(this).colorScheme.error;

  Color get errorContainer => Theme.of(this).colorScheme.errorContainer;

  Color get background => Theme.of(this).colorScheme.background;

  Color get outline => Theme.of(this).colorScheme.outline;

  Color get hintColor => Theme.of(this).hintColor;

  Color get disableColor => Theme.of(this).disabledColor;

  // Text and Icon Color
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;

  Color get onPrimaryContainer => Theme.of(this).colorScheme.onPrimaryContainer;

  Color get onSecondary => Theme.of(this).colorScheme.onSecondary;

  Color get onSecondaryContainer =>
      Theme.of(this).colorScheme.onSecondaryContainer;

  Color get onTertiary => Theme.of(this).colorScheme.onTertiary;

  Color get onTertiaryContainer =>
      Theme.of(this).colorScheme.onTertiaryContainer;

  Color get onError => Theme.of(this).colorScheme.onError;

  Color get onErrorContainer => Theme.of(this).colorScheme.onErrorContainer;

  Color get onBackground => Theme.of(this).colorScheme.onBackground;

  Color get onSurface => Theme.of(this).colorScheme.onSurface;

  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;

  Color get onInverseSurface => Theme.of(this).colorScheme.onInverseSurface;

  // Widgets theme data
  ElevatedButtonThemeData get elevatedButton =>
      Theme.of(this).elevatedButtonTheme;
}
