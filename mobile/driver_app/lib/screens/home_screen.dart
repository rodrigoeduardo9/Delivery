import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/location_provider.dart';
import '../providers/earnings_provider.dart';
import '../models/order.dart';
import '../widgets/driver_status_toggle.dart';
import '../widgets/active_order_card.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<Marker> _demandMarkers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startPolling();
      context.read<EarningsProvider>().loadSummary();
      _initDemandMarkers();
    });
  }

  void _initDemandMarkers() {
    final simulatedDemand = [
      {'lat': 19.4326, 'lng': -99.1332, 'label': 'High Demand'},
      {'lat': 19.4200, 'lng': -99.1500, 'label': 'Medium Demand'},
      {'lat': 19.4400, 'lng': -99.1200, 'label': 'High Demand'},
      {'lat': 19.4250, 'lng': -99.1400, 'label': 'Low Demand'},
      {'lat': 19.4450, 'lng': -99.1250, 'label': 'Medium Demand'},
    ];

    for (int i = 0; i < simulatedDemand.length; i++) {
      final point = simulatedDemand[i];
      final isHigh = point['label'] == 'High Demand';
      _demandMarkers.add(
        Marker(
          markerId: MarkerId('demand_$i'),
          position: LatLng(point['lat'] as double, point['lng'] as double),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isHigh ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(title: point['label'] as String?),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Driver Home'),
        actions: [
          Consumer<OrderProvider>(
            builder: (_, orderProv, __) {
              if (orderProv.hasNewOrders) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        orderProv.clearHasNewOrders();
                        Navigator.pushNamed(context, '/available-orders');
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/available-orders');
                },
              );
            },
          ),
        ],
      ),
      body: Consumer3<AuthProvider, OrderProvider, LocationProvider>(
        builder: (_, authProv, orderProv, locProv, __) {
          final hasActiveOrder = orderProv.hasActiveOrder;
          return RefreshIndicator(
            onRefresh: () async {
              await orderProv.fetchActiveOrder();
              await context.read<EarningsProvider>().loadSummary();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DriverStatusToggle(
                    isAvailable: authProv.isAvailable,
                    onToggle: (value) => authProv.updateAvailability(value),
                  ),
                  const SizedBox(height: 8),
                  _buildStatsRow(),
                  const SizedBox(height: 8),
                  _buildMapSection(),
                  if (hasActiveOrder) ...[
                    const SizedBox(height: 8),
                    _buildActiveOrderSection(orderProv.activeOrder!),
                  ],
                  if (!hasActiveOrder && authProv.isAvailable) ...[
                    const SizedBox(height: 8),
                    _buildAvailableOrdersButton(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow() {
    return Consumer2<EarningsProvider, AuthProvider>(
      builder: (_, earnProv, authProv, __) {
        final profile = authProv.driverProfile;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.receipt_long,
                  label: "Today's\nDeliveries",
                  value: '${earnProv.summary?.todayDeliveries ?? 0}',
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money,
                  label: "Today's\nEarnings",
                  value: AppFormatters.currency(earnProv.todayTotal),
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.star,
                  label: 'Rating',
                  value: profile?.rating.toStringAsFixed(1) ?? '0.0',
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapSection() {
    return Consumer<LocationProvider>(
      builder: (_, locProv, __) {
        final initialPos = locProv.currentPosition;
        return Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  initialPos?.latitude ?? AppConstants.mapDefaultLatitude,
                  initialPos?.longitude ?? AppConstants.mapDefaultLongitude,
                ),
                zoom: AppConstants.mapDefaultZoom,
              ),
              markers: _demandMarkers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              onTap: (_) {
                Navigator.pushNamed(context, '/navigation');
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveOrderSection(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Active Order',
            style: AppTheme.heading3,
          ),
        ),
        ActiveOrderCard(
          order: order,
          onTap: () => Navigator.pushNamed(context, '/active-order'),
        ),
      ],
    );
  }

  Widget _buildAvailableOrdersButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/available-orders'),
          icon: const Icon(Icons.list_alt),
          label: const Text('Available Orders'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}
