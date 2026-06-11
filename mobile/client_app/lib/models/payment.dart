class Payment {
  final int id;
  final int? orderId;
  final String? orderNumber;
  final double amount;
  final String method;
  final String status;
  final String? transactionId;
  final String createdAt;

  Payment({
    required this.id,
    this.orderId,
    this.orderNumber,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      orderId: json['order_id'] as int?,
      orderNumber: json['order_number'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? '',
      transactionId: json['transaction_id'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'order_number': orderNumber,
        'amount': amount,
        'method': method,
        'status': status,
        'transaction_id': transactionId,
        'created_at': createdAt,
      };
}

class PaymentMethod {
  final int? id;
  final String type;
  final String? lastFour;
  final String? cardHolderName;
  final String? expiryDate;
  final String? brand;
  final bool isDefault;

  PaymentMethod({
    this.id,
    required this.type,
    this.lastFour,
    this.cardHolderName,
    this.expiryDate,
    this.brand,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int?,
      type: json['type'] as String? ?? '',
      lastFour: json['last_four'] as String?,
      cardHolderName: json['card_holder_name'] as String?,
      expiryDate: json['expiry_date'] as String?,
      brand: json['brand'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'type': type,
        'last_four': lastFour,
        'card_holder_name': cardHolderName,
        'expiry_date': expiryDate,
        'brand': brand,
        'is_default': isDefault,
      };

  String get displayName {
    if (type == 'cash') return 'Cash';
    if (type == 'card' && lastFour != null) return '•••• $lastFour';
    if (type == 'wallet') return 'Wallet Balance';
    return type;
  }
}
