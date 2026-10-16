import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';

/// Status siklus order sesuai database-schema.md
enum OrderStatus {
  queued('QUEUED', 'Antrean', Icons.schedule),
  picking('PICKING', 'Sedang Diambil', Icons.shopping_basket_outlined),
  waitingVerification('WAITING_VERIFICATION', 'Menunggu Verifikasi', Icons.photo_camera_outlined),
  rePicking('RE_PICKING', 'Ambil Ulang', Icons.replay),
  verified('VERIFIED', 'Terverifikasi', Icons.verified_outlined),
  packing('PACKING', 'Sedang Dipacking', Icons.inventory_2_outlined),
  ready('READY', 'Siap Dikirim', Icons.local_shipping_outlined),
  done('DONE', 'Selesai', Icons.check_circle_outline),
  cancelled('CANCELLED', 'Dibatalkan', Icons.cancel_outlined);

  final String value;
  final String label;
  final IconData icon;

  const OrderStatus(this.value, this.label, this.icon);

  static OrderStatus fromString(String? val) {
    if (val == null) return OrderStatus.queued;
    return OrderStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => OrderStatus.queued,
    );
  }

  Color get badgeColor {
    switch (this) {
      case OrderStatus.queued:
        return const Color(0xFFEFEEE7);
      case OrderStatus.picking:
        return const Color(0xFFE0F2FE);
      case OrderStatus.waitingVerification:
        return AppColors.warningBg;
      case OrderStatus.rePicking:
        return const Color(0xFFFFDAD6);
      case OrderStatus.verified:
        return const Color(0xFFE8F8ED);
      case OrderStatus.packing:
        return const Color(0xFFEDE9FE);
      case OrderStatus.ready:
        return const Color(0xFFD1FAE5);
      case OrderStatus.done:
        return AppColors.stockInBg;
      case OrderStatus.cancelled:
        return AppColors.stockOutBg;
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.queued:
        return AppColors.textSecondary;
      case OrderStatus.picking:
        return const Color(0xFF0369A1);
      case OrderStatus.waitingVerification:
        return AppColors.warning;
      case OrderStatus.rePicking:
        return const Color(0xFFBA1A1A);
      case OrderStatus.verified:
        return const Color(0xFF006D30);
      case OrderStatus.packing:
        return const Color(0xFF6D28D9);
      case OrderStatus.ready:
        return const Color(0xFF047857);
      case OrderStatus.done:
        return AppColors.stockIn;
      case OrderStatus.cancelled:
        return AppColors.stockOut;
    }
  }
}

/// Status picking per item
enum PickingStatus {
  pending('PENDING', 'Belum Diambil'),
  partial('PARTIAL', 'Diambil Sebagian'),
  picked('PICKED', 'Sudah Diambil');

  final String value;
  final String label;

  const PickingStatus(this.value, this.label);

  static PickingStatus fromString(String? val) {
    if (val == null) return PickingStatus.pending;
    return PickingStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => PickingStatus.pending,
    );
  }
}

/// Hasil verifikasi foto oleh Owner
enum VerificationResult {
  match('MATCH', 'Semua Sesuai'),
  mismatch('MISMATCH', 'Ada Ketidaksesuaian'),
  damaged('DAMAGED', 'Barang Rusak');

  final String value;
  final String label;

  const VerificationResult(this.value, this.label);

  static VerificationResult fromString(String? val) {
    if (val == null) return VerificationResult.match;
    return VerificationResult.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => VerificationResult.match,
    );
  }
}

/// Alasan reject item sesuai enum verification_reason di database-schema.md
enum VerificationReason {
  wrongItem('WRONG_ITEM', 'Salah Produk / Varian'),
  missingQuantity('MISSING_QUANTITY', 'Jumlah Kurang / Belum Lengkap'),
  damagedItem('DAMAGED_ITEM', 'Fisik Barang Rusak / Cacat'),
  other('OTHER', 'Lainnya');

  final String value;
  final String label;

  const VerificationReason(this.value, this.label);

  static VerificationReason fromString(String? val) {
    if (val == null) return VerificationReason.wrongItem;
    return VerificationReason.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => VerificationReason.wrongItem,
    );
  }
}
