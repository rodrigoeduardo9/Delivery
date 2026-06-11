import '../models/api_response.dart';
import '../models/user.dart';
import '../models/restaurant.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<ApiResponse<User>> getProfile() async {
    try {
      final data = await _api.get(ApiConfig.userProfile);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => User.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<User>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final data = await _api.put(ApiConfig.userProfile, body: profileData);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => User.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<User>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<List<Address>>> getAddresses() async {
    try {
      final data = await _api.get(ApiConfig.userAddresses);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => (d as List).map((e) => Address.fromJson(e as Map<String, dynamic>)).toList());
    } on ApiException catch (e) {
      return ApiResponse<List<Address>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<Address>> addAddress(Address address) async {
    try {
      final data = await _api.post(ApiConfig.userAddresses, body: address.toJson());
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => Address.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<Address>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<Address>> updateAddress(int addressId, Address address) async {
    try {
      final data = await _api.put('${ApiConfig.userAddresses}/$addressId', body: address.toJson());
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => Address.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<Address>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<void>> deleteAddress(int addressId) async {
    try {
      await _api.delete('${ApiConfig.userAddresses}/$addressId');
      return ApiResponse<void>(success: true, message: 'Address deleted');
    } on ApiException catch (e) {
      return ApiResponse<void>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<List<Restaurant>>> getFavorites() async {
    try {
      final data = await _api.get(ApiConfig.userFavorites);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => (d as List).map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList());
    } on ApiException catch (e) {
      return ApiResponse<List<Restaurant>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<void>> toggleFavorite(int restaurantId) async {
    try {
      await _api.post('${ApiConfig.userFavorites}/$restaurantId');
      return ApiResponse<void>(success: true);
    } on ApiException catch (e) {
      return ApiResponse<void>(success: false, message: e.message, errors: e.errors);
    }
  }
}
