import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/order_provider.dart';
import '../providers/location_provider.dart';
import '../models/order.dart';
import '../widgets/order_card_driver.dart';
import '../widgets/empty_state_driver.dart';

class AvailableOrdersScreen extends StatefulWidget {
  const AvailableOrdersScreen({super.key});

  @override
  State<AvailableOrdersScreen> createState() => _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends State<AvailableOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchAvailableOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Available Orders'),
      ),
      body: Consumer2<OrderProvider, LocationProvider>(
        builder: (_, orderProv, locProv, __) {
          if (orderProv.isLoading && orderProv.availableOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProv.availableOrders.isEmpty) {
            return EmptyStateDriver(
              icon: Icons.inventory_2_outlined,
              title: 'No orders available',
              subtitle: 'No orders available in your area',
              actionLabel: 'Refresh',
              onAction: () => orderProv.fetchAvailableOrders(),
              child: _buildMiniMap(locProv),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProv.fetchAvailableOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: orderProv.availableOrders.length,
              itemBuilder: (_, index) {
                final order = orderProv.availableOrders[index];
                return OrderCardDriver(
                  order: order,
                  onAccept: () => _showAcceptDialog(order),
                  onSkip: () => _handleSkip(order),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniMap(LocationProvider locProv) {
    final initialPos = locProv.currentPosition;
    return Container(
      height: 150,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            initialPos?.latitude ?? AppConstants.mapDefaultLatitude,
            initialPos?.longitude ?? AppConstants.mapDefaultLongitude,
          ),
          zoom: 12,
        ),
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
      ),
    );
  }

  void _showAcceptDialog(Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Accept Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.restaurantName,
                    style: AppTheme.heading3,
                  ),
                ),
              ],
            ),
            const Divider(),
            _detailRow(Icons.delivery_dining, 'Distance',
                '${order.distanceKm.toStringAsFixed(1)} km'),
            const SizedBox(height: 4),
            _detailRow(Icons.shopping_bag, 'Items', '${order.itemCount} items'),
            const SizedBox(height: 4),
            _detailRow(Icons.timer_outlined, 'Est. Time',
                '${order.estimatedMinutes} min'),
            const SizedBox(height: 4),
            _detailRow(Icons.attach_money, 'Payout',
                '\$${order.estimatedPayout.toStringAsFixed(2)}'),
            if (order.driverNote != null) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${order.driverNote}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.accent,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleAccept(order);
            },
            child: const Text('Accept Order'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.bodySmall),
        const Spacer(),
        Text(value, style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _handleAccept(Order order) async {
    final orderProv = context.read<OrderProvider>();
    final success = await orderProv.acceptOrder(order.id);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order accepted!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pushReplacementNamed(context, '/active-order');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProv.error ?? 'Failed to accept order'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSkip(Order order) async {
    final orderProv = context.read<OrderProvider>();
    await orderProv.rejectOrder(order.id);
  }
}
