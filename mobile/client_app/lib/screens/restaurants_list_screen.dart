import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/chip_filter.dart';
import '../utils/debouncer.dart';
import 'restaurant_detail_screen.dart';

class RestaurantsListScreen extends StatefulWidget {
  const RestaurantsListScreen({super.key});

  @override
  State<RestaurantsListScreen> createState() => _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends State<RestaurantsListScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: AppConstants.searchDebounceMs));
  final _scrollController = ScrollController();
  bool _isGridView = false;
  String? _sortBy;
  double? _minRating;

  final _sortOptions = ['Distance', 'Rating', 'Delivery Time'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadRestaurants(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<RestaurantProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildRestaurantsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search restaurants...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<RestaurantProvider>().clearSearch();
                  },
                )
              : null,
        ),
        onChanged: (v) {
          _debouncer(() {
            context.read<RestaurantProvider>().searchRestaurants(v);
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSortChip('Sort: $_sortBy', () => _showSortOptions()),
              const SizedBox(width: 8),
              if (_minRating != null)
                FilterChip(
                  label: Text('${_minRating!.toStringAsFixed(0)}+ stars'),
                  selected: true,
                  onSelected: (_) => setState(() => _minRating = null),
                  selectedColor: AppTheme.primary,
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  backgroundColor: AppTheme.background,
                  side: BorderSide.none,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, VoidCallback onTap) {
    return ActionChip(
      avatar: const Icon(Icons.sort, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: AppTheme.background,
      side: BorderSide.none,
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sort by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            ..._sortOptions.map((option) => ListTile(
              title: Text(option),
              trailing: _sortBy == option
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = option);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsList() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.restaurants.isEmpty) {
          return const LoadingShimmerList();
        }

        if (provider.error != null && provider.restaurants.isEmpty) {
          return ErrorState(
            message: provider.error,
            onRetry: () => provider.loadRestaurants(refresh: true),
          );
        }

        final restaurants = _searchController.text.isNotEmpty
            ? provider.searchResults
            : provider.restaurants;

        if (restaurants.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'No restaurants found',
            subtitle: 'Try adjusting your search or filters',
          );
        }

        if (_isGridView) {
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: restaurants.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (_, index) {
              if (index >= restaurants.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final r = restaurants[index];
              return RestaurantCard(
                restaurant: r,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(restaurantId: r.id),
                    ),
                  );
                },
              );
            },
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: restaurants.length + (provider.isLoadingMore ? 1 : 0),
          itemBuilder: (_, index) {
            if (index >= restaurants.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final r = restaurants[index];
            return RestaurantCard(
              restaurant: r,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailScreen(restaurantId: r.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
