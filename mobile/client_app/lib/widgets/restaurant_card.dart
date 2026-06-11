import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/restaurant.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../utils/formatters.dart';
import 'loading_shimmer.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  _buildInfo(),
                  if (restaurant.tags != null && restaurant.tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildTags(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.cardRadius)),
      child: Stack(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: restaurant.bannerUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => const ShimmerWidget(height: 160),
              errorWidget: (_, __, ___) => Container(
                color: AppTheme.divider,
                child: const Icon(Icons.restaurant, size: 48, color: AppTheme.textHint),
              ),
            ),
          ),
          if (!restaurant.isOpen)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Text(
                    'Closed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  restaurant.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: restaurant.isFavorite ? AppTheme.error : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (restaurant.logoUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: restaurant.logoUrl!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ShimmerWidget(width: 40, height: 40),
              errorWidget: (_, __, ___) => Container(
                color: AppTheme.divider,
                child: const Icon(Icons.store, size: 20),
              ),
            ),
          ),
        if (restaurant.logoUrl != null) const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  RatingBarIndicator(
                    rating: restaurant.rating,
                    itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.ratingStar),
                    itemSize: 14,
                    itemCount: 5,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    ' (${restaurant.reviewCount})',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onTap,
          color: AppTheme.textHint,
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Row(
      children: [
        _buildInfoChip(Icons.timer_outlined, Formatters.deliveryTime(restaurant.deliveryTimeMin, restaurant.deliveryTimeMax)),
        const SizedBox(width: 16),
        _buildInfoChip(Icons.motorcycle_outlined, Formatters.currency(restaurant.deliveryFee)),
        if (restaurant.distance != null) ...[
          const SizedBox(width: 16),
          _buildInfoChip(Icons.location_on_outlined, Formatters.distance(restaurant.distance)),
        ],
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: restaurant.tags!.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(tag, style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
      )).toList(),
    );
  }
}
