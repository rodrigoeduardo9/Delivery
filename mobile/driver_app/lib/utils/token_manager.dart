import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  final FlutterSecureStorage _secureStorage;
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpiryKey = 'token_expiry';
  static const _userDataKey = 'user_data';

  TokenManager({FlutterSecureStorage? secureStorage})
      : _secureStorage =
            secureStorage ?? const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> saveTokenExpiry(DateTime expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _tokenExpiryKey, expiry.toIso8601String());
  }

  Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _userDataKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_userDataKey);
  }
}
