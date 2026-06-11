import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/order_provider.dart';
import '../providers/location_provider.dart';
import '../models/order.dart';
import '../widgets/empty_state_driver.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<PointLatLng> _polylinePoints = [];
  List<StepInstruction> _steps = [];
  bool _isLoadingRoute = true;
  bool _showDirections = false;
  String _currentInstruction = '';
  int _currentStepIndex = 0;
  double _speed = 0;
  int _etaMinutes = 0;
  bool _showBottomSheet = true;
  bool _arrived = false;

  final Set<Marker> _destinationMarkers = {};
  PolylinePoints _polylinePointsService = PolylinePoints();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNavigation();
    });
  }

  Future<void> _initNavigation() async {
    final orderProv = context.read<OrderProvider>();
    final locProv = context.read<LocationProvider>();
    final order = orderProv.activeOrder;
    if (order == null) return;

    await locProv.getCurrentLocation();
    final currentPos = locProv.currentPosition;
    if (currentPos == null) return;

    _setupMarkers(order, currentPos.latitude, currentPos.longitude);
    await _loadRoute(
      currentPos.latitude,
      currentPos.longitude,
      order.restaurantAddress.latitude,
      order.restaurantAddress.longitude,
      order.customerAddress.latitude,
      order.customerAddress.longitude,
    );
  }

  void _setupMarkers(Order order, double currentLat, double currentLng) {
    final currentLocation = LatLng(currentLat, currentLng);
    final restaurantLocation = LatLng(
      order.restaurantAddress.latitude,
      order.restaurantAddress.longitude,
    );
    final customerLocation = LatLng(
      order.customerAddress.latitude,
      order.customerAddress.longitude,
    );

    _markers = {
      Marker(
        markerId: const MarkerId('current'),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
      Marker(
        markerId: const MarkerId('restaurant'),
        position: restaurantLocation,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: order.restaurantName),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: order.customerName),
      ),
    };
  }

  Future<void> _loadRoute(double startLat, double startLng,
      double restaurantLat, double restaurantLng,
      double customerLat, double customerLng) async {
    setState(() => _isLoadingRoute = true);

    try {
      final waypoints = [
        PointLatLng(startLat, startLng),
        PointLatLng(restaurantLat, restaurantLng),
        PointLatLng(customerLat, customerLng),
      ];

      final result = await _polylinePointsService.getRouteBetweenCoordinates(
        'YOUR_API_KEY_HERE',
        waypoints[0],
        waypoints[1],
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        _polylinePoints = result.points;
        _steps = _generateSimulatedSteps();
        _etaMinutes = 15;

        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: result.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          color: AppTheme.primary,
          width: 5,
          jointType: JointType.round,
        );

        setState(() {
          _polylines = {polyline};
          _currentInstruction =
              'Head ${_steps.isNotEmpty ? _steps[0].instruction : 'towards restaurant'}';
          _etaMinutes = 15;
        });

        final bounds = _calculateBounds(result.points);
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      } else {
        _polylinePoints = _generateSimulatedPolyline(
            startLat, startLng, restaurantLat, restaurantLng, customerLat,
            customerLng);
        _steps = _generateSimulatedSteps();
        _etaMinutes = 15;

        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: _polylinePoints
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          color: AppTheme.primary,
          width: 5,
          jointType: JointType.round,
        );

        setState(() {
          _polylines = {polyline};
          _currentInstruction = 'Navigate to restaurant';
        });
      }
    } catch (e) {
      _polylinePoints = _generateSimulatedPolyline(
          startLat, startLng, restaurantLat, restaurantLng, customerLat,
          customerLng);
      _steps = _generateSimulatedSteps();
      _etaMinutes = 15;

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: _polylinePoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(),
        color: AppTheme.primary,
        width: 5,
        jointType: JointType.round,
      );

      setState(() {
        _polylines = {polyline};
        _currentInstruction = 'Navigate to restaurant';
      });
    }

    setState(() => _isLoadingRoute = false);
  }

  List<PointLatLng> _generateSimulatedPolyline(
      double startLat, double startLng,
      double restLat, double restLng,
      double custLat, double custLng) {
    final points = <PointLatLng>[];
    points.add(PointLatLng(startLat, startLng));
    points.add(PointLatLng(
        (startLat + restLat) / 2, (startLng + restLng) / 2));
    points.add(PointLatLng(restLat, restLng));
    points.add(PointLatLng(
        (restLat + custLat) / 2, (restLng + custLng) / 2));
    points.add(PointLatLng(custLat, custLng));
    return points;
  }

  List<StepInstruction> _generateSimulatedSteps() {
    return [
      StepInstruction(
          distance: '500m',
          duration: '2 min',
          instruction: 'Head north on Main Street'),
      StepInstruction(
          distance: '1.2 km',
          duration: '4 min',
          instruction: 'Turn right on Av. Reforma'),
      StepInstruction(
          distance: '800m',
          duration: '3 min',
          instruction: 'Continue straight on Av. Reforma'),
      StepInstruction(
          distance: '300m',
          duration: '1 min',
          instruction: 'Turn left on Calle 5 de Mayo'),
      StepInstruction(
          distance: '150m',
          duration: '1 min',
          instruction: 'Your destination is on the right'),
    ];
  }

  LatLngBounds _calculateBounds(List<PointLatLng> points) {
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    for (final point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Navigation'),
        actions: [
          IconButton(
            icon: Icon(
                _showDirections ? Icons.directions_off : Icons.directions),
            onPressed: () {
              setState(() => _showDirections = !_showDirections);
            },
          ),
        ],
      ),
      body: Consumer2<OrderProvider, LocationProvider>(
        builder: (_, orderProv, locProv, __) {
          final order = orderProv.activeOrder;
          if (order == null) {
            return const EmptyStateDriver(
              icon: Icons.navigation_off,
              title: 'No active order',
              subtitle: 'No active delivery to navigate',
            );
          }

          if (_isLoadingRoute) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading route...', style: AppTheme.bodyText),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          locProv.latitude ??
                              AppConstants.mapDefaultLatitude,
                          locProv.longitude ??
                              AppConstants.mapDefaultLongitude,
                        ),
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _buildInstructionBanner(),
                    ),
                    Positioned(
                      top: 80,
                      right: 16,
                      child: _buildSpeedIndicator(),
                    ),
                    if (_arrived)
                      Positioned(
                        bottom: 120,
                        left: 16,
                        right: 16,
                        child: _buildArrivedBanner(order),
                      ),
                  ],
                ),
              ),
              if (_showBottomSheet) _buildBottomSheet(order, orderProv),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.turn_slight_right, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentInstruction,
              style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${_speed.toStringAsFixed(0)}',
            style: AppTheme.heading2.copyWith(color: AppTheme.primary),
          ),
          Text('km/h', style: AppTheme.caption),
        ],
      ),
    );
  }

  Widget _buildArrivedBanner(Order order) {
    final isRestaurant = order.status == 'accepted';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          const Text(
            'You have arrived!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isRestaurant
                ? 'Tap to confirm you are at the restaurant'
                : 'Tap to confirm delivery',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isRestaurant) {
                  Navigator.pushReplacementNamed(context, '/active-order');
                } else {
                  context.read<OrderProvider>().markDelivered(order.id);
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.success,
              ),
              child: Text(isRestaurant ? 'Confirm Arrival' : 'Complete Delivery'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(Order order, OrderProvider orderProv) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.restaurantName,
                            style: AppTheme.bodyText.copyWith(
                                fontWeight: FontWeight.w600)),
                        Text(
                          '${order.distanceKm.toStringAsFixed(1)} km',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'ETA: ${_etaMinutes} min',
                    style: AppTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_pin, color: AppTheme.secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.customerName,
                            style: AppTheme.bodyText.copyWith(
                                fontWeight: FontWeight.w600)),
                        Text(
                          order.customerAddress.fullAddress,
                          style: AppTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDirectionsPanel(),
                      icon: const Icon(Icons.list, size: 18),
                      label: const Text('Steps'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _arrived = true);
                      },
                      icon: const Icon(Icons.flag, size: 18),
                      label: const Text("I've Arrived"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDirectionsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) {
          return Padding(
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
                Text('Directions', style: AppTheme.heading3),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: _steps.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final step = _steps[index];
                      final isActive = _currentStepIndex == index;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? AppTheme.primary
                              : AppTheme.surface,
                          radius: 16,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          step.instruction,
                          style: TextStyle(
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text('${step.distance} - ${step.duration}'),
                        trailing: isActive
                            ? const Icon(Icons.arrow_forward_ios,
                                size: 16, color: AppTheme.primary)
                            : null,
                      );
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
}

class StepInstruction {
  final String distance;
  final String duration;
  final String instruction;

  StepInstruction({
    required this.distance,
    required this.duration,
    required this.instruction,
  });
}
