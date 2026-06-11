class Order {
  final int id;
  final String orderNumber;
  final int? restaurantId;
  final String? restaurantName;
  final String? restaurantLogoUrl;
  final String status;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double? discount;
  final double? tip;
  final double total;
  final String? couponCode;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? paymentMethod;
  final String? driverName;
  final String? driverPhone;
  final String? driverPhotoUrl;
  final String? driverVehicle;
  final double? driverRating;
  final double? driverLatitude;
  final double? driverLongitude;
  final int? estimatedTimeMin;
  final List<OrderStatusHistory> statusHistory;
  final bool isRated;
  final String createdAt;
  final String? updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    this.restaurantId,
    this.restaurantName,
    this.restaurantLogoUrl,
    required this.status,
    this.items = const [],
    required this.subtotal,
    required this.deliveryFee,
    this.discount,
    this.tip,
    required this.total,
    this.couponCode,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.paymentMethod,
    this.driverName,
    this.driverPhone,
    this.driverPhotoUrl,
    this.driverVehicle,
    this.driverRating,
    this.driverLatitude,
    this.driverLongitude,
    this.estimatedTimeMin,
    this.statusHistory = const [],
    this.isRated = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String? ?? '',
      restaurantId: json['restaurant_id'] as int?,
      restaurantName: json['restaurant_name'] as String?,
      restaurantLogoUrl: json['restaurant_logo_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble(),
      tip: (json['tip'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['coupon_code'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      deliveryLatitude: (json['delivery_latitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['delivery_longitude'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String?,
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      driverPhotoUrl: json['driver_photo_url'] as String?,
      driverVehicle: json['driver_vehicle'] as String?,
      driverRating: (json['driver_rating'] as num?)?.toDouble(),
      driverLatitude: (json['driver_latitude'] as num?)?.toDouble(),
      driverLongitude: (json['driver_longitude'] as num?)?.toDouble(),
      estimatedTimeMin: json['estimated_time_min'] as int?,
      statusHistory: (json['status_history'] as List<dynamic>?)
              ?.map(
                  (e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isRated: json['is_rated'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'restaurant_logo_url': restaurantLogoUrl,
        'status': status,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'discount': discount,
        'tip': tip,
        'total': total,
        'coupon_code': couponCode,
        'delivery_address': deliveryAddress,
        'delivery_latitude': deliveryLatitude,
        'delivery_longitude': deliveryLongitude,
        'payment_method': paymentMethod,
        'driver_name': driverName,
        'driver_phone': driverPhone,
        'driver_photo_url': driverPhotoUrl,
        'driver_vehicle': driverVehicle,
        'driver_rating': driverRating,
        'driver_latitude': driverLatitude,
        'driver_longitude': driverLongitude,
        'estimated_time_min': estimatedTimeMin,
        'status_history': statusHistory.map((e) => e.toJson()).toList(),
        'is_rated': isRated,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class OrderItem {
  final int? id;
  final int? productId;
  final String productName;
  final String? productImageUrl;
  final double price;
  final int quantity;
  final String? variantName;
  final List<String> extras;
  final String? notes;

  OrderItem({
    this.id,
    this.productId,
    required this.productName,
    this.productImageUrl,
    required this.price,
    this.quantity = 1,
    this.variantName,
    this.extras = const [],
    this.notes,
  });

  double get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      productName: json['product_name'] as String? ?? '',
      productImageUrl: json['product_image_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      variantName: json['variant_name'] as String?,
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'product_id': productId,
        'product_name': productName,
        'product_image_url': productImageUrl,
        'price': price,
        'quantity': quantity,
        'variant_name': variantName,
        'extras': extras,
        'notes': notes,
      };
}

class OrderStatusHistory {
  final String status;
  final String? note;
  final String createdAt;

  OrderStatusHistory({
    required this.status,
    this.note,
    required this.createdAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: json['status'] as String? ?? '',
      note: json['note'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'note': note,
        'created_at': createdAt,
      };
}
