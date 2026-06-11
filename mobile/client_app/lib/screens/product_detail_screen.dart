import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/loading_shimmer.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductVariant? _selectedVariant;
  final Set<int> _selectedExtraIds = {};
  int _quantity = 1;
  final _notesController = TextEditingController();

  double get _unitPrice {
    double price = widget.product.price;
    if (_selectedVariant != null) {
      price += _selectedVariant!.priceAdjustment;
    }
    for (final extra in widget.product.extras) {
      if (_selectedExtraIds.contains(extra.id)) {
        price += extra.price;
      }
    }
    return price;
  }

  double get _total => _unitPrice * _quantity;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      final defaultVar = widget.product.variants.where((v) => v.isDefault).firstOrNull;
      _selectedVariant = defaultVar ?? widget.product.variants.first;
    }
    for (final extra in widget.product.extras) {
      if (extra.isDefault) {
        _selectedExtraIds.add(extra.id);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.product.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerWidget(height: 300),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.divider,
                  child: const Icon(Icons.fastfood, size: 64, color: AppTheme.textHint),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            Formatters.currency(_unitPrice),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                          if (widget.product.originalPrice != null)
                            Text(
                              Formatters.currency(widget.product.originalPrice!),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.product.description != null) ...[
                    Text(
                      widget.product.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.product.variants.isNotEmpty) ...[
                    const Text(
                      'Size / Variant',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    ...widget.product.variants.map((variant) => RadioListTile<ProductVariant>(
                      title: Text(variant.name),
                      subtitle: variant.priceAdjustment > 0
                          ? Text('+${Formatters.currency(variant.priceAdjustment)}')
                          : null,
                      value: variant,
                      groupValue: _selectedVariant,
                      onChanged: (v) => setState(() => _selectedVariant = v),
                      activeColor: AppTheme.primary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    )),
                    const SizedBox(height: 16),
                  ],
                  if (widget.product.extras.isNotEmpty) ...[
                    const Text(
                      'Extras',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    ...widget.product.extras.map((extra) => CheckboxListTile(
                      title: Text(extra.name),
                      subtitle: extra.price > 0
                          ? Text('+${Formatters.currency(extra.price)}')
                          : null,
                      value: _selectedExtraIds.contains(extra.id),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedExtraIds.add(extra.id);
                          } else {
                            _selectedExtraIds.remove(extra.id);
                          }
                        });
                      },
                      activeColor: AppTheme.primary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    )),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Special Instructions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Any special requests?',
                      filled: true,
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            QuantitySelector(
              value: _quantity,
              onChanged: (v) => setState(() => _quantity = v),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: Text(
                    'Add to Cart · ${Formatters.currency(_total)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    if (!widget.product.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item is not available')),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    final selectedExtras = widget.product.extras
        .where((e) => _selectedExtraIds.contains(e.id))
        .toList();

    final cartItem = CartItem(
      product: widget.product,
      selectedVariant: _selectedVariant,
      selectedExtras: selectedExtras,
      quantity: _quantity,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    cart.addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.of(context).pushNamed('/cart'),
        ),
      ),
    );

    Navigator.of(context).pop();
  }
}
