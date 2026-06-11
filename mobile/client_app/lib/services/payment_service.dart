import '../models/api_response.dart';
import '../models/payment.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class PaymentService {
  final ApiService _api = ApiService();

  Future<ApiResponse<Payment>> processPayment(Map<String, dynamic> paymentData) async {
    try {
      final data = await _api.post(ApiConfig.payments, body: paymentData);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => Payment.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<Payment>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
    try {
      final data = await _api.get(ApiConfig.paymentMethods);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => (d as List).map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>)).toList());
    } on ApiException catch (e) {
      return ApiResponse<List<PaymentMethod>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<PaginatedResponse<Payment>>> getPaymentHistory({int page = 1}) async {
    try {
      final data = await _api.get(ApiConfig.paymentHistory, queryParams: {'page': page.toString()});
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => PaginatedResponse.fromJson(d as Map<String, dynamic>, (e) => Payment.fromJson(e as Map<String, dynamic>)));
    } on ApiException catch (e) {
      return ApiResponse<PaginatedResponse<Payment>>(success: false, message: e.message, errors: e.errors);
    }
  }
}
