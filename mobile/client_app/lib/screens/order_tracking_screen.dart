import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../utils/formatters.dart';
import '../widgets/driver_info_card.dart';
import '../widgets/order_progress_stepper.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startTracking(widget.orderId);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          Consumer<OrderProvider>(
            builder: (context, provider, _) {
              final order = provider.trackingOrder;
              if (order == null || order.status == 'delivered' || order.status == 'cancelled') {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.startTracking(widget.orderId),
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.trackingOrder == null) {
            return const LoadingShimmerList();
          }

          final order = provider.trackingOrder;
          if (order == null) {
            return ErrorState(
              message: provider.error ?? 'Could not load order',
              onRetry: () => provider.startTracking(widget.orderId),
            );
          }

          return _buildContent(order, provider);
        },
      ),
    );
  }

  Widget _buildContent(Order order, OrderProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMapSection(order),
          const SizedBox(height: 16),
          _buildETA(order),
          const SizedBox(height: 16),
          DriverInfoCard(
            driverName: order.driverName,
            driverPhotoUrl: order.driverPhotoUrl,
            driverPhone: order.driverPhone,
            driverVehicle: order.driverVehicle,
            driverRating: order.driverRating,
          ),
          const SizedBox(height: 24),
          const Text(
            'Order Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          OrderProgressStepper(currentStatus: order.status),
          const SizedBox(height: 24),
          _buildActionButtons(order),
          const SizedBox(height: 16),
          _buildOrderDetails(order),
        ],
      ),
    );
  }

  Widget _buildMapSection(Order order) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map, size: 48, color: AppTheme.textHint),
                const SizedBox(height: 8),
                const Text('Live Map', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  'Google Maps will render here',
                  style: TextStyle(fontSize: 12, color: AppTheme.textHint.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          if (order.driverLatitude != null && order.driverLongitude != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.onlineGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.brightness_1, size: 8, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Live', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildETA(Order order) {
    if (order.estimatedTimeMin == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated arrival',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                '${order.estimatedTimeMin} minutes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    if (order.status == 'delivered' || order.status == 'cancelled') {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (order.driverPhone != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse('tel:${order.driverPhone}')),
              icon: const Icon(Icons.phone),
              label: const Text('Contact Driver'),
            ),
          ),
        if (order.driverPhone != null) const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Chat'),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Order order) {
    return ExpansionTile(
      title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.restaurantName ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Expanded(child: Text(item.productName)),
                    Text(Formatters.currency(item.price * item.quantity)),
                  ],
                ),
              )),
              const Divider(height: 16),
              _detailRow('Subtotal', Formatters.currency(order.subtotal)),
              _detailRow('Delivery', Formatters.currency(order.deliveryFee)),
              if (order.discount != null && order.discount! > 0)
                _detailRow('Discount', '-${Formatters.currency(order.discount!)}'),
              if (order.tip != null && order.tip! > 0)
                _detailRow('Tip', Formatters.currency(order.tip!)),
              _detailRow('Total', Formatters.currency(order.total), bold: true),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600, fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }
}
