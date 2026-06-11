class AppConstants {
  static const Duration locationPollingInterval = Duration(seconds: 5);
  static const Duration ordersPollingInterval = Duration(seconds: 10);
  static const Duration earningsRefreshInterval = Duration(seconds: 30);

  static const double mapDefaultLatitude = 19.4326;
  static const double mapDefaultLongitude = -99.1332;
  static const double mapDefaultZoom = 14.0;
  static const double geofenceRadiusMeters = 100.0;
  static const double searchRadiusKm = 10.0;

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration httpTimeout = Duration(seconds: 30);

  static const String appName = 'Delivery Driver';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = '\$';
  static const String currencyCode = 'MXN';

  static const List<String> vehicleTypes = [
    'Bicycle',
    'Motorcycle',
    'Car',
    'Scooter',
    'Truck',
  ];

  static const List<String> documentTypes = [
    'Driver License',
    'Vehicle Insurance',
    'Vehicle Registration',
    'Background Check',
    'Health Certificate',
  ];

  static const double minRatingForBonus = 4.5;
  static const double bonusPerDelivery = 5.0;
}
