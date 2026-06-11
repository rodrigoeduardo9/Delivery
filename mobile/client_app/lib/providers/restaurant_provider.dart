import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _searchResults = [];
  List<RestaurantCategory> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  String? _selectedCategory;
  String _searchQuery = '';

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get searchResults => _searchResults;
  List<RestaurantCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _currentPage < _lastPage;
  String? get selectedCategory => _selectedCategory;

  Future<void> loadRestaurants({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _restaurants.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _restaurantService.getRestaurants(
      page: _currentPage,
      category: _selectedCategory,
    );

    if (result.success && result.data != null) {
      if (refresh) {
        _restaurants = result.data!.items;
      } else {
        _restaurants.addAll(result.data!.items);
      }
      _lastPage = result.data!.lastPage;
    } else {
      _error = result.message ?? 'Failed to load restaurants';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    final result = await _restaurantService.getRestaurants(
      page: _currentPage,
      category: _selectedCategory,
    );

    if (result.success && result.data != null) {
      _restaurants.addAll(result.data!.items);
      _lastPage = result.data!.lastPage;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    final result = await _restaurantService.getCategories();
    if (result.success && result.data != null) {
      _categories = result.data!;
      notifyListeners();
    }
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    loadRestaurants(refresh: true);
  }

  void searchRestaurants(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    // Debounce handled in UI
    _restaurantService.searchRestaurants(query).then((result) {
      if (result.success && result.data != null && _searchQuery == query) {
        _searchResults = result.data!;
        notifyListeners();
      }
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
