class Coupon {
  final String code;
  final double discount;
  final String discountType;
  final double? minOrder;
  final double? maxDiscount;
  final bool isValid;
  final String? expiresAt;

  Coupon({
    required this.code,
    required this.discount,
    required this.discountType,
    this.minOrder,
    this.maxDiscount,
    required this.isValid,
    this.expiresAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      code: json['code'] as String? ?? '',
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] as String? ?? 'percentage',
      minOrder: (json['min_order'] as num?)?.toDouble(),
      maxDiscount: (json['max_discount'] as num?)?.toDouble(),
      isValid: json['is_valid'] as bool? ?? false,
      expiresAt: json['expires_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'discount': discount,
        'discount_type': discountType,
        'min_order': minOrder,
        'max_discount': maxDiscount,
        'is_valid': isValid,
        'expires_at': expiresAt,
      };

  double calculateDiscount(double subtotal) {
    if (!isValid) return 0;
    if (minOrder != null && subtotal < minOrder!) return 0;
    double disc;
    if (discountType == 'percentage') {
      disc = subtotal * (discount / 100);
    } else {
      disc = discount;
    }
    if (maxDiscount != null && disc > maxDiscount!) {
      disc = maxDiscount!;
    }
    return disc;
  }
}
