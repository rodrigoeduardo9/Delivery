import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/restaurant.dart';
import '../services/user_service.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import 'restaurant_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _userService = UserService();
  List<Restaurant>? _favorites;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _userService.getFavorites();
    if (result.success && result.data != null) {
      setState(() => _favorites = result.data);
    } else {
      setState(() => _error = result.message);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _isLoading
          ? const LoadingShimmerList()
          : _error != null
              ? ErrorState(message: _error, onRetry: _loadFavorites)
              : _favorites == null || _favorites!.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite_outline,
                      title: 'No favorites yet',
                      subtitle: 'Tap the heart icon on restaurants to save them here',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _favorites!.length,
                        itemBuilder: (_, index) {
                          final r = _favorites![index];
                          return RestaurantCard(
                            restaurant: r,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RestaurantDetailScreen(restaurantId: r.id),
                                ),
                              );
                            },
                            onFavoriteTap: () async {
                              await _userService.toggleFavorite(r.id);
                              _loadFavorites();
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
