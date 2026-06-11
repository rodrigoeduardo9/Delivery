import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    final result = await _notificationService.getNotifications();
    if (result.success && result.data != null) {
      _notifications = result.data!;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    final result = await _notificationService.markAsRead(notificationId);
    if (result.success) {
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx >= 0) {
        final old = _notifications[idx];
        _notifications[idx] = AppNotification(
          id: old.id,
          title: old.title,
          body: old.body,
          type: old.type,
          referenceId: old.referenceId,
          isRead: true,
          createdAt: old.createdAt,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final result = await _notificationService.markAllAsRead();
    if (result.success) {
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        referenceId: n.referenceId,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    }
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      final removed = _notifications.removeAt(index);
      if (!removed.isRead && _unreadCount > 0) {
        _unreadCount--;
      }
      notifyListeners();
    }
  }

  void addNotificationFromFCM(AppNotification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }
}
