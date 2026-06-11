import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/driver_service.dart';
import 'services/order_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/earnings_service.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/location_provider.dart';
import 'providers/earnings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/available_orders_screen.dart';
import 'screens/active_order_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/earnings_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/token_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  final tokenManager = TokenManager();
  final apiService = ApiService(tokenManager: tokenManager);
  final authService = AuthService(tokenManager: tokenManager, apiService: apiService);
  final driverService = DriverService(apiService);
  final orderService = OrderService(apiService);
  final locationService = LocationService();
  final notificationService = NotificationService();
  final earningsService = EarningsService(apiService);

  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            driverService: driverService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderService: orderService),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(
            locationService: locationService,
            driverService: driverService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EarningsProvider(earningsService: earningsService),
        ),
      ],
      child: const DriverApp(),
    ),
  );
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (_, authProv, __) {
          switch (authProv.status) {
            case AuthStatus.uninitialized:
              return const _SplashScreen();
            case AuthStatus.authenticated:
              return const MainShell();
            case AuthStatus.unauthenticated:
            case AuthStatus.loading:
              return const LoginScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => const MainShell(),
        '/login': (context) => const LoginScreen(),
        '/available-orders': (context) => const AvailableOrdersScreen(),
        '/active-order': (context) => const ActiveOrderScreen(),
        '/navigation': (context) => const NavigationScreen(),
        '/earnings': (context) => const EarningsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    EarningsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delivery_dining,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Delivery Driver',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
