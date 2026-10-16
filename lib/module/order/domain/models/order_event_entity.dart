class OrderEvent {
  final String id;
  final String userId;
  final String orderId;
  final String eventType;
  final String? actorId;
  final String? actorName;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const OrderEvent({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.eventType,
    this.actorId,
    this.actorName,
    this.metadata = const {},
    required this.createdAt,
  });

  String get eventTitle {
    switch (eventType.toUpperCase()) {
      case 'ORDER_CREATED':
        return 'Pesanan Dibuat';
      case 'PICKING_STARTED':
        return 'Picking Dimulai';
      case 'ITEM_PICKED':
        return 'Barang Berhasil Diambil';
      case 'PHOTO_SUBMITTED':
      case 'SUBMITTED_FOR_VERIFICATION':
        return 'Foto Bukti Dikirim';
      case 'VERIFICATION_PASSED':
      case 'VERIFIED':
        return 'Verifikasi Disetujui';
      case 'VERIFICATION_FAILED':
        return 'Verifikasi Ditolak / Perlu Re-pick';
      case 'RE_PICKING_STARTED':
        return 'Mulai Ambil Ulang (Re-picking)';
      case 'PACKING_STARTED':
        return 'Mulai Proses Packing';
      case 'READY_FOR_COURIER':
      case 'READY':
        return 'Paket Siap Menunggu Kurir';
      case 'HANDED_TO_COURIER':
      case 'DONE':
        return 'Diserahkan ke Kurir (Selesai)';
      case 'ORDER_CANCELLED':
        return 'Pesanan Dibatalkan';
      case 'ORDER_UPDATED':
        return 'Pesanan Diperbarui';
      default:
        return eventType.replaceAll('_', ' ');
    }
  }
}
