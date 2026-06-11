import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../widgets/order_progress_stepper.dart';
import '../widgets/rating_widget.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderService = OrderService();
  Order? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _orderService.getOrderDetail(widget.orderId);
    if (result.success && result.data != null) {
      setState(() => _order = result.data);
    } else {
      setState(() => _error = result.message);
    }
    setState(() => _isLoading = false);
  }

  void _showRatingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: RatingInputWidget(
          onSubmitted: (rating) async {
            Navigator.pop(context);
            final provider = context.read<OrderProvider>();
            final success = await provider.rateOrder(widget.orderId, rating: rating);
            if (success) {
              _loadOrder();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your rating!')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: _isLoading
          ? const LoadingShimmerList()
          : _error != null
              ? ErrorState(message: _error, onRetry: _loadOrder)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final order = _order!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(order),
          const SizedBox(height: 24),
          const Text('Order Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          OrderProgressStepper(currentStatus: order.status),
          const SizedBox(height: 24),
          const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          ...order.items.map((item) => _buildItemRow(item)),
          const Divider(height: 24),
          _buildPriceSummary(order),
          const SizedBox(height: 24),
          _buildInfoSection('Delivery Address', order.deliveryAddress ?? 'N/A', Icons.location_on_outlined),
          const SizedBox(height: 12),
          _buildInfoSection('Payment Method', order.paymentMethod ?? 'N/A', Icons.payment_outlined),
          if (order.statusHistory.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Status Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            ...order.statusHistory.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    h.status.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(Formatters.dateTime(h.createdAt), style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                ],
              ),
            )),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(order),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.restaurantName ?? 'Order',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Order #${order.orderNumber}', style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(Formatters.dateTime(order.createdAt), style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
        return AppTheme.warning;
      case 'preparing':
        return AppTheme.primary;
      case 'on_the_way':
        return AppTheme.secondary;
      case 'delivered':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (item.variantName != null)
                  Text(item.variantName!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                if (item.extras.isNotEmpty)
                  Text(item.extras.join(', '), style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
              ],
            ),
          ),
          Text(Formatters.currency(item.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(Order order) {
    return Column(
      children: [
        _summaryRow('Subtotal', Formatters.currency(order.subtotal)),
        _summaryRow('Delivery', Formatters.currency(order.deliveryFee)),
        if (order.discount != null && order.discount! > 0)
          _summaryRow('Discount', '-${Formatters.currency(order.discount!)}'),
        if (order.tip != null && order.tip! > 0)
          _summaryRow('Tip', Formatters.currency(order.tip!)),
        const Divider(height: 16),
        _summaryRow('Total', Formatters.currency(order.total), bold: true, color: AppTheme.primary),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: bold ? 14 : 13)),
          Text(value, style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppTheme.textPrimary,
            fontSize: bold ? 16 : 14,
          )),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Order order) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add items from the same restaurant to reorder')),
              );
            },
            icon: const Icon(Icons.replay),
            label: const Text('Reorder'),
          ),
        ),
        if (order.status == 'delivered' && !order.isRated) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showRatingDialog,
              icon: const Icon(Icons.star_outline),
              label: const Text('Rate Order'),
            ),
          ),
        ],
      ],
    );
  }
}
