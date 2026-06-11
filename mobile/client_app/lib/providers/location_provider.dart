import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/location_service.dart';
import '../services/user_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final UserService _userService = UserService();

  double? _latitude;
  double? _longitude;
  String? _address;
  Address? _selectedAddress;
  List<Address> _savedAddresses = [];
  bool _isLoading = false;
  String? _error;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  Address? get selectedAddress => _selectedAddress;
  List<Address> get savedAddresses => _savedAddresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _latitude = position.latitude;
      _longitude = position.longitude;
      _address = await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      _error = 'Could not get location: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSavedAddresses() async {
    final result = await _userService.getAddresses();
    if (result.success && result.data != null) {
      _savedAddresses = result.data!;
      final defaultAddr =
          _savedAddresses.where((a) => a.isDefault).firstOrNull;
      if (defaultAddr != null) {
        _selectedAddress = defaultAddr;
        _latitude = defaultAddr.latitude;
        _longitude = defaultAddr.longitude;
        _address = defaultAddr.fullAddress;
      }
      notifyListeners();
    }
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    _latitude = address.latitude;
    _longitude = address.longitude;
    _address = address.fullAddress;
    notifyListeners();
  }

  void setLocation(double lat, double lng, String addr) {
    _latitude = lat;
    _longitude = lng;
    _address = addr;
    notifyListeners();
  }

  Future<bool> addAddress(Address address) async {
    final result = await _userService.addAddress(address);
    if (result.success && result.data != null) {
      _savedAddresses.add(result.data!);
      notifyListeners();
      return true;
    }
    _error = result.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteAddress(int addressId) async {
    final result = await _userService.deleteAddress(addressId);
    if (result.success) {
      _savedAddresses.removeWhere((a) => a.id == addressId);
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = null;
      }
      notifyListeners();
      return true;
    }
    _error = result.message;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
