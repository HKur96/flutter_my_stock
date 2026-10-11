import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';

class AppCircleAvatar extends StatelessWidget {
  final String name;
  const AppCircleAvatar({super.key, required this.name, });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ChuckerFlutter.showChuckerScreen(),
      child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
    );
  }
}