class DriverDocument {
  final String id;
  final String type;
  final String url;
  final String status;
  final DateTime? expiresAt;
  final DateTime uploadedAt;
  final String? rejectionReason;

  DriverDocument({
    required this.id,
    required this.type,
    required this.url,
    required this.status,
    this.expiresAt,
    required this.uploadedAt,
    this.rejectionReason,
  });

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isExpired => status == 'expired';
  bool get isRejected => status == 'rejected';
  bool get needsAction => isPending || isRejected || isExpired;

  String get statusLabel {
    switch (status) {
      case 'verified':
        return 'Verified';
      case 'pending':
        return 'Pending Review';
      case 'expired':
        return 'Expired';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'driver_license':
        return "Driver's License";
      case 'vehicle_insurance':
        return 'Vehicle Insurance';
      case 'vehicle_registration':
        return 'Vehicle Registration';
      case 'background_check':
        return 'Background Check';
      case 'health_certificate':
        return 'Health Certificate';
      default:
        return type;
    }
  }

  factory DriverDocument.fromJson(Map<String, dynamic> json) {
    return DriverDocument(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      status: json['status'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
      'uploaded_at': uploadedAt.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }
}
