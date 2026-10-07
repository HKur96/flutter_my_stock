import 'package:flutter/material.dart';

late GlobalKey<NavigatorState> gNavigatorKey;

void showFlashError(String message) {
  if (gNavigatorKey.currentContext == null) return;

  ScaffoldMessenger.of(
    gNavigatorKey.currentContext!,
  ).showSnackBar(SnackBar(content: Text(message)));
}
