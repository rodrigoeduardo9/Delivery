import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../utils/token_manager.dart';
import 'api_service.dart';

class AuthService {
  final TokenManager _tokenManager;
  final ApiService? _apiService;
  final http.Client _client;

  AuthService({
    required TokenManager tokenManager,
    ApiService? apiService,
    http.Client? client,
  })  : _tokenManager = tokenManager,
        _apiService = apiService,
        _client = client ?? http.Client();

  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final data = body['data'] as Map<String, dynamic>? ?? body;
        final userRole = data['user'] != null
            ? (data['user'] as Map<String, dynamic>)['role'] as String?
            : null;
        if (userRole != null && userRole != 'driver') {
          return ApiResponse.error(
            'Access denied. This account is not a driver account.',
            statusCode: 403,
          );
        }
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        if (accessToken != null) {
          await _tokenManager.saveAccessToken(accessToken);
        }
        if (refreshToken != null) {
          await _tokenManager.saveRefreshToken(refreshToken);
        }
        if (data['expires_in'] != null) {
          final expiry =
              DateTime.now().add(Duration(seconds: data['expires_in'] as int));
          await _tokenManager.saveTokenExpiry(expiry);
        }
        final userData = data['user'] as Map<String, dynamic>?;
        if (userData != null) {
          final user = User.fromJson(userData);
          await _tokenManager.saveUserData(userData);
          return ApiResponse.success(user, message: body['message'] as String?);
        }
        if (data['id'] != null) {
          final user = User.fromJson(data);
          await _tokenManager.saveUserData(data);
          return ApiResponse.success(user, message: body['message'] as String?);
        }
        return ApiResponse.error('Invalid response format');
      }

      final message = body['message'] as String? ??
          body['error'] as String? ??
          'Login failed';
      return ApiResponse.error(message, statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(e.message, statusCode: e.statusCode);
      }
      return ApiResponse.error('Connection error. Please try again.');
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      if (_apiService != null) {
        await _apiService!.post(ApiConfig.logout);
      }
    } catch (_) {
      // ignore logout errors
    } finally {
      await _tokenManager.clearTokens();
    }
    return ApiResponse.success(null, message: 'Logged out successfully');
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenManager.getAccessToken();
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    final userData = await _tokenManager.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }
}
