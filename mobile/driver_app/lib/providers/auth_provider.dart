import 'package:flutter/foundation.dart';
import '../models/driver_document.dart';
import '../models/driver_profile.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final DriverService _driverService;

  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  DriverProfile? _driverProfile;
  String? _error;
  List<DriverDocument> _documents = [];
  bool _onboardingComplete = false;

  AuthProvider({
    required AuthService authService,
    required DriverService driverService,
  })  : _authService = authService,
        _driverService = driverService {
    _init();
  }

  AuthStatus get status => _status;
  User? get user => _user;
  DriverProfile? get driverProfile => _driverProfile;
  String? get error => _error;
  List<DriverDocument> get documents => _documents;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get onboardingComplete => _onboardingComplete;
  bool get isAvailable => _driverProfile?.isAvailable ?? false;

  Future<void> _init() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _user = await _authService.getCurrentUser();
      if (_user != null) {
        _status = AuthStatus.authenticated;
        await loadDriverProfile();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _authService.login(email, password);
    if (result.success && result.data != null) {
      _user = result.data;
      _status = AuthStatus.authenticated;
      await loadDriverProfile();
      notifyListeners();
      return true;
    } else {
      _error = result.error ?? 'Login failed';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _driverProfile = null;
    _documents = [];
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> loadDriverProfile() async {
    final result = await _driverService.getProfile();
    if (result.success && result.data != null) {
      _driverProfile = result.data;
    }
    final docsResult = await _driverService.getDocuments();
    if (docsResult.success) {
      _documents = docsResult.data ?? [];
    }
    _checkOnboardingComplete();
    notifyListeners();
  }

  void _checkOnboardingComplete() {
    if (_documents.isEmpty) {
      _onboardingComplete = false;
      return;
    }
    final requiredDocs = _documents.where((d) =>
        d.type == 'driver_license' ||
        d.type == 'vehicle_insurance' ||
        d.type == 'background_check');
    _onboardingComplete = requiredDocs.every((d) => d.isVerified);
  }

  Future<bool> updateAvailability(bool available) async {
    if (_driverProfile == null) return false;
    final result = await _driverService.updateProfile(
      isAvailable: available,
      status: available ? 'online' : 'offline',
    );
    if (result.success && result.data != null) {
      _driverProfile = result.data;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateProfile({
    String? vehicleType,
    String? name,
    String? phone,
  }) async {
    final result = await _driverService.updateProfile(
      vehicleType: vehicleType,
      name: name,
      phone: phone,
    );
    if (result.success && result.data != null) {
      _driverProfile = result.data;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> submitDocument(String filePath, String documentType) async {
    final result =
        await _driverService.submitDocument(filePath: filePath, documentType: documentType);
    if (result.success) {
      await loadDriverProfile();
      return true;
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
