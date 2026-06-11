import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/restaurant.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../services/restaurant_service.dart';
import '../services/product_service.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _restaurantService = RestaurantService();
  final _productService = ProductService();

  Restaurant? _restaurant;
  List<Product> _products = [];
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final results = await Future.wait([
      _restaurantService.getRestaurantDetail(widget.restaurantId),
      _productService.getProducts(widget.restaurantId),
      _restaurantService.getRestaurantReviews(widget.restaurantId),
    ]);

    if (results[0].success && results[0].data != null) {
      _restaurant = results[0].data;
    } else {
      _error = results[0].message;
    }

    if (results[1].success && results[1].data != null) {
      _products = results[1].data!;
      _products.sort((a, b) {
        final aCat = a.category ?? '';
        final bCat = b.category ?? '';
        return aCat.compareTo(bCat);
      });
    }

    if (results[2].success && results[2].data != null) {
      _reviews = results[2].data!.items;
    }

    setState(() => _isLoading = false);
  }

  Map<String, List<Product>> get _categorizedProducts {
    final map = <String, List<Product>>{};
    for (final p in _products) {
      final cat = p.category ?? 'Other';
      map.putIfAbsent(cat, () => []).add(p);
    }
    return map;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingShimmerList()
          : _error != null
              ? ErrorState(message: _error, onRetry: _loadData)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 220,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: _restaurant!.bannerUrl ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.divider,
                    child: const Icon(Icons.restaurant, size: 64, color: AppTheme.textHint),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_restaurant!.logoUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: _restaurant!.logoUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (_restaurant!.logoUrl != null) const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _restaurant!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: _restaurant!.rating,
                                  itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.ratingStar, size: 14),
                                  itemSize: 14,
                                  itemCount: 5,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_restaurant!.rating.toStringAsFixed(1)} (${_restaurant!.reviewCount})',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!_restaurant!.isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Closed', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildInfoBar(),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              tabs: const [
                Tab(text: 'Menu'),
                Tab(text: 'Info'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMenuTab(),
          _buildInfoTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(Icons.timer_outlined, Formatters.deliveryTime(_restaurant!.deliveryTimeMin, _restaurant!.deliveryTimeMax)),
          _infoItem(Icons.motorcycle_outlined, Formatters.currency(_restaurant!.deliveryFee)),
          if (_restaurant!.distance != null)
            _infoItem(Icons.location_on_outlined, Formatters.distance(_restaurant!.distance)),
          if (_restaurant!.minOrder != null)
            _infoItem(Icons.shopping_bag_outlined, 'Min ${Formatters.currency(_restaurant!.minOrder!)}'),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildMenuTab() {
    if (_products.isEmpty) {
      return const EmptyState(
        icon: Icons.restaurant_menu,
        title: 'No menu items',
        subtitle: 'This restaurant has no items in the menu yet',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _categorizedProducts.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            ...entry.value.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProductCard(
                product: product,
                onTap: () => _openProductDetail(product),
                onAdd: () => _openProductDetail(product),
              ),
            )),
          ],
        );
      }).toList(),
    );
  }

  void _openProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_restaurant!.description != null) ...[
            const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_restaurant!.description!, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
          ],
          const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _restaurant!.address ?? 'Address not available',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          if (_restaurant!.openingHours != null) ...[
            const SizedBox(height: 24),
            const Text('Opening Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_restaurant!.openingHours!, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_reviews.isEmpty) {
      return const EmptyState(
        icon: Icons.rate_review_outlined,
        title: 'No reviews yet',
        subtitle: 'Be the first to review this restaurant',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (_, index) {
        final review = _reviews[index];
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.divider,
                    child: Text(
                      (review.userName ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review.userName ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  RatingBarIndicator(
                    rating: review.rating,
                    itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.ratingStar, size: 12),
                    itemSize: 12,
                    itemCount: 5,
                  ),
                ],
              ),
              if (review.comment != null && review.comment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(review.comment!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ],
              const SizedBox(height: 6),
              Text(
                Formatters.date(review.createdAt),
                style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
