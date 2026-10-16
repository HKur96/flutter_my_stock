import 'dart:typed_data';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_event_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_summary.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_verification_entity.dart';

abstract class OrderRepository {
  /// Mendapatkan daftar seluruh pesanan dengan pagination, filter status, dan search
  Future<List<OrderEntity>> getOrders({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    OrderStatus? status,
  });

  /// Mengambil satu pesanan lengkap berdasarkan ID beserta item, picking, dan timeline
  Future<OrderEntity?> getOrderById(String orderId);

  /// Mengambil pesanan aktif tunggal yang sedang dikerjakan operator
  Future<OrderEntity?> getActiveOrderForOperator();

  /// Mengambil daftar antrean pesanan aktif berdasarkan urutan FIFO
  Future<List<OrderEntity>> getOrderQueue();

  /// Mengambil ringkasan jumlah pesanan per status pada pipeline operasional
  Future<OrderPipelineSummary> getOrderPipelineSummary();

  /// Membuat pesanan baru ke antrean (Owner)
  Future<OrderEntity> createOrder({
    required String orderNumber,
    String? marketplace,
    String? customerNote,
    required List<Map<String, dynamic>> items,
  });

  /// Memperbarui status pesanan dengan kontrol concurrency (version check)
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    required int currentVersion,
    String? reason,
  });

  /// Operator memperbarui progres picking untuk satu item pesanan
  Future<bool> updateItemPicking({
    required String orderItemId,
    required int quantityPicked,
    required PickingStatus status,
  });

  /// Operator mengunggah foto hasil picking untuk diverifikasi
  Future<String?> uploadVerificationPhoto(Uint8List bytes, String fileName);

  /// Operator mengajukan foto bukti verifikasi ke Owner
  Future<OrderVerification> submitVerification({
    required String orderId,
    required String photoUrl,
    required int attemptNumber,
  });

  /// Owner memverifikasi foto (setuju MATCH atau tolak MISMATCH/DAMAGED dengan rincian item)
  Future<bool> reviewVerification({
    required String verificationId,
    required String orderId,
    required VerificationResult result,
    required int currentVersion,
    List<Map<String, dynamic>> rejectedItems = const [],
  });

  /// Menyelesaikan pesanan saat kurir mengambil paket (DONE & auto stock out)
  Future<bool> completeOrder({
    required String orderId,
    required int currentVersion,
  });

  /// Membatalkan pesanan oleh Owner
  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
    required int currentVersion,
  });

  /// Mendapatkan riwayat event audit pesanan
  Future<List<OrderEvent>> getOrderEvents(String orderId);
}
