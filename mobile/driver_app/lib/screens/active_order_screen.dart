import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/order_provider.dart';
import '../providers/location_provider.dart';
import '../models/order.dart';
import '../utils/formatters.dart';
import '../utils/location_helper.dart';

class ActiveOrderScreen extends StatefulWidget {
  const ActiveOrderScreen({super.key});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchActiveOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Active Order'),
        actions: [
          TextButton(
            onPressed: _showProblemDialog,
            child: const Text(
              'Problem?',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (_, orderProv, __) {
          final order = orderProv.activeOrder;
          if (order == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: AppTheme.success),
                  SizedBox(height: 16),
                  Text(
                    'No active order',
                    style: AppTheme.heading2,
                  ),
                ],
              ),
            );
          }

          if (orderProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => orderProv.fetchActiveOrder(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusProgress(order),
                  const SizedBox(height: 16),
                  _buildPickupSection(order),
                  const SizedBox(height: 12),
                  _buildDeliverySection(order),
                  const SizedBox(height: 12),
                  _buildOrderSummary(order),
                  const SizedBox(height: 16),
                  _buildActionButton(order, orderProv),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusProgress(Order order) {
    final statuses = ['accepted', 'at_restaurant', 'picked_up', 'on_route', 'delivered'];
    final labels = ['Accepted', 'At Restaurant', 'Picked Up', 'On Route', 'Delivered'];
    final icons = [
      Icons.check_circle,
      Icons.restaurant,
      Icons.shopping_bag,
      Icons.directions_car,
      Icons.home,
    ];

    int currentIndex = statuses.indexOf(order.status);
    if (currentIndex == -1) currentIndex = 0;
    if (order.status == 'delivered') currentIndex = 4;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Progress', style: AppTheme.heading3),
            const SizedBox(height: 16),
            ...List.generate(statuses.length, (index) {
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isCompleted ? icons[index] : Icons.radio_button_unchecked,
                      size: 24,
                      color: isCompleted ? AppTheme.primary : AppTheme.textHint,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCompleted
                            ? AppTheme.textPrimary
                            : AppTheme.textHint,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupSection(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pick up from ${order.restaurantName}',
                    style: AppTheme.heading3,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.restaurantAddress.fullAddress,
                    style: AppTheme.bodyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Items to collect: ${order.itemCount}',
              style: AppTheme.bodySmall,
            ),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('${item.quantity}x ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        Expanded(child: Text(item.name)),
                      ],
                    ),
                  )),
            ],
            if (order.restaurantAddress.instructions != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.restaurantAddress.instructions!,
                        style: AppTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_pin, color: AppTheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deliver to ${order.customerName}',
                    style: AppTheme.heading3,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.customerAddress.fullAddress,
                    style: AppTheme.bodyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(order.customerPhone, style: AppTheme.bodyText),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.phone_in_talk,
                      size: 20, color: AppTheme.primary),
                  onPressed: () => _launchPhone(order.customerPhone),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            if (order.customerAddress.instructions != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes,
                        size: 16, color: AppTheme.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.customerAddress.instructions!,
                        style: AppTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${order.orderNumber}', style: AppTheme.heading3),
            const Divider(),
            _summaryRow('Subtotal', AppFormatters.currency(order.subtotal)),
            _summaryRow('Delivery Fee', AppFormatters.currency(order.deliveryFee)),
            if (order.tip > 0)
              _summaryRow(
                'Tip',
                AppFormatters.currency(order.tip),
                valueColor: AppTheme.success,
              ),
            const Divider(thickness: 1),
            _summaryRow(
              'Total',
              AppFormatters.currency(order.total),
              valueStyle: AppTheme.bodyText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {Color? valueColor, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodySmall),
          Text(
            value,
            style: valueStyle ??
                AppTheme.bodyText.copyWith(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Order order, OrderProvider orderProv) {
    final status = order.status;
    String buttonLabel;
    VoidCallback? onPressed;

    if (status == 'accepted') {
      buttonLabel = 'NAVIGATE TO RESTAURANT';
      onPressed = () => Navigator.pushNamed(context, '/navigation');
    } else if (status == 'at_restaurant') {
      buttonLabel = 'I\'VE PICKED UP THE ORDER';
      onPressed = () => _handlePickup(order.id);
    } else if (status == 'picked_up') {
      buttonLabel = 'NAVIGATE TO CUSTOMER';
      onPressed = () => Navigator.pushNamed(context, '/navigation');
    } else if (status == 'on_route') {
      buttonLabel = 'COMPLETE DELIVERY';
      onPressed = () => _handleDelivery(order.id);
    } else {
      buttonLabel = 'DELIVERED';
      onPressed = null;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          status == 'delivered' ? Icons.check_circle : Icons.navigation,
        ),
        label: Text(buttonLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              status == 'delivered' ? AppTheme.success : AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePickup(String orderId) async {
    final orderProv = context.read<OrderProvider>();
    final success = await orderProv.markPickedUp(orderId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order picked up!'),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProv.error ?? 'Failed to update'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDelivery(String orderId) async {
    final orderProv = context.read<OrderProvider>();
    final success = await orderProv.markDelivered(orderId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery completed!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProv.error ?? 'Failed to complete delivery'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showProblemDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Report a Problem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _problemOption(ctx, 'Restaurant is closed', Icons.restaurant),
            _problemOption(ctx, 'Can\'t find customer address', Icons.location_off),
            _problemOption(
                ctx, 'Order is incorrect', Icons.error_outline),
            _problemOption(ctx, 'Customer is not responding', Icons.phone_disabled),
            _problemOption(ctx, 'Other issue', Icons.more_horiz),
          ],
        ),
      ),
    );
  }

  Widget _problemOption(BuildContext ctx, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(label),
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report submitted: $label'),
            backgroundColor: AppTheme.success,
          ),
        );
      },
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
