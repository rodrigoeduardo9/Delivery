class AppConstants {
  static const String appName = 'FoodDelivery';
  static const String appVersion = '1.0.0';

  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 20.0;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  static const int orderPollInterval = 5;
  static const int searchDebounceMs = 500;

  static const double defaultMapZoom = 15.0;
  static const double deliveryFee = 39.0;
  static const double freeDeliveryThreshold = 200.0;

  static const List<double> tipPercentages = [10, 15, 20];
}
