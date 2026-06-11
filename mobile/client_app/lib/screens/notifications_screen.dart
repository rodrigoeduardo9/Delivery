import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_item.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const LoadingShimmerList();
          }

          if (provider.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No notifications',
              subtitle: 'You\'re all caught up!',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadNotifications(),
            child: ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (_, index) {
                final notif = provider.notifications[index];
                return NotificationItem(
                  notification: notif,
                  onTap: () => provider.markAsRead(notif.id),
                  onDismiss: () => provider.removeNotification(index),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
