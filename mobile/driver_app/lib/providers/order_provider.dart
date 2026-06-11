import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;
  Timer? _pollingTimer;

  List<Order> _availableOrders = [];
  Order? _activeOrder;
  List<Order> _orderHistory = [];
  bool _isLoading = false;
  String? _error;
  bool _hasNewOrders = false;

  OrderProvider({
    required OrderService orderService,
  }) : _orderService = orderService;

  List<Order> get availableOrders => _availableOrders;
  Order? get activeOrder => _activeOrder;
  List<Order> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNewOrders => _hasNewOrders;
  bool get hasActiveOrder => _activeOrder != null;

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      AppConstants.ordersPollingInterval,
      (_) => fetchAvailableOrders(),
    );
    fetchAvailableOrders();
    fetchActiveOrder();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchAvailableOrders() async {
    _isLoading = true;
    notifyListeners();

    final result = await _orderService.getAvailableOrders();
    if (result.success) {
      if (result.data != null && _availableOrders.isNotEmpty) {
        final existingIds = _availableOrders.map((o) => o.id).toSet();
        final newOrders =
            result.data!.where((o) => !existingIds.contains(o.id)).toList();
        if (newOrders.isNotEmpty) {
          _hasNewOrders = true;
        }
      }
      _availableOrders = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchActiveOrder() async {
    final result = await _orderService.getActiveOrder();
    if (result.success) {
      _activeOrder = result.data;
      _error = null;
      notifyListeners();
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _orderService.acceptOrder(orderId);
    if (result.success && result.data != null) {
      _activeOrder = result.data;
      _availableOrders.removeWhere((o) => o.id == orderId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId) async {
    final result = await _orderService.rejectOrder(orderId);
    if (result.success) {
      _availableOrders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> markPickedUp(String orderId) async {
    final result = await _orderService.markPickedUp(orderId);
    if (result.success && result.data != null) {
      _activeOrder = result.data;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markDelivered(String orderId) async {
    final result = await _orderService.markDelivered(orderId);
    if (result.success && result.data != null) {
      _activeOrder = result.data;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchOrderHistory({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _orderService.getOrderHistory(
      startDate: startDate,
      endDate: endDate,
    );
    if (result.success) {
      _orderHistory = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearHasNewOrders() {
    _hasNewOrders = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearActiveOrder() {
    _activeOrder = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
