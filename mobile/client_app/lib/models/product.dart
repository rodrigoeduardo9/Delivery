class Product {
  final int id;
  final int restaurantId;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final String? category;
  final bool isAvailable;
  final bool isPopular;
  final List<ProductVariant> variants;
  final List<Extra> extras;
  final int? preparationTime;

  Product({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    this.originalPrice,
    this.category,
    this.isAvailable = true,
    this.isPopular = false,
    this.variants = const [],
    this.extras = const [],
    this.preparationTime,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      category: json['category'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isPopular: json['is_popular'] as bool? ?? false,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => Extra.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      preparationTime: json['preparation_time'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'price': price,
        'original_price': originalPrice,
        'category': category,
        'is_available': isAvailable,
        'is_popular': isPopular,
        'variants': variants.map((e) => e.toJson()).toList(),
        'extras': extras.map((e) => e.toJson()).toList(),
        'preparation_time': preparationTime,
      };
}

class ProductVariant {
  final int id;
  final String name;
  final double priceAdjustment;
  final bool isDefault;

  ProductVariant({
    required this.id,
    required this.name,
    this.priceAdjustment = 0.0,
    this.isDefault = false,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      priceAdjustment: (json['price_adjustment'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price_adjustment': priceAdjustment,
        'is_default': isDefault,
      };
}

class Extra {
  final int id;
  final String name;
  final double price;
  final bool isDefault;

  Extra({
    required this.id,
    required this.name,
    this.price = 0.0,
    this.isDefault = false,
  });

  factory Extra.fromJson(Map<String, dynamic> json) {
    return Extra(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'is_default': isDefault,
      };
}
