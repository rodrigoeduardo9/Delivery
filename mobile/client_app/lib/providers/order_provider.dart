import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../config/constants.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _activeOrders = [];
  List<Order> _orderHistory = [];
  Order? _trackingOrder;
  bool _isLoading = false;
  String? _error;
  Timer? _trackingTimer;

  List<Order> get activeOrders => _activeOrders;
  List<Order> get orderHistory => _orderHistory;
  Order? get trackingOrder => _trackingOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadActiveOrders() async {
    _isLoading = true;
    notifyListeners();

    final result = await _orderService.getOrders(status: 'active');
    if (result.success && result.data != null) {
      _activeOrders = result.data!.items;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadOrderHistory({int page = 1, String? status}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _orderService.getOrders(page: page, status: status);
    if (result.success && result.data != null) {
      if (page == 1) {
        _orderHistory = result.data!.items;
      } else {
        _orderHistory.addAll(result.data!.items);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> createOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _orderService.createOrder(orderData);
    _isLoading = false;

    if (result.success && result.data != null) {
      return result.data;
    } else {
      _error = result.message ?? 'Failed to create order';
      notifyListeners();
      return null;
    }
  }

  Future<void> startTracking(int orderId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _orderService.trackOrder(orderId);
    if (result.success && result.data != null) {
      _trackingOrder = result.data;
    }

    _isLoading = false;
    notifyListeners();

    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(
      Duration(seconds: AppConstants.orderPollInterval),
      (_) => _pollTracking(orderId),
    );
  }

  Future<void> _pollTracking(int orderId) async {
    final result = await _orderService.trackOrder(orderId);
    if (result.success && result.data != null) {
      _trackingOrder = result.data;
      notifyListeners();
    }
  }

  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingOrder = null;
    notifyListeners();
  }

  Future<bool> cancelOrder(int orderId) async {
    final result = await _orderService.cancelOrder(orderId);
    if (result.success) {
      _activeOrders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      return true;
    }
    _error = result.message;
    notifyListeners();
    return false;
  }

  Future<bool> rateOrder(int orderId, {required double rating, String? comment}) async {
    final result = await _orderService.rateOrder(orderId, rating: rating, comment: comment);
    if (result.success) {
      final idx = _orderHistory.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        final old = _orderHistory[idx];
        _orderHistory[idx] = Order(
          id: old.id,
          orderNumber: old.orderNumber,
          restaurantId: old.restaurantId,
          restaurantName: old.restaurantName,
          restaurantLogoUrl: old.restaurantLogoUrl,
          status: old.status,
          items: old.items,
          subtotal: old.subtotal,
          deliveryFee: old.deliveryFee,
          discount: old.discount,
          tip: old.tip,
          total: old.total,
          couponCode: old.couponCode,
          deliveryAddress: old.deliveryAddress,
          deliveryLatitude: old.deliveryLatitude,
          deliveryLongitude: old.deliveryLongitude,
          paymentMethod: old.paymentMethod,
          driverName: old.driverName,
          driverPhone: old.driverPhone,
          driverPhotoUrl: old.driverPhotoUrl,
          driverVehicle: old.driverVehicle,
          driverRating: old.driverRating,
          driverLatitude: old.driverLatitude,
          driverLongitude: old.driverLongitude,
          estimatedTimeMin: old.estimatedTimeMin,
          statusHistory: old.statusHistory,
          isRated: true,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        );
        notifyListeners();
      }
      return true;
    }
    _error = result.message;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
