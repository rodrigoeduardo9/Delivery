import '../models/api_response.dart';
import '../models/user.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final data = await _api.post(ApiConfig.login, body: {
        'email': email,
        'password': password,
      }, withAuth: false);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => User.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<User>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final data = await _api.post(ApiConfig.register, body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }, withAuth: false);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => User.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<User>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      await _api.post(ApiConfig.forgotPassword, body: {
        'email': email,
      }, withAuth: false);
      return ApiResponse<void>(success: true, message: 'Reset link sent to your email');
    } on ApiException catch (e) {
      return ApiResponse<void>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<bool> logout() async {
    try {
      await _api.post(ApiConfig.logout);
      return true;
    } catch (_) {
      return true;
    }
  }
}
