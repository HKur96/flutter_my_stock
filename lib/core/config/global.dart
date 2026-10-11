import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';

/// Shared navigator key — delegates to Chucker's key so both
/// the app (flash messages, navigation) and Chucker (network inspector)
/// use the same navigator.
GlobalKey<NavigatorState> get gNavigatorKey => ChuckerFlutter.navigatorKey;

void showFlashError(String message) {
  if (gNavigatorKey.currentContext == null) return;

  ScaffoldMessenger.of(
    gNavigatorKey.currentContext!,
  ).showSnackBar(SnackBar(content: Text(message)));
}
