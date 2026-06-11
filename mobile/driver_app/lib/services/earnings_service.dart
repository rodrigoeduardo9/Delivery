import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/driver_earning.dart';
import 'api_service.dart';

class EarningsService {
  final ApiService _apiService;

  EarningsService(this._apiService);

  Future<ApiResponse<EarningsSummary>> getSummary() async {
    try {
      final response = await _apiService.get(ApiConfig.earningsSummary);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      final summary = EarningsSummary.fromJson(data);
      return ApiResponse.success(summary);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load earnings summary');
    }
  }

  Future<ApiResponse<List<DriverEarning>>> getHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String();
      }
      final response =
          await _apiService.get(ApiConfig.earningsHistory, queryParams: params);
      final data = response['data'] as List<dynamic>? ??
          (response['earnings'] as List<dynamic>? ?? []);
      final earnings = data
          .map((e) => DriverEarning.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(earnings);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load earnings history');
    }
  }

  Future<ApiResponse<List<WeeklyEarning>>> getWeeklyChart() async {
    try {
      final response =
          await _apiService.get('${ApiConfig.earningsSummary}/weekly');
      final data = response['data'] as List<dynamic>? ??
          (response['weekly'] as List<dynamic>? ?? []);
      final weekly = data
          .map((e) => WeeklyEarning.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(weekly);
    } on ApiException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiResponse.error('Failed to load weekly chart');
    }
  }
}
