class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? notes;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'notes': notes,
    };
  }
}

class OrderAddress {
  final String street;
  final String number;
  final String? colony;
  final String? city;
  final String? state;
  final String? zipCode;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? instructions;

  OrderAddress({
    required this.street,
    required this.number,
    this.colony,
    this.city,
    this.state,
    this.zipCode,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.instructions,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      colony: json['colony'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      fullAddress: json['full_address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      instructions: json['instructions'] as String?,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String status;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tip;
  final double total;
  final String? driverNote;
  final String createdAt;
  final String? acceptedAt;
  final String? pickedUpAt;
  final String? deliveredAt;
  final String restaurantId;
  final String restaurantName;
  final String restaurantPhone;
  final String restaurantImageUrl;
  final OrderAddress restaurantAddress;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final OrderAddress customerAddress;
  final double distanceKm;
  final int estimatedMinutes;
  final double estimatedPayout;
  final double? driverRating;
  final int itemCount;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tip,
    required this.total,
    this.driverNote,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantPhone,
    required this.restaurantImageUrl,
    required this.restaurantAddress,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.estimatedPayout,
    this.driverRating,
    required this.itemCount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      driverNote: json['driver_note'] as String?,
      createdAt: json['created_at'] as String,
      acceptedAt: json['accepted_at'] as String?,
      pickedUpAt: json['picked_up_at'] as String?,
      deliveredAt: json['delivered_at'] as String?,
      restaurantId: json['restaurant_id'] as String,
      restaurantName: json['restaurant_name'] as String,
      restaurantPhone: json['restaurant_phone'] as String? ?? '',
      restaurantImageUrl: json['restaurant_image_url'] as String? ?? '',
      restaurantAddress:
          OrderAddress.fromJson(json['restaurant_address'] as Map<String, dynamic>),
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String? ?? '',
      customerAddress:
          OrderAddress.fromJson(json['customer_address'] as Map<String, dynamic>),
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 0,
      estimatedPayout: (json['estimated_payout'] as num?)?.toDouble() ?? 0.0,
      driverRating: (json['driver_rating'] as num?)?.toDouble(),
      itemCount: json['item_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'tip': tip,
      'total': total,
      'driver_note': driverNote,
      'created_at': createdAt,
      'accepted_at': acceptedAt,
      'picked_up_at': pickedUpAt,
      'delivered_at': deliveredAt,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'restaurant_phone': restaurantPhone,
      'restaurant_image_url': restaurantImageUrl,
      'restaurant_address': restaurantAddress.toJson(),
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress.toJson(),
      'distance_km': distanceKm,
      'estimated_minutes': estimatedMinutes,
      'estimated_payout': estimatedPayout,
      'driver_rating': driverRating,
      'item_count': itemCount,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'at_restaurant':
        return 'At Restaurant';
      case 'picked_up':
        return 'Picked Up';
      case 'on_route':
        return 'On Route';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
