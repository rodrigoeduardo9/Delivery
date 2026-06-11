import '../models/api_response.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class AppNotification {
  final int id;
  final String title;
  final String body;
  final String? type;
  final int? referenceId;
  final bool isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String?,
      referenceId: json['reference_id'] as int?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'reference_id': referenceId,
        'is_read': isRead,
        'created_at': createdAt,
      };
}

class NotificationService {
  final ApiService _api = ApiService();

  Future<ApiResponse<List<AppNotification>>> getNotifications({int page = 1}) async {
    try {
      final data = await _api.get(ApiConfig.notifications, queryParams: {
        'page': page.toString(),
      });
      return ApiResponse.fromJson(data as Map<String, dynamic>,
          (d) => (d['data'] as List?)?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList() ?? []);
    } on ApiException catch (e) {
      return ApiResponse<List<AppNotification>>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<void>> markAsRead(int notificationId) async {
    try {
      await _api.post('${ApiConfig.markNotificationRead}$notificationId/read');
      return ApiResponse<void>(success: true);
    } on ApiException catch (e) {
      return ApiResponse<void>(success: false, message: e.message, errors: e.errors);
    }
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      await _api.post('${ApiConfig.notifications}/read-all');
      return ApiResponse<void>(success: true);
    } on ApiException catch (e) {
      return ApiResponse<void>(success: false, message: e.message, errors: e.errors);
    }
  }
}
