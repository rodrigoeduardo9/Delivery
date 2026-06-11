import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../utils/debouncer.dart';
import 'restaurant_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: AppConstants.searchDebounceMs));
  List<String> _recentSearches = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final searches = (prefs.getStringList('recent_searches') ?? []);
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) {
      searches.removeLast();
    }
    await prefs.setStringList('recent_searches', searches);
    setState(() => _recentSearches = searches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches = []);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search restaurants or dishes...',
            filled: false,
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<RestaurantProvider>().clearSearch();
                      setState(() => _showResults = false);
                    },
                  )
                : null,
          ),
          onChanged: (v) {
            setState(() => _showResults = v.isNotEmpty);
            _debouncer(() {
              context.read<RestaurantProvider>().searchRestaurants(v);
            });
          },
          onSubmitted: (v) {
            if (v.isNotEmpty) {
              _saveSearch(v);
              context.read<RestaurantProvider>().searchRestaurants(v);
            }
          },
        ),
      ),
      body: _showResults ? _buildResults() : _buildRecentSearches(),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'Search for restaurants',
        subtitle: 'Find your favorite food and restaurants',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text('Clear', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (_, index) {
              final query = _recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history, color: AppTheme.textHint),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 18, color: AppTheme.textHint),
                  onPressed: () {
                    _searchController.text = query;
                    context.read<RestaurantProvider>().searchRestaurants(query);
                    setState(() => _showResults = true);
                  },
                ),
                onTap: () {
                  _searchController.text = query;
                  context.read<RestaurantProvider>().searchRestaurants(query);
                  setState(() => _showResults = true);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, _) {
        if (provider.searchResults.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'No results found',
            subtitle: 'Try a different search term',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => provider.searchRestaurants(_searchController.text),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.searchResults.length,
            itemBuilder: (_, index) {
              final r = provider.searchResults[index];
              return RestaurantCard(
                restaurant: r,
                onTap: () {
                  _saveSearch(_searchController.text);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(restaurantId: r.id),
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
