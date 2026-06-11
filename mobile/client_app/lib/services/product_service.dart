import '../models/api_response.dart';
import '../models/product.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<ApiResponse<List<Product>>> getProducts(int restaurantId) async {
    try {
      final data = await _api.get(ApiConfig.products, queryParams: {
        'restaurant_id': restaurantId.toString(),
      });
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => (d as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList());
    } on ApiException catch (e) {
      return ApiResponse<List<Product>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<Product>> getProductDetail(int productId) async {
    try {
      final data = await _api.get('${ApiConfig.productDetail}$productId');
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => Product.fromJson(d as Map<String, dynamic>));
    } on ApiException catch (e) {
      return ApiResponse<Product>(success: false, message: e.message, errors: e.errors);
    }
  }
}
