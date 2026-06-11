class DriverProfile {
  final String id;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String vehicleType;
  final bool isAvailable;
  final String status;
  final double latitude;
  final double longitude;
  final double rating;
  final int totalDeliveries;
  final double totalEarnings;
  final String zone;
  final int acceptanceRate;
  final int onTimeRate;
  final DateTime? memberSince;
  final String? vehiclePlate;

  DriverProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.vehicleType,
    required this.isAvailable,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.zone,
    this.acceptanceRate = 100,
    this.onTimeRate = 100,
    this.memberSince,
    this.vehiclePlate,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      vehicleType: json['vehicle_type'] as String,
      isAvailable: json['is_available'] as bool? ?? false,
      status: json['status'] as String? ?? 'offline',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      zone: json['zone'] as String? ?? 'Unknown',
      acceptanceRate: json['acceptance_rate'] as int? ?? 100,
      onTimeRate: json['on_time_rate'] as int? ?? 100,
      memberSince: json['member_since'] != null
          ? DateTime.parse(json['member_since'] as String)
          : null,
      vehiclePlate: json['vehicle_plate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'vehicle_type': vehicleType,
      'is_available': isAvailable,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'total_earnings': totalEarnings,
      'zone': zone,
      'acceptance_rate': acceptanceRate,
      'on_time_rate': onTimeRate,
      'member_since': memberSince?.toIso8601String(),
      'vehicle_plate': vehiclePlate,
    };
  }

  DriverProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? vehicleType,
    bool? isAvailable,
    String? status,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalDeliveries,
    double? totalEarnings,
    String? zone,
    int? acceptanceRate,
    int? onTimeRate,
    DateTime? memberSince,
    String? vehiclePlate,
  }) {
    return DriverProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      zone: zone ?? this.zone,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      onTimeRate: onTimeRate ?? this.onTimeRate,
      memberSince: memberSince ?? this.memberSince,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    );
  }
}
