import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        return '${pm.street ?? ''}${pm.subLocality != null ? ', ${pm.subLocality}' : ''}${pm.locality != null ? ', ${pm.locality}' : ''}';
      }
      return '$latitude, $longitude';
    } catch (_) {
      return '$latitude, $longitude';
    }
  }

  Future<LatLngPosition> geocodeAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLngPosition(
          locations.first.latitude,
          locations.first.longitude,
        );
      }
      throw Exception('Address not found');
    } catch (e) {
      throw Exception('Could not geocode address: $e');
    }
  }
}

class LatLngPosition {
  final double latitude;
  final double longitude;

  LatLngPosition(this.latitude, this.longitude);
}
