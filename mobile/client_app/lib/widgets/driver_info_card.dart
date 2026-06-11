import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import 'loading_shimmer.dart';

class DriverInfoCard extends StatelessWidget {
  final String? driverName;
  final String? driverPhotoUrl;
  final String? driverPhone;
  final String? driverVehicle;
  final double? driverRating;

  const DriverInfoCard({
    super.key,
    this.driverName,
    this.driverPhotoUrl,
    this.driverPhone,
    this.driverVehicle,
    this.driverRating,
  });

  @override
  Widget build(BuildContext context) {
    if (driverName == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                width: 56,
                height: 56,
                child: CachedNetworkImage(
                  imageUrl: driverPhotoUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerWidget(width: 56, height: 56, borderRadius: 28),
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.divider,
                    child: const Icon(Icons.person, color: AppTheme.textHint, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverName!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (driverVehicle != null)
                    Text(
                      driverVehicle!,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  if (driverRating != null)
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: driverRating!,
                          itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.ratingStar, size: 14),
                          itemSize: 14,
                          itemCount: 5,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driverRating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (driverPhone != null)
              IconButton(
                icon: const Icon(Icons.phone, color: AppTheme.primary),
                onPressed: () {
                  launchUrl(Uri.parse('tel:${driverPhone!}'));
                },
              ),
          ],
        ),
      ),
    );
  }
}
