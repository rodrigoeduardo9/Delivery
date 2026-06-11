import '../models/api_response.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class RestaurantService {
  final ApiService _api = ApiService();

  Future<ApiResponse<PaginatedResponse<Restaurant>>> getRestaurants({
    int page = 1,
    String? category,
    double? minRating,
    String? sortBy,
    double? maxDistance,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
      };
      if (category != null) params['category'] = category;
      if (minRating != null) params['min_rating'] = minRating.toString();
      if (sortBy != null) params['sort_by'] = sortBy;
      if (maxDistance != null) params['max_distance'] = maxDistance.toString();

      final data = await _api.get(ApiConfig.restaurants, queryParams: params);
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => PaginatedResponse.fromJson(d as Map<String, dynamic>, (e) => Restaurant.fromJson(e as Map<String, dynamic>)));
    } on ApiException catch (e) {
      return ApiResponse<PaginatedResponse<Restaurant>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<List<Restaurant>>> searchRestaurants(String query) async {
    try {
      final data = await _api.get(ApiConfig.searchRestaurants, queryParams: {'q': query});
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => (d as List).map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList());
    } on ApiException catch (e) {
      return ApiResponse<List<Restaurant>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<Restaurant>> getRestaurantDetail(int id) async {
    try {
      final data = await _api.get('${ApiConfig.restaurantDetail}$id');
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => Restaurant.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<Restaurant>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<PaginatedResponse<Review>>> getRestaurantReviews(int restaurantId, {int page = 1}) async {
    try {
      final data = await _api.get('${ApiConfig.restaurantReviews}$restaurantId/reviews', queryParams: {'page': page.toString()});
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => PaginatedResponse.fromJson(d as Map<String, dynamic>, (e) => Review.fromJson(e as Map<String, dynamic>)));
    } on ApiException catch (e) {
      return ApiResponse<PaginatedResponse<Review>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<List<RestaurantCategory>>> getCategories() async {
    try {
      final data = await _api.get('/restaurants/categories');
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => (d as List).map((e) => RestaurantCategory.fromJson(e as Map<String, dynamic>)).toList());
    } on ApiException catch (e) {
      return ApiResponse<List<RestaurantCategory>>(success: false, message: e.message, errors: e.errors);
    }
  }
}
