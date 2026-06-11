class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final bool emailVerified;
  final bool phoneVerified;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'email_verified': emailVerified,
        'phone_verified': phoneVerified,
        'created_at': createdAt,
      };
}

class Address {
  final int? id;
  final String alias;
  final String street;
  final String? number;
  final String? colony;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? reference;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Address({
    this.id,
    required this.alias,
    required this.street,
    this.number,
    this.colony,
    this.city,
    this.state,
    this.zipCode,
    this.reference,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int?,
      alias: json['alias'] as String? ?? '',
      street: json['street'] as String? ?? '',
      number: json['number'] as String?,
      colony: json['colony'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      reference: json['reference'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'alias': alias,
        'street': street,
        'number': number,
        'colony': colony,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'reference': reference,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      };

  String get fullAddress =>
      '$street${number != null ? ' #$number' : ''}${colony != null ? ', $colony' : ''}${city != null ? ', $city' : ''}${state != null ? ', $state' : ''}';
}
