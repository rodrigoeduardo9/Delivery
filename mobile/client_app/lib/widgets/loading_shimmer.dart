import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerWidget({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.divider,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.divider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class LoadingShimmerList extends StatelessWidget {
  final int itemCount;

  const LoadingShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerWidget(width: 80, height: 80, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerWidget(height: 16, borderRadius: 4),
                    const SizedBox(height: 8),
                    const ShimmerWidget(width: 150, height: 12, borderRadius: 4),
                    const SizedBox(height: 8),
                    const ShimmerWidget(width: 100, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
