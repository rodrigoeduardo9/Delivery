import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy h:mm a');

  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String date(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _dateFormat.format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String time(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _timeFormat.format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String dateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _dateTimeFormat.format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String distance(double? kilometers) {
    if (kilometers == null) return '';
    if (kilometers < 1) {
      return '${(kilometers * 1000).round()} m';
    }
    return '${kilometers.toStringAsFixed(1)} km';
  }

  static String deliveryTime(int min, int max) {
    if (min == max) return '$min min';
    return '$min - $max min';
  }

  static String pluralize(int count, String singular, [String? plural]) {
    return count == 1 ? '$count $singular' : '$count ${plural ?? '${singular}s'}';
  }
}
