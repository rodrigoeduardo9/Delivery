class ApiConfig {
  static const String baseUrl = 'https://api.delivery-platform.com/v1';

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  static const String driverProfile = '/driver/profile';
  static const String updateDriverProfile = '/driver/profile';
  static const String submitDocument = '/driver/documents';
  static const String driverDocuments = '/driver/documents';
  static const String locationHistory = '/driver/location';

  static const String availableOrders = '/orders/available';
  static const String acceptOrder = '/orders/';
  static const String rejectOrder = '/orders/';
  static const String activeOrder = '/orders/active';
  static const String pickupOrder = '/orders/';
  static const String deliverOrder = '/orders/';
  static const String orderHistory = '/orders/history';
  static const String orderDetail = '/orders/';

  static String acceptOrderEndpoint(String orderId) => '/orders/$orderId/accept';
  static String rejectOrderEndpoint(String orderId) => '/orders/$orderId/reject';
  static String pickupOrderEndpoint(String orderId) => '/orders/$orderId/pickup';
  static String deliverOrderEndpoint(String orderId) => '/orders/$orderId/deliver';
  static String orderDetailEndpoint(String orderId) => '/orders/$orderId';

  static const String earningsSummary = '/driver/earnings/summary';
  static const String earningsHistory = '/driver/earnings/history';

  static const String wsUrl = 'wss://api.delivery-platform.com/ws/driver';
}
