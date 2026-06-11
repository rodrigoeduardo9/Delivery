class ApiConfig {
  static const String baseUrl = 'https://api.delivery-platform.com/v1';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String logout = '/auth/logout';

  static const String restaurants = '/restaurants';
  static const String restaurantDetail = '/restaurants/';
  static const String restaurantMenu = '/restaurants/';
  static const String restaurantReviews = '/restaurants/';
  static const String searchRestaurants = '/restaurants/search';

  static const String products = '/products';
  static const String productDetail = '/products/';

  static const String orders = '/orders';
  static const String orderDetail = '/orders/';
  static const String trackOrder = '/orders/';
  static const String cancelOrder = '/orders/';
  static const String rateOrder = '/orders/';
  static const String calculateOrder = '/orders/calculate';

  static const String payments = '/payments';
  static const String paymentMethods = '/payments/methods';
  static const String paymentHistory = '/payments/history';

  static const String userProfile = '/user/profile';
  static const String userAddresses = '/user/addresses';
  static const String userFavorites = '/user/favorites';

  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/';

  static const String chatbotConversations = '/chatbot/conversations';
  static const String chatbotSend = '/chatbot/send';

  static const String coupons = '/coupons/validate';

  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}
