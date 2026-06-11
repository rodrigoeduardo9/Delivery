import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../config/theme.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../utils/formatters.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTimeRange? _dateRange;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Delivery History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading && prov.orderHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => prov.fetchOrderHistory(),
            child: Column(
              children: [
                if (_showFilters) _buildFilterBar(prov),
                if (prov.orderHistory.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history,
                              size: 64, color: AppTheme.textHint),
                          const SizedBox(height: 16),
                          const Text(
                            'No delivery history yet',
                            style: AppTheme.bodyText,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your completed deliveries will appear here',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: prov.orderHistory.length,
                      itemBuilder: (_, index) {
                        final order = prov.orderHistory[index];
                        return _buildHistoryItem(order);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(OrderProvider prov) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickDateRange,
              icon: const Icon(Icons.date_range, size: 18),
              label: Text(
                _dateRange != null
                    ? '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
                    : 'Filter by date',
                style: AppTheme.bodySmall,
              ),
            ),
          ),
          if (_dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                setState(() => _dateRange = null);
                prov.fetchOrderHistory();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      context.read<OrderProvider>().fetchOrderHistory(
            startDate: picked.start,
            endDate: picked.end,
          );
    }
  }

  Widget _buildHistoryItem(Order order) {
    final date = DateTime.parse(order.createdAt);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOrderDetail(order),
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
                    child: const Icon(Icons.restaurant,
                        color: AppTheme.primary, size: 24),
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
                        Text(
                          order.customerAddress.fullAddress,
                          style: AppTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppFormatters.currency(order.total),
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, HH:mm').format(date),
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Order #${order.orderNumber}',
                    style: AppTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (order.driverRating != null)
                    RatingBarIndicator(
                      rating: order.driverRating!,
                      itemBuilder: (_, __) => const Icon(
                        Icons.star,
                        color: AppTheme.accent,
                      ),
                      itemCount: 5,
                      itemSize: 16,
                      direction: Axis.horizontal,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetail(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) {
          final date = DateTime.parse(order.createdAt);
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Delivery Details', style: AppTheme.heading2),
                const SizedBox(height: 16),
                _detailCard('Order #${order.orderNumber}', [
                  _detailRow('Status', 'Delivered'),
                  _detailRow('Date', DateFormat('MMMM d, yyyy - HH:mm').format(date)),
                  _detailRow('Items', '${order.itemCount} items'),
                  _detailRow('Subtotal', AppFormatters.currency(order.subtotal)),
                  _detailRow('Delivery Fee', AppFormatters.currency(order.deliveryFee)),
                  if (order.tip > 0)
                    _detailRow('Tip', AppFormatters.currency(order.tip)),
                  _detailRow(
                    'Total',
                    AppFormatters.currency(order.total),
                    valueBold: true,
                  ),
                ]),
                const SizedBox(height: 12),
                _detailCard('Restaurant', [
                  _detailRow('Name', order.restaurantName),
                  _detailRow('Address', order.restaurantAddress.fullAddress),
                ]),
                const SizedBox(height: 12),
                _detailCard('Customer', [
                  _detailRow('Name', order.customerName),
                  _detailRow('Phone', order.customerPhone),
                  _detailRow('Address', order.customerAddress.fullAddress),
                ]),
                if (order.driverRating != null) ...[
                  const SizedBox(height: 12),
                  _detailCard('Rating', [
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: order.driverRating!,
                          itemBuilder: (_, __) => const Icon(
                            Icons.star,
                            color: AppTheme.accent,
                          ),
                          itemCount: 5,
                          itemSize: 28,
                          direction: Axis.horizontal,
                        ),
                        const Spacer(),
                        Text(
                          order.driverRating!.toStringAsFixed(1),
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ],
                const SizedBox(height: 16),
                if (order.items.isNotEmpty) ...[
                  Text('Items', style: AppTheme.heading3),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text('${item.quantity}x ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Expanded(child: Text(item.name)),
                            Text(AppFormatters.currency(item.price)),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailCard(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.heading3),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool valueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyText.copyWith(
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
