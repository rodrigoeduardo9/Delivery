class Review {
  final int id;
  final int? orderId;
  final int? restaurantId;
  final int? productId;
  final String? userName;
  final String? userAvatarUrl;
  final double rating;
  final String? comment;
  final String? response;
  final List<String>? images;
  final String createdAt;

  Review({
    required this.id,
    this.orderId,
    this.restaurantId,
    this.productId,
    this.userName,
    this.userAvatarUrl,
    required this.rating,
    this.comment,
    this.response,
    this.images,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      orderId: json['order_id'] as int?,
      restaurantId: json['restaurant_id'] as int?,
      productId: json['product_id'] as int?,
      userName: json['user_name'] as String?,
      userAvatarUrl: json['user_avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String?,
      response: json['response'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'restaurant_id': restaurantId,
        'product_id': productId,
        'user_name': userName,
        'user_avatar_url': userAvatarUrl,
        'rating': rating,
        'comment': comment,
        'response': response,
        'images': images,
        'created_at': createdAt,
      };
}
