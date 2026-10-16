import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/module/order/order_module.dart';

class OrdersProvider with ChangeNotifier {
  final OrderRepository _orderRepository;

  OrdersProvider(this._orderRepository);

  List<OrderEntity> _orders = [];
  List<OrderEntity> get orders => _orders;

  // Filter & Pagination state
  OrderStatus? _selectedStatus;
  bool _hasMoreOrder = true;
  bool _isLoadingOrder = false;
  bool _isLoadingMoreOrder = false;
  bool _isLoading = false;
  int _currentOrderPage = 1;

  OrderStatus? get selectedStatus => _selectedStatus;
  OrderStatus? get filterStatus => _selectedStatus;
  bool get isLoadingOrder => _isLoadingOrder;
  bool get hasMoreOrder => _hasMoreOrder;
  bool get isLoadingMoreOrder => _isLoadingMoreOrder;
  bool get isLoading => _isLoading;
  int get currentOrderPage => _currentOrderPage;

  List<String> get statusChipFilter => [
    'Semua',
    ...OrderStatus.values.map((x) => x.label),
  ];

  // Backward compatibility alias for UI selector
  List<String> get pickingChipFilter => statusChipFilter;

  Future<List<OrderEntity>> getOrders({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    OrderStatus? status,
    bool isRefresh = false,
  }) async {
    if (_isLoadingOrder || _isLoadingMoreOrder) return _orders;

    if (isRefresh || page == 1) {
      _isLoadingOrder = true;
      _currentOrderPage = 1;
      _hasMoreOrder = true;
    } else {
      _isLoadingMoreOrder = true;
    }
    notifyListeners();

    try {
      final response = await _orderRepository.getOrders(
        page: page,
        limit: limit,
        searchQuery: searchQuery,
        status: status ?? _selectedStatus,
      );

      if (isRefresh || page == 1) {
        _orders = response;
      } else {
        _orders.addAll(response);
      }

      _currentOrderPage = page;
      _hasMoreOrder = response.length >= limit;

      return _orders;
    } catch (e) {
      debugPrint("Error loading orders: $e");
      return [];
    } finally {
      _isLoadingOrder = false;
      _isLoadingMoreOrder = false;
      notifyListeners();
    }
  }

  Future<OrderEntity?> createOrder({
    required String orderNumber,
    String? marketplace,
    String? customerNote,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newOrder = await _orderRepository.createOrder(
        orderNumber: orderNumber,
        marketplace: marketplace,
        customerNote: customerNote,
        items: items,
      );
      _orders = [newOrder, ..._orders];
      return newOrder;
    } catch (e) {
      debugPrint("Error creating order: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByStatus(OrderStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    notifyListeners();
  }
}
