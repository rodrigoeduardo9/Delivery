import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/driver_document.dart';
import '../models/driver_profile.dart';
import 'api_service.dart';

class DriverService {
  final ApiService _apiService;

  DriverService(this._apiService);

  Future<ApiResponse<DriverProfile>> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.driverProfile);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final profile = DriverProfile.fromJson(data);
      return ApiResponse.success(profile);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load profile');
    }
  }

  Future<ApiResponse<DriverProfile>> updateProfile({
    String? vehicleType,
    String? name,
    String? phone,
    bool? isAvailable,
    String? status,
    double? latitude,
    double? longitude,
    String? vehiclePlate,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (vehicleType != null) body['vehicle_type'] = vehicleType;
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (isAvailable != null) body['is_available'] = isAvailable;
      if (status != null) body['status'] = status;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (vehiclePlate != null) body['vehicle_plate'] = vehiclePlate;

      final response =
          await _apiService.put(ApiConfig.updateDriverProfile, body: body);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final profile = DriverProfile.fromJson(data);
      return ApiResponse.success(profile);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to update profile');
    }
  }

  Future<ApiResponse<List<DriverDocument>>> getDocuments() async {
    try {
      final response = await _apiService.get(ApiConfig.driverDocuments);
      final data = response['data'] as List<dynamic>? ??
          (response['documents'] as List<dynamic>? ?? []);
      final documents = data
          .map((e) => DriverDocument.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(documents);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load documents');
    }
  }

  Future<ApiResponse<DriverDocument>> submitDocument({
    required String filePath,
    required String documentType,
  }) async {
    try {
      final response = await _apiService.uploadFile(
        ApiConfig.submitDocument,
        filePath,
        extraFields: {'type': documentType},
      );
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final document = DriverDocument.fromJson(data);
      return ApiResponse.success(document);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to submit document');
    }
  }

  Future<ApiResponse<void>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.locationHistory,
        body: {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return ApiResponse.success(null);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to update location');
    }
  }
}
