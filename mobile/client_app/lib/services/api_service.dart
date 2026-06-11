import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_manager.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<String>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  final TokenManager _tokenManager = TokenManager();
  final http.Client _client = http.Client();
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshQueue = [];

  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _tokenManager.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams, bool withAuth = true}) async {
    return _requestWithRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);
      final response = await _client
          .get(uri, headers: await _getHeaders(withAuth: withAuth))
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    });
  }

  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    return _requestWithRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client
          .post(uri,
              headers: await _getHeaders(withAuth: withAuth),
              body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    });
  }

  Future<dynamic> put(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    return _requestWithRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client
          .put(uri,
              headers: await _getHeaders(withAuth: withAuth),
              body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    });
  }

  Future<dynamic> delete(String endpoint,
      {bool withAuth = true}) async {
    return _requestWithRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client
          .delete(uri, headers: await _getHeaders(withAuth: withAuth))
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    });
  }

  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri);

    final headers = await _getHeaders();
    request.headers.addAll(headers);
    request.files
        .add(await http.MultipartFile.fromPath(fieldName, file.path));
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResponse =
        await request.send().timeout(ApiConfig.timeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<dynamic> _requestWithRetry(Future<dynamic> Function() request,
      {int retryCount = 0}) async {
    try {
      return await request();
    } on ApiException catch (e) {
      if (e.statusCode == 401 && retryCount < ApiConfig.maxRetries) {
        await _handleTokenRefresh();
        return _requestWithRetry(request, retryCount: retryCount + 1);
      }
      rethrow;
    } on SocketException {
      throw ApiException('No internet connection');
    } on http.ClientException {
      throw ApiException('Connection error');
    } on TimeoutException {
      throw ApiException('Request timed out');
    }
  }

  Future<void> _handleTokenRefresh() async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshQueue.add(completer);
      await completer.future;
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw ApiException('Session expired');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshToken}');
      final response = await _client
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refresh_token': refreshToken}))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _tokenManager.saveTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String? ?? refreshToken,
        );
      } else {
        await _tokenManager.clearTokens();
        throw ApiException('Session expired');
      }
    } finally {
      _isRefreshing = false;
      for (final completer in _refreshQueue) {
        completer.complete();
      }
      _refreshQueue.clear();
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String message = 'An error occurred';
    List<String>? errors;

    if (body is Map<String, dynamic>) {
      message = body['message'] as String? ?? message;
      final errs = body['errors'];
      if (errs is List) {
        errors = errs.map((e) => e.toString()).toList();
      } else if (errs is Map) {
        errors = (errs as Map<String, dynamic>)
            .values
            .expand((e) => (e as List).map((v) => v.toString()))
            .toList();
      }
    }

    if (response.statusCode == 401) {
      throw ApiException(message, statusCode: 401, errors: errors);
    }
    if (response.statusCode == 422) {
      throw ApiException(message, statusCode: 422, errors: errors);
    }
    if (response.statusCode == 404) {
      throw ApiException('Resource not found', statusCode: 404);
    }
    throw ApiException(message, statusCode: response.statusCode, errors: errors);
  }

  void dispose() {
    _client.close();
  }
}
