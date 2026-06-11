import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/restaurant.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/location_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadRestaurants(refresh: true);
      context.read<RestaurantProvider>().loadCategories();
      context.read<LocationProvider>().getCurrentLocation();
      context.read<LocationProvider>().loadSavedAddresses();
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => context.read<RestaurantProvider>().loadRestaurants(refresh: true),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildPromotionsCarousel()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nearby Restaurants',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/restaurants'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            _buildRestaurantsList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<LocationProvider>(
        builder: (context, location, _) {
          return GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location.address ?? 'Select location',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
              ],
            ),
          );
        },
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, notif, _) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                ),
                if (notif.unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        notif.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Consumer<CartProvider>(
          builder: (context, cart, _) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.of(context).pushNamed('/cart'),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        cart.itemCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => Navigator.of(context).pushNamed('/profile'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPromotionsCarousel() {
    final promotions = [
      _PromotionData('Free Delivery', 'On orders over ${Formatters.currency(200)}', AppTheme.primary, Icons.delivery_dining),
      _PromotionData('20% OFF', 'First order discount', AppTheme.secondary, Icons.local_offer),
      _PromotionData('Fast Delivery', '30 min or less', AppTheme.success, Icons.timer),
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: promotions.length,
        itemBuilder: (_, index) {
          final promo = promotions[index];
          return Container(
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [promo.color, promo.color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        promo.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(promo.icon, color: Colors.white.withOpacity(0.5), size: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final cat = categories[index];
              final isSelected = provider.selectedCategory == cat.name;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      provider.setCategory(null);
                    } else {
                      provider.setCategory(cat.name);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.divider,
                          ),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRestaurantsList() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SliverToBoxAdapter(
            child: LoadingShimmerList(),
          );
        }

        if (provider.error != null) {
          return SliverToBoxAdapter(
            child: ErrorState(
              message: provider.error,
              onRetry: () => provider.loadRestaurants(refresh: true),
            ),
          );
        }

        if (provider.restaurants.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.restaurant_outlined,
              title: 'No restaurants found',
              subtitle: 'Try a different category or search for something else',
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= provider.restaurants.length) return null;
              final restaurant = provider.restaurants[index];
              return RestaurantCard(
                restaurant: restaurant,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(restaurantId: restaurant.id),
                    ),
                  );
                },
              );
            },
            childCount: provider.restaurants.length,
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.of(context).pushNamed('/search');
            break;
          case 2:
            Navigator.of(context).pushNamed('/cart');
            break;
          case 3:
            Navigator.of(context).pushNamed('/order-history');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
      ],
    );
  }
}

class _PromotionData {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _PromotionData(this.title, this.subtitle, this.color, this.icon);
}

class Formatters {
  static String currency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
