import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';

class AppDialogConfirmation {
  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String cancelText,
    required String confirmText,
    required Function onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Center(child: Text(cancelText))),
              ),
              Expanded(
                flex: 3,
                child: Material(
                  color: AppColors.stockOut,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      onConfirm();
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        confirmText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              // TextButton(
              //   onPressed: () => Navigator.pop(ctx),
              //   child: Text(cancelText),
              // ),
              // Expanded(
              //   child: ElevatedButton(
              //     onPressed: () {
              //       onConfirm();
              //       Navigator.pop(ctx);
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.stockOut,
              //     ),
              //     child: Text(confirmText),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
