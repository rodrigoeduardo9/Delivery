class DriverBasic {
  final int id;
  final String name;
  final String? photoUrl;
  final String? phone;
  final String? vehicleType;
  final String? vehiclePlate;
  final double rating;
  final double? latitude;
  final double? longitude;
  final bool isAvailable;

  DriverBasic({
    required this.id,
    required this.name,
    this.photoUrl,
    this.phone,
    this.vehicleType,
    this.vehiclePlate,
    this.rating = 0.0,
    this.latitude,
    this.longitude,
    this.isAvailable = true,
  });

  factory DriverBasic.fromJson(Map<String, dynamic> json) {
    return DriverBasic(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      phone: json['phone'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photo_url': photoUrl,
        'phone': phone,
        'vehicle_type': vehicleType,
        'vehicle_plate': vehiclePlate,
        'rating': rating,
        'latitude': latitude,
        'longitude': longitude,
        'is_available': isAvailable,
      };
}
