import '../models/api_response.dart';
import '../models/order.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class OrderService {
  final ApiService _api = ApiService();

  Future<ApiResponse<Order>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final data = await _api.post(ApiConfig.orders, body: orderData);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => Order.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<Order>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<PaginatedResponse<Order>>> getOrders({
    int page = 1,
    String? status,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
      };
      if (status != null) params['status'] = status;

      final data = await _api.get(ApiConfig.orders, queryParams: params);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => PaginatedResponse.fromJson(d as Map<String, dynamic>, (e) => Order.fromJson(e as Map<String, dynamic>)));
    } on ApiException catch (e) {
      return ApiResponse<PaginatedResponse<Order>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<Order>> getOrderDetail(int orderId) async {
    try {
      final data = await _api.get('${ApiConfig.orderDetail}$orderId');
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => Order.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<Order>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<Order>> trackOrder(int orderId) async {
    try {
      final data = await _api.get('${ApiConfig.trackOrder}$orderId/track');
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => Order.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<Order>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<void>> cancelOrder(int orderId) async {
    try {
      await _api.post('${ApiConfig.cancelOrder}$orderId/cancel');
      return ApiResponse<void>(success: true, message: 'Order cancelled');
    } on ApiException catch (e) {
      return ApiResponse<void>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<void>> rateOrder(int orderId, {required double rating, String? comment}) async {
    try {
      await _api.post('${ApiConfig.rateOrder}$orderId/rate', body: {
        'rating': rating,
        if (comment != null) 'comment': comment,
      });
      return ApiResponse<void>(success: true, message: 'Order rated');
    } on ApiException catch (e) {
      return ApiResponse<void>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> calculateOrder(Map<String, dynamic> data) async {
    try {
      final result = await _api.post(ApiConfig.calculateOrder, body: data);
      return ApiResponse.fromJson(result as Map<String, dynamic>, (d) => d as Map<String, dynamic>);
    } on ApiException catch (e) {
      return ApiResponse<Map<String, dynamic>>(success: false, message: e.message, errors: e.errors);
    }
  }
}
