import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';
import '../services/location_service.dart';
import '../services/driver_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;
  final DriverService _driverService;
  Timer? _locationTimer;

  Position? _currentPosition;
  bool _isTracking = false;
  bool _isBackgroundTracking = false;
  String? _error;

  LocationProvider({
    required LocationService locationService,
    required DriverService driverService,
  })  : _locationService = locationService,
        _driverService = driverService;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get isBackgroundTracking => _isBackgroundTracking;
  String? get error => _error;

  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;

  Future<void> initialize() async {
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      _error = 'Location permission denied';
      notifyListeners();
      return;
    }
    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      _currentPosition = position;
      notifyListeners();
    }
  }

  Future<void> startTracking() async {
    if (_isTracking) return;

    await _locationService.startTracking(
      interval: AppConstants.locationPollingInterval,
      distanceFilterMeters: 10,
    );

    _isTracking = true;

    _locationTimer = Timer.periodic(
      AppConstants.locationPollingInterval,
      (_) => _syncLocation(),
    );

    _locationService.positionNotifier.addListener(_onPositionChanged);
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    _isBackgroundTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    _locationService.stopTracking();
    _locationService.positionNotifier.removeListener(_onPositionChanged);
    notifyListeners();
  }

  void _onPositionChanged() {
    final position = _locationService.positionNotifier.value;
    if (position != null) {
      _currentPosition = position;
      notifyListeners();
    }
  }

  Future<void> _syncLocation() async {
    if (_currentPosition == null) return;
    await _driverService.updateLocation(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
    );
  }

  void enableBackgroundTracking() {
    _isBackgroundTracking = true;
    notifyListeners();
  }

  void disableBackgroundTracking() {
    _isBackgroundTracking = false;
    notifyListeners();
  }

  bool isWithinGeofence(
    double targetLat,
    double targetLng, {
    double radiusMeters = AppConstants.geofenceRadiusMeters,
  }) {
    if (_currentPosition == null) return false;
    return _locationService.isWithinGeofence(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetLat,
      targetLng,
      radiusMeters,
    );
  }

  Future<double> calculateDistance(
      double startLat, double startLng,
      double endLat, double endLng) async {
    return _locationService.calculateDistance(
      startLat, startLng, endLat, endLng);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    _locationService.dispose();
    super.dispose();
  }
}
