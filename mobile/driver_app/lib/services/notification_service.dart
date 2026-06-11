import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  final ValueNotifier<Map<String, dynamic>?> notificationNotifier =
      ValueNotifier(null);

  Future<void> initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Notification permission denied');
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _deviceToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_deviceToken');

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _deviceToken = newToken;
      debugPrint('FCM Token refreshed: $newToken');
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpened(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      _showLocalNotification(
        notification.title ?? 'Delivery App',
        notification.body ?? '',
        data: data,
      );
    }

    if (data.isNotEmpty) {
      notificationNotifier.value = data;
    }
  }

  void _handleNotificationOpened(RemoteMessage message) {
    final data = message.data;
    if (data.isNotEmpty) {
      notificationNotifier.value = data;
    }
  }

  Future<void> _showLocalNotification(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'driver_orders',
      'Driver Orders',
      channelDescription: 'Notifications for new orders and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        notificationNotifier.value = data;
      } catch (_) {}
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void dispose() {
    notificationNotifier.dispose();
  }
}
