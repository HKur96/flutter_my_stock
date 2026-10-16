import 'dart:typed_data';
import 'package:flutter_catat_stok/core/services/local_storage_service.dart';
import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/order/data/models/order_event_model.dart';
import 'package:flutter_catat_stok/module/order/data/models/order_model.dart';
import 'package:flutter_catat_stok/module/order/data/models/order_verification_model.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_enums.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_event_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_summary.dart';
import 'package:flutter_catat_stok/module/order/domain/models/order_verification_entity.dart';
import 'package:flutter_catat_stok/module/order/domain/repository/order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepositoryImpl implements OrderRepository {
  SupabaseClient get _client => SupabaseService.client;

  static const String _orderSelectQuery = '''
    id,
    user_id,
    order_number,
    marketplace,
    customer_note,
    status,
    version,
    queue_position,
    cancel_reason,
    completed_at,
    cancelled_at,
    created_at,
    updated_at,
    order_items(
      id,
      user_id,
      order_id,
      product_id,
      sku_snapshot,
      name_snapshot,
      variant_snapshot,
      location_snapshot,
      photo_snapshot,
      quantity_required,
      created_at,
      updated_at,
      order_item_pickings(
        id,
        quantity_picked,
        status,
        picked_at,
        updated_at
      )
    ),
    order_events(
      id,
      user_id,
      order_id,
      event_type,
      actor_id,
      metadata,
      created_at
    ),
    order_verifications(
      id,
      user_id,
      order_id,
      attempt_number,
      photo_url,
      result,
      verified_by,
      created_at,
      order_verification_items(
        id,
        user_id,
        verification_id,
        order_item_id,
        reason,
        note
      )
    )
  ''';

  @override
  Future<List<OrderEntity>> getOrders({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    OrderStatus? status,
  }) async {
    try {
      final int from = (page - 1) * limit;
      final int to = from + limit - 1;

      var query = _client.from('orders').select(_orderSelectQuery);

      if (status != null) {
        query = query.eq('status', status.value);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        query = query.or('order_number.ilike.%$q%,marketplace.ilike.%$q%,customer_note.ilike.%$q%');
      }

      final res = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return (res as List<dynamic>)
          .map<OrderEntity>((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    try {
      final res = await _client
          .from('orders')
          .select(_orderSelectQuery)
          .eq('id', orderId)
          .maybeSingle();

      if (res == null) return null;
      return OrderModel.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<OrderEntity?> getActiveOrderForOperator() async {
    try {
      // Cari order yang sedang dikerjakan terlebih dahulu
      final inProgress = await _client
          .from('orders')
          .select(_orderSelectQuery)
          .inFilter('status', [
            OrderStatus.picking.value,
            OrderStatus.waitingVerification.value,
            OrderStatus.rePicking.value,
            OrderStatus.verified.value,
            OrderStatus.packing.value,
            OrderStatus.ready.value,
          ])
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (inProgress != null) {
        return OrderModel.fromJson(inProgress);
      }

      // Jika tidak ada yang sedang jalan, ambil order teratas di antrean QUEUED
      final nextQueued = await _client
          .from('orders')
          .select(_orderSelectQuery)
          .eq('status', OrderStatus.queued.value)
          .order('queue_position', ascending: true)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (nextQueued != null) {
        return OrderModel.fromJson(nextQueued);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<OrderEntity>> getOrderQueue() async {
    try {
      final res = await _client
          .from('orders')
          .select(_orderSelectQuery)
          .not('status', 'in', [OrderStatus.done.value, OrderStatus.cancelled.value])
          .order('created_at', ascending: true);

      return (res as List<dynamic>)
          .map<OrderEntity>((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<OrderPipelineSummary> getOrderPipelineSummary() async {
    try {
      final res = await _client
          .from('orders')
          .select('id, status, created_at');

      final list = res as List<dynamic>;

      int queued = 0;
      int picking = 0;
      int waitingVerif = 0;
      int rePicking = 0;
      int verified = 0;
      int packing = 0;
      int ready = 0;
      int done = 0;
      int cancelled = 0;
      int overdueSla = 0;

      final now = DateTime.now();

      for (var row in list) {
        final status = (row['status'] as String? ?? '').toUpperCase();
        final createdAtStr = row['created_at'] as String?;
        final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

        if (status == 'QUEUED') {
          queued++;
        } else if (status == 'PICKING') {
          picking++;
        } else if (status == 'WAITING_VERIFICATION') {
          waitingVerif++;
        } else if (status == 'RE_PICKING') {
          rePicking++;
        } else if (status == 'VERIFIED') {
          verified++;
        } else if (status == 'PACKING') {
          packing++;
        } else if (status == 'READY') {
          ready++;
        } else if (status == 'DONE') {
          done++;
        } else if (status == 'CANCELLED') {
          cancelled++;
        }

        // Hitung jika lewat SLA (> 30 menit dan belum selesai)
        if (createdAt != null &&
            status != 'DONE' &&
            status != 'CANCELLED' &&
            now.difference(createdAt).inMinutes > 30) {
          overdueSla++;
        }
      }

      return OrderPipelineSummary(
        queuedCount: queued,
        pickingCount: picking,
        waitingVerificationCount: waitingVerif,
        rePickingCount: rePicking,
        verifiedCount: verified,
        packingCount: packing,
        readyCount: ready,
        doneCount: done,
        cancelledCount: cancelled,
        overdueSlaCount: overdueSla,
      );
    } catch (e) {
      return const OrderPipelineSummary();
    }
  }

  @override
  Future<OrderEntity> createOrder({
    required String orderNumber,
    String? marketplace,
    String? customerNote,
    required List<Map<String, dynamic>> items,
  }) async {
    final user = await LocalStorageService().getUser();
    final userId = user?.id ?? _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Sesi pengguna tidak valid');

    // 1. Simpan header order
    final orderRes = await _client
        .from('orders')
        .insert({
          'user_id': userId,
          'order_number': orderNumber,
          'marketplace': marketplace,
          'customer_note': customerNote,
          'status': OrderStatus.queued.value,
          'version': 1,
        })
        .select()
        .single();

    final orderId = orderRes['id'] as String;

    // 2. Simpan order items & inisialisasi order_item_pickings
    for (var item in items) {
      final insertedItem = await _client
          .from('order_items')
          .insert({
            'user_id': userId,
            'order_id': orderId,
            'product_id': item['product_id'],
            'sku_snapshot': item['sku_snapshot'] ?? '',
            'name_snapshot': item['name_snapshot'] ?? '',
            'variant_snapshot': item['variant_snapshot'],
            'location_snapshot': item['location_snapshot'] ?? 'Gudang Utama',
            'photo_snapshot': item['photo_snapshot'],
            'quantity_required': item['quantity_required'] ?? 1,
          })
          .select()
          .single();

      final orderItemId = insertedItem['id'] as String;

      // Inisialisasi baris picking
      await _client.from('order_item_pickings').insert({
        'user_id': userId,
        'order_item_id': orderItemId,
        'quantity_picked': 0,
        'status': PickingStatus.pending.value,
      });
    }

    // 3. Catat order event
    await _client.from('order_events').insert({
      'user_id': userId,
      'order_id': orderId,
      'event_type': 'ORDER_CREATED',
      'actor_id': userId,
      'metadata': {'order_number': orderNumber, 'item_count': items.length},
    });

    final completeOrder = await getOrderById(orderId);
    if (completeOrder == null) throw Exception('Gagal memuat pesanan yang baru dibuat');
    return completeOrder;
  }

  @override
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    required int currentVersion,
    String? reason,
  }) async {
    final user = await LocalStorageService().getUser();
    final userId = user?.id ?? _client.auth.currentUser?.id;

    final updatePayload = <String, dynamic>{
      'status': status.value,
      'version': currentVersion + 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (reason != null && status == OrderStatus.cancelled) {
      updatePayload['cancel_reason'] = reason;
      updatePayload['cancelled_at'] = DateTime.now().toIso8601String();
    } else if (status == OrderStatus.done) {
      updatePayload['completed_at'] = DateTime.now().toIso8601String();
    }

    final res = await _client
        .from('orders')
        .update(updatePayload)
        .eq('id', orderId)
        .eq('version', currentVersion)
        .select('id, version');

    final success = (res as List).isNotEmpty;

    if (success && userId != null) {
      await _client.from('order_events').insert({
        'user_id': userId,
        'order_id': orderId,
        'event_type': 'STATUS_CHANGED_TO_${status.value}',
        'actor_id': userId,
        'metadata': {'status': status.value, 'previous_version': currentVersion},
      });
    }

    return success;
  }

  @override
  Future<bool> updateItemPicking({
    required String orderItemId,
    required int quantityPicked,
    required PickingStatus status,
  }) async {
    final user = await LocalStorageService().getUser();
    final userId = user?.id ?? _client.auth.currentUser?.id;

    final res = await _client
        .from('order_item_pickings')
        .upsert(
          {
            'order_item_id': orderItemId,
            if (userId != null) 'user_id': userId,
            'quantity_picked': quantityPicked,
            'status': status.value,
            'picked_at': status == PickingStatus.picked
                ? DateTime.now().toIso8601String()
                : null,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'order_item_id',
        )
        .select();

    return (res as List).isNotEmpty;
  }

  @override
  Future<String?> uploadVerificationPhoto(Uint8List bytes, String fileName) async {
    try {
      final path = 'verifications/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await _client.storage.from('verification-photos').uploadBinary(path, bytes);
      return _client.storage.from('verification-photos').getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<OrderVerification> submitVerification({
    required String orderId,
    required String photoUrl,
    required int attemptNumber,
  }) async {
    final user = await LocalStorageService().getUser();
    final userId = user?.id ?? _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Sesi pengguna tidak valid');

    final res = await _client
        .from('order_verifications')
        .insert({
          'user_id': userId,
          'order_id': orderId,
          'attempt_number': attemptNumber,
          'photo_url': photoUrl,
          'result': VerificationResult.match.value, // default sebelum direview
          'verified_by': userId,
        })
        .select()
        .single();

    // Ubah status order ke WAITING_VERIFICATION
    await _client.from('orders').update({
      'status': OrderStatus.waitingVerification.value,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);

    // Catat event
    await _client.from('order_events').insert({
      'user_id': userId,
      'order_id': orderId,
      'event_type': 'PHOTO_SUBMITTED',
      'actor_id': userId,
      'metadata': {'attempt': attemptNumber, 'photo_url': photoUrl},
    });

    return OrderVerificationModel.fromJson(res);
  }

  @override
  Future<bool> reviewVerification({
    required String verificationId,
    required String orderId,
    required VerificationResult result,
    required int currentVersion,
    List<Map<String, dynamic>> rejectedItems = const [],
  }) async {
    final user = await LocalStorageService().getUser();
    final userId = user?.id ?? _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Sesi pengguna tidak valid');

    // 1. Update hasil verifikasi
    await _client.from('order_verifications').update({
      'result': result.value,
      'verified_by': userId,
    }).eq('id', verificationId);

    // 2. Jika ada item yang salah, masukkan ke order_verification_items
    if (rejectedItems.isNotEmpty) {
      for (var item in rejectedItems) {
        await _client.from('order_verification_items').insert({
          'user_id': userId,
          'verification_id': verificationId,
          'order_item_id': item['order_item_id'],
          'reason': item['reason'],
          'note': item['note'],
        });
      }
    }

    // 3. Tentukan status baru (VERIFIED jika match, RE_PICKING jika mismatch/damaged)
    final newStatus = result == VerificationResult.match
        ? OrderStatus.verified
        : OrderStatus.rePicking;

    // 4. Update status order dengan versioning
    final success = await updateOrderStatus(
      orderId: orderId,
      status: newStatus,
      currentVersion: currentVersion,
    );

    // 5. Catat audit event
    await _client.from('order_events').insert({
      'user_id': userId,
      'order_id': orderId,
      'event_type': result == VerificationResult.match
          ? 'VERIFICATION_PASSED'
          : 'VERIFICATION_FAILED',
      'actor_id': userId,
      'metadata': {
        'result': result.value,
        'rejected_count': rejectedItems.length,
      },
    });

    return success;
  }

  @override
  Future<bool> completeOrder({
    required String orderId,
    required int currentVersion,
  }) async {
    return updateOrderStatus(
      orderId: orderId,
      status: OrderStatus.done,
      currentVersion: currentVersion,
    );
  }

  @override
  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
    required int currentVersion,
  }) async {
    return updateOrderStatus(
      orderId: orderId,
      status: OrderStatus.cancelled,
      currentVersion: currentVersion,
      reason: reason,
    );
  }

  @override
  Future<List<OrderEvent>> getOrderEvents(String orderId) async {
    try {
      final res = await _client
          .from('order_events')
          .select('''
            id,
            user_id,
            order_id,
            event_type,
            actor_id,
            metadata,
            created_at,
            profiles(name)
          ''')
          .eq('order_id', orderId)
          .order('created_at', ascending: true);

      return (res as List<dynamic>)
          .map<OrderEvent>((e) => OrderEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
