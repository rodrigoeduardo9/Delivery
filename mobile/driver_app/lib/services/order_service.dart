import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService;

  OrderService(this._apiService);

  Future<ApiResponse<List<Order>>> getAvailableOrders() async {
    try {
      final response =
          await _apiService.get(ApiConfig.availableOrders);
      final data = response['data'] as List<dynamic>? ??
          (response['orders'] as List<dynamic>? ?? []);
      final orders =
          data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.success(orders);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load orders');
    }
  }

  Future<ApiResponse<Order>> acceptOrder(String orderId) async {
    try {
      final response = await _apiService.post(
        ApiConfig.acceptOrderEndpoint(orderId),
      );
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final order = Order.fromJson(data);
      return ApiResponse.success(order);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to accept order');
    }
  }

  Future<ApiResponse<void>> rejectOrder(String orderId,
      {String? reason}) async {
    try {
      await _apiService.post(
        ApiConfig.rejectOrderEndpoint(orderId),
        body: reason != null ? {'reason': reason} : null,
      );
      return ApiResponse.success(null);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to reject order');
    }
  }

  Future<ApiResponse<Order?>> getActiveOrder() async {
    try {
      final response = await _apiService.get(ApiConfig.activeOrder);
      if (response['data'] == null && response['order'] == null) {
        return ApiResponse.success(null);
      }
      final data = response['data'] as Map<String, dynamic>? ??
          response['order'] as Map<String, dynamic>?;
      if (data == null) return ApiResponse.success(null);
      final order = Order.fromJson(data);
      return ApiResponse.success(order);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load active order');
    }
  }

  Future<ApiResponse<Order>> markPickedUp(String orderId) async {
    try {
      final response =
          await _apiService.post(ApiConfig.pickupOrderEndpoint(orderId));
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final order = Order.fromJson(data);
      return ApiResponse.success(order);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to mark pickup');
    }
  }

  Future<ApiResponse<Order>> markDelivered(String orderId) async {
    try {
      final response =
          await _apiService.post(ApiConfig.deliverOrderEndpoint(orderId));
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final order = Order.fromJson(data);
      return ApiResponse.success(order);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to mark delivered');
    }
  }

  Future<ApiResponse<Order>> getOrderDetail(String orderId) async {
    try {
      final response =
          await _apiService.get(ApiConfig.orderDetailEndpoint(orderId));
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final order = Order.fromJson(data);
      return ApiResponse.success(order);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load order detail');
    }
  }

  Future<ApiResponse<List<Order>>> getOrderHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String();
      }
      final response =
          await _apiService.get(ApiConfig.orderHistory, queryParams: params);
      final data = response['data'] as List<dynamic>? ??
          (response['orders'] as List<dynamic>? ?? []);
      final orders =
          data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse.success(orders);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load order history');
    }
  }
}
