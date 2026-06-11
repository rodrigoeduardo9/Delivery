import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/order.dart';
import '../utils/formatters.dart';

class OrderCardDriver extends StatelessWidget {
  final Order order;
  final VoidCallback? onAccept;
  final VoidCallback? onSkip;

  const OrderCardDriver({
    super.key,
    required this.order,
    this.onAccept,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final orderTime = DateTime.parse(order.createdAt);
    final timeSince = DateTime.now().difference(orderTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: order.restaurantImageUrl.isNotEmpty
                        ? Image.network(
                            order.restaurantImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.restaurant,
                              color: AppTheme.primary,
                            ),
                          )
                        : const Icon(Icons.restaurant, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName,
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 2),
                          Text(
                            '${order.distanceKm.toStringAsFixed(1)} km',
                            style: AppTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time,
                              size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 2),
                          Text(
                            '${order.estimatedMinutes} min',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppFormatters.currency(order.estimatedPayout),
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeSince(timeSince),
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_pin,
                      size: 16, color: AppTheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerAddress.fullAddress,
                      style: AppTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${order.itemCount} items',
                    style: AppTheme.caption.copyWith(color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${order.orderNumber}',
                    style: AppTheme.caption.copyWith(color: AppTheme.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('ACCEPT'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('SKIP'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeSince(Duration duration) {
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    return '${duration.inHours}h ago';
  }
}
