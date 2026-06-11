import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/order_provider.dart';
import 'providers/location_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/chatbot_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/restaurants_list_screen.dart';
import 'screens/restaurant_detail_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_confirmed_screen.dart';
import 'screens/order_tracking_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/addresses_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/search_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured
  }

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: MaterialApp(
        title: 'FoodDelivery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/restaurants': (context) => const RestaurantsListScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/order-history': (context) => const OrderHistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/addresses': (context) => const AddressesScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/chatbot': (context) => const ChatbotScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
}
