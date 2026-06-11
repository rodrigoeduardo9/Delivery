import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;

  final ValueNotifier<Position?> positionNotifier = ValueNotifier(null);

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<Position?> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      positionNotifier.value = _currentPosition;
      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Future<void> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 10,
    Duration interval = const Duration(seconds: 5),
  }) async {
    if (_isTracking) return;

    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    _isTracking = true;

    await getCurrentLocation();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
        timeLimit: null,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      positionNotifier.value = position;
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
  }

  Future<double> calculateDistance(
      double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  bool isWithinGeofence(
    double currentLat,
    double currentLng,
    double targetLat,
    double targetLng,
    double radiusMeters,
  ) {
    final distance = Geolocator.distanceBetween(
      currentLat,
      currentLng,
      targetLat,
      targetLng,
    );
    return distance <= radiusMeters;
  }

  void dispose() {
    stopTracking();
    positionNotifier.dispose();
  }
}
