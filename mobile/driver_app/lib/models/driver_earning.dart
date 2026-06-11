class DriverEarning {
  final String id;
  final String? orderId;
  final String? orderNumber;
  final DateTime date;
  final double amount;
  final double tip;
  final double bonus;
  final String type;
  final String? description;

  DriverEarning({
    required this.id,
    this.orderId,
    this.orderNumber,
    required this.date,
    required this.amount,
    required this.tip,
    required this.bonus,
    required this.type,
    this.description,
  });

  double get total => amount + tip + bonus;

  factory DriverEarning.fromJson(Map<String, dynamic> json) {
    return DriverEarning(
      id: json['id'] as String,
      orderId: json['order_id'] as String?,
      orderNumber: json['order_number'] as String?,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_number': orderNumber,
      'date': date.toIso8601String(),
      'amount': amount,
      'tip': tip,
      'bonus': bonus,
      'type': type,
      'description': description,
    };
  }

  String get typeLabel {
    switch (type) {
      case 'delivery':
        return 'Delivery';
      case 'tip':
        return 'Tip';
      case 'bonus':
        return 'Bonus';
      case 'adjustment':
        return 'Adjustment';
      default:
        return type;
    }
  }
}

class EarningsSummary {
  final double todayAmount;
  final double todayTips;
  final double todayBonus;
  final int todayDeliveries;
  final double weekAmount;
  final double weekTips;
  final double weekBonus;
  final int weekDeliveries;
  final double monthAmount;
  final double monthTips;
  final double monthBonus;
  final int monthDeliveries;
  final List<DriverEarning> recentEarnings;

  EarningsSummary({
    required this.todayAmount,
    required this.todayTips,
    required this.todayBonus,
    required this.todayDeliveries,
    required this.weekAmount,
    required this.weekTips,
    required this.weekBonus,
    required this.weekDeliveries,
    required this.monthAmount,
    required this.monthTips,
    required this.monthBonus,
    required this.monthDeliveries,
    required this.recentEarnings,
  });

  double get todayTotal => todayAmount + todayTips + todayBonus;
  double get weekTotal => weekAmount + weekTips + weekBonus;
  double get monthTotal => monthAmount + monthTips + monthBonus;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      todayAmount: (json['today_amount'] as num?)?.toDouble() ?? 0.0,
      todayTips: (json['today_tips'] as num?)?.toDouble() ?? 0.0,
      todayBonus: (json['today_bonus'] as num?)?.toDouble() ?? 0.0,
      todayDeliveries: json['today_deliveries'] as int? ?? 0,
      weekAmount: (json['week_amount'] as num?)?.toDouble() ?? 0.0,
      weekTips: (json['week_tips'] as num?)?.toDouble() ?? 0.0,
      weekBonus: (json['week_bonus'] as num?)?.toDouble() ?? 0.0,
      weekDeliveries: json['week_deliveries'] as int? ?? 0,
      monthAmount: (json['month_amount'] as num?)?.toDouble() ?? 0.0,
      monthTips: (json['month_tips'] as num?)?.toDouble() ?? 0.0,
      monthBonus: (json['month_bonus'] as num?)?.toDouble() ?? 0.0,
      monthDeliveries: json['month_deliveries'] as int? ?? 0,
      recentEarnings: (json['recent_earnings'] as List<dynamic>?)
              ?.map(
                  (e) => DriverEarning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WeeklyEarning {
  final DateTime date;
  final double amount;

  WeeklyEarning({required this.date, required this.amount});

  factory WeeklyEarning.fromJson(Map<String, dynamic> json) {
    return WeeklyEarning(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
