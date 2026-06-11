import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order.dart';
import '../config/theme.dart';
import '../utils/formatters.dart';
import 'loading_shimmer.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.restaurantLogoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: CachedNetworkImage(
                      imageUrl: order.restaurantLogoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ShimmerWidget(width: 56, height: 56),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.divider,
                        child: const Icon(Icons.restaurant, color: AppTheme.textHint),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName ?? 'Order #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.dateTime(order.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${order.items.length} items',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          Formatters.currency(order.total),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (order.status) {
      case 'pending':
      case 'confirmed':
        bgColor = AppTheme.warning.withOpacity(0.15);
        textColor = AppTheme.warning;
        label = order.status == 'pending' ? 'Pending' : 'Confirmed';
        break;
      case 'preparing':
        bgColor = AppTheme.primary.withOpacity(0.15);
        textColor = AppTheme.primary;
        label = 'Preparing';
        break;
      case 'on_the_way':
        bgColor = AppTheme.secondary.withOpacity(0.15);
        textColor = AppTheme.secondary;
        label = 'On the way';
        break;
      case 'delivered':
        bgColor = AppTheme.success.withOpacity(0.15);
        textColor = AppTheme.success;
        label = 'Delivered';
        break;
      case 'cancelled':
        bgColor = AppTheme.error.withOpacity(0.15);
        textColor = AppTheme.error;
        label = 'Cancelled';
        break;
      default:
        bgColor = AppTheme.divider;
        textColor = AppTheme.textSecondary;
        label = order.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
