import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/token_manager.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final TokenManager _tokenManager = TokenManager();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final hasToken = await _tokenManager.hasTokens();
      if (hasToken) {
        final result = await _userService.getProfile();
        if (result.success && result.data != null) {
          _user = result.data;
          _status = AuthStatus.authenticated;
        } else {
          await _tokenManager.clearTokens();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);
    if (result.success && result.data != null) {
      _user = result.data;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message ?? 'Login failed';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    if (result.success && result.data != null) {
      _user = result.data;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message ?? 'Registration failed';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _tokenManager.clearTokens();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> updateAvatar(String avatarUrl) async {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        phone: _user!.phone,
        avatarUrl: avatarUrl,
        emailVerified: _user!.emailVerified,
        phoneVerified: _user!.phoneVerified,
        createdAt: _user!.createdAt,
      );
      notifyListeners();
    }
  }
}
