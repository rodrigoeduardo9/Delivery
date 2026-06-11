import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../config/theme.dart';
import '../utils/formatters.dart';
import 'quantity_selector.dart';
import 'loading_shimmer.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final int index;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.index,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(cartItem.identifier),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: CachedNetworkImage(
                  imageUrl: cartItem.product.imageUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerWidget(width: 64, height: 64),
                  errorWidget: (_, __, ___) => Container(
                    color: AppTheme.divider,
                    child: const Icon(Icons.fastfood, color: AppTheme.textHint),
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
                    cartItem.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cartItem.selectedVariant != null)
                    Text(
                      cartItem.selectedVariant!.name,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  if (cartItem.selectedExtras.isNotEmpty)
                    Text(
                      cartItem.selectedExtras.map((e) => e.name).join(', '),
                      style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.currency(cartItem.unitPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                QuantitySelector(
                  value: cartItem.quantity,
                  onChanged: (v) => onQuantityChanged?.call(v),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(cartItem.total),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
