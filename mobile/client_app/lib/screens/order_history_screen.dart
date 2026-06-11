import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    Tab(text: 'All'),
    Tab(text: 'Active'),
    Tab(text: 'Completed'),
    Tab(text: 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadOrders();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  void _loadOrders() {
    String? status;
    switch (_tabController.index) {
      case 1:
        status = 'active';
        break;
      case 2:
        status = 'delivered';
        break;
      case 3:
        status = 'cancelled';
        break;
    }
    context.read<OrderProvider>().loadOrderHistory(status: status);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabs.length, (_) => _buildOrdersList()),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.orderHistory.isEmpty) {
          return const LoadingShimmerList();
        }

        if (provider.error != null && provider.orderHistory.isEmpty) {
          return ErrorState(
            message: provider.error,
            onRetry: _loadOrders,
          );
        }

        if (provider.orderHistory.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            subtitle: 'Place your first order to see it here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.orderHistory.length,
            itemBuilder: (_, index) {
              final order = provider.orderHistory[index];
              return OrderCard(
                order: order,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: order.id),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
