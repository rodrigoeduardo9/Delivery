class Restaurant {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? category;
  final double rating;
  final int reviewCount;
  final double? distance;
  final int deliveryTimeMin;
  final int deliveryTimeMax;
  final double deliveryFee;
  final double? minOrder;
  final bool isOpen;
  final bool isFavorite;
  final List<String>? tags;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? openingHours;

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.distance,
    this.deliveryTimeMin = 30,
    this.deliveryTimeMax = 45,
    this.deliveryFee = 0.0,
    this.minOrder,
    this.isOpen = true,
    this.isFavorite = false,
    this.tags,
    this.address,
    this.latitude,
    this.longitude,
    this.openingHours,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      distance: (json['distance'] as num?)?.toDouble(),
      deliveryTimeMin: json['delivery_time_min'] as int? ?? 30,
      deliveryTimeMax: json['delivery_time_max'] as int? ?? 45,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      minOrder: (json['min_order'] as num?)?.toDouble(),
      isOpen: json['is_open'] as bool? ?? true,
      isFavorite: json['is_favorite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      openingHours: json['opening_hours'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'logo_url': logoUrl,
        'banner_url': bannerUrl,
        'category': category,
        'rating': rating,
        'review_count': reviewCount,
        'distance': distance,
        'delivery_time_min': deliveryTimeMin,
        'delivery_time_max': deliveryTimeMax,
        'delivery_fee': deliveryFee,
        'min_order': minOrder,
        'is_open': isOpen,
        'is_favorite': isFavorite,
        'tags': tags,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'opening_hours': openingHours,
      };
}

class RestaurantCategory {
  final int id;
  final String name;
  final String? icon;
  final bool isActive;

  RestaurantCategory({
    required this.id,
    required this.name,
    this.icon,
    this.isActive = true,
  });

  factory RestaurantCategory.fromJson(Map<String, dynamic> json) {
    return RestaurantCategory(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'is_active': isActive,
      };
}
