import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';

class LocationHelper {
  static const double _earthRadius = 6371000;

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static double calculateDistanceBetween(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static bool isWithinRadius(
    double currentLat,
    double currentLng,
    double targetLat,
    double targetLng, {
    double radiusMeters = AppConstants.geofenceRadiusMeters,
  }) {
    final distance =
        calculateDistanceBetween(currentLat, currentLng, targetLat, targetLng);
    return distance <= radiusMeters;
  }

  static double calculateBearing(
      double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final dLon = _degreesToRadians(lon2 - lon1);

    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    final bearing = _radiansToDegrees(atan2(y, x));
    return (bearing + 360) % 360;
  }

  static String bearingToDirection(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'N';
    if (bearing >= 22.5 && bearing < 67.5) return 'NE';
    if (bearing >= 67.5 && bearing < 112.5) return 'E';
    if (bearing >= 112.5 && bearing < 157.5) return 'SE';
    if (bearing >= 157.5 && bearing < 202.5) return 'S';
    if (bearing >= 202.5 && bearing < 247.5) return 'SW';
    if (bearing >= 247.5 && bearing < 292.5) return 'W';
    return 'NW';
  }

  static double interpolateLatitude(
      double lat1, double lat2, double fraction) {
    return lat1 + (lat2 - lat1) * fraction;
  }

  static double interpolateLongitude(
      double lon1, double lon2, double fraction) {
    return lon1 + (lon2 - lon1) * fraction;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  static double _radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }
}
