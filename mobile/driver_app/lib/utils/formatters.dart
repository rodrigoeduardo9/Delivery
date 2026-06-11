import 'package:intl/intl.dart';
import '../config/constants.dart';

class AppFormatters {
  static final _currencyFormat = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
    locale: 'es_MX',
  );

  static final _compactCurrencyFormat = NumberFormat.compactCurrency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 1,
    locale: 'es_MX',
  );

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy - HH:mm');
  static final _shortDateFormat = DateFormat('MMM d');
  static final _dayFormat = DateFormat('EEEE');
  static final _monthYearFormat = DateFormat('MMMM yyyy');

  static String currency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String compactCurrency(double amount) {
    return _compactCurrencyFormat.format(amount);
  }

  static String date(DateTime date) {
    return _dateFormat.format(date);
  }

  static String time(DateTime date) {
    return _timeFormat.format(date);
  }

  static String dateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String shortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String dayOfWeek(DateTime date) {
    return _dayFormat.format(date);
  }

  static String monthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String distance(double kilometers) {
    if (kilometers < 1) {
      return '${(kilometers * 1000).toStringAsFixed(0)} m';
    }
    return '${kilometers.toStringAsFixed(1)} km';
  }

  static String durationMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}min';
  }

  static String timeSince(DateTime dateTime) {
    final now = DateTime.now();
    final duration = now.difference(dateTime);

    if (duration.inSeconds < 60) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      final minutes = duration.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (duration.inDays < 7) {
      final days = duration.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return date(dateTime);
    }
  }

  static String rating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String percentage(int value) {
    return '$value%';
  }

  static String deliveryCount(int count) {
    return '$count delivery${count == 1 ? '' : 'ies'}';
  }

  static String orderNumber(String orderNum) {
    return '#$orderNum';
  }

  static String phone(String phone) {
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone;
  }
}
