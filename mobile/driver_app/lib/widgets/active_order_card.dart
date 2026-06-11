import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/order.dart';
import '../utils/formatters.dart';

class ActiveOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const ActiveOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppTheme.primary,
                      size: 22,
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
                        Text(
                          'Order #${order.orderNumber}',
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_pin,
                      size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.customerAddress.fullAddress,
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoChip(
                    Icons.timer_outlined,
                    '${order.estimatedMinutes} min',
                  ),
                  const SizedBox(width: 8),
                  _infoChip(
                    Icons.attach_money,
                    AppFormatters.currency(order.estimatedPayout),
                  ),
                  const SizedBox(width: 8),
                  _infoChip(
                    Icons.straighten,
                    '${order.distanceKm.toStringAsFixed(1)} km',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: AppTheme.divider,
                valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              ),
              const SizedBox(height: 6),
              Text(
                _progressLabel,
                style: AppTheme.caption.copyWith(color: _statusColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (order.status) {
      case 'accepted':
        return AppTheme.secondary;
      case 'at_restaurant':
      case 'picked_up':
        return AppTheme.accent;
      case 'on_route':
        return AppTheme.primary;
      case 'delivered':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  double get _progressValue {
    switch (order.status) {
      case 'accepted':
        return 0.25;
      case 'at_restaurant':
        return 0.5;
      case 'picked_up':
        return 0.6;
      case 'on_route':
        return 0.85;
      case 'delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String get _progressLabel {
    switch (order.status) {
      case 'accepted':
        return 'Heading to restaurant';
      case 'at_restaurant':
        return 'Waiting for order';
      case 'picked_up':
        return 'Heading to customer';
      case 'on_route':
        return 'Almost there';
      case 'delivered':
        return 'Completed';
      default:
        return '';
    }
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(text, style: AppTheme.caption),
        ],
      ),
    );
  }
}
