import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/constants.dart';
import '../utils/token_manager.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  final TokenManager _tokenManager;
  final http.Client _client;
  bool _isRefreshing = false;
  Completer<String>? _refreshCompleter;

  ApiService({required TokenManager tokenManager, http.Client? client})
      : _tokenManager = tokenManager,
        _client = client ?? http.Client();

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenManager.getAccessToken();
    if (token != null) {
      return {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };
    }
    return _defaultHeaders;
  }

  Future<String?> _getValidToken() async {
    final token = await _tokenManager.getAccessToken();
    final expiry = await _tokenManager.getTokenExpiry();
    if (token != null && expiry != null && DateTime.now().isBefore(expiry)) {
      return token;
    }
    if (_isRefreshing) {
      return _refreshCompleter?.future;
    }
    _isRefreshing = true;
    _refreshCompleter = Completer<String>();
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) throw ApiException('Session expired');
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshToken}'),
        headers: _defaultHeaders,
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['access_token'] as String;
        await _tokenManager.saveAccessToken(newToken);
        if (data['refresh_token'] != null) {
          await _tokenManager.saveRefreshToken(data['refresh_token'] as String);
        }
        _refreshCompleter?.complete(newToken);
        return newToken;
      } else {
        await _tokenManager.clearTokens();
        _refreshCompleter?.completeError(ApiException('Session expired'));
        return null;
      }
    } catch (e) {
      await _tokenManager.clearTokens();
      _refreshCompleter?.completeError(ApiException('Session expired'));
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    return _executeWithRetry(() async {
      final headers = await _authHeaders;
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);
      final response = await _client
          .get(uri, headers: headers)
          .timeout(AppConstants.httpTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    return _executeWithRetry(() async {
      final headers = await _authHeaders;
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.httpTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? body}) async {
    return _executeWithRetry(() async {
      final headers = await _authHeaders;
      final response = await _client
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.httpTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> patch(String endpoint,
      {Map<String, dynamic>? body}) async {
    return _executeWithRetry(() async {
      final headers = await _authHeaders;
      final response = await _client
          .patch(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.httpTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _executeWithRetry(() async {
      final headers = await _authHeaders;
      final response = await _client
          .delete(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(AppConstants.httpTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? extraFields,
  }) async {
    final token = await _getValidToken();
    if (token == null) throw ApiException('Not authenticated');
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }
    final streamedResponse =
        await request.send().timeout(AppConstants.httpTimeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _executeWithRetry(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    for (int attempt = 0; attempt < AppConstants.maxRetries; attempt++) {
      try {
        return await request();
      } on SocketException {
        if (attempt == AppConstants.maxRetries - 1) rethrow;
        await Future.delayed(AppConstants.retryDelay);
      } on HttpException {
        if (attempt == AppConstants.maxRetries - 1) rethrow;
        await Future.delayed(AppConstants.retryDelay);
      }
    }
    throw ApiException('Request failed after retries');
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      _tokenManager.clearTokens();
      throw ApiException('Unauthorized', statusCode: 401);
    }

    final message = body['message'] as String? ??
        body['error'] as String? ??
        'Request failed';
    throw ApiException(message, statusCode: response.statusCode);
  }

  void dispose() {
    _client.close();
  }
}
