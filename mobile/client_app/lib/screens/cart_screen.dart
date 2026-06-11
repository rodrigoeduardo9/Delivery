import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/coupon.dart';
import '../services/api_service.dart';
import '../services/order_service.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/empty_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponController = TextEditingController();
  bool _isApplyingCoupon = false;
  String? _couponError;
  String? _couponSuccess;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
      _couponSuccess = null;
    });

    try {
      final api = ApiService();
      final data = await api.post('/coupons/validate', body: {
        'code': code,
        'subtotal': context.read<CartProvider>().subtotal,
      });

      if (data is Map<String, dynamic> && data['success'] == true) {
        final coupon = Coupon.fromJson(data['data'] as Map<String, dynamic>);
        if (coupon.isValid) {
          context.read<CartProvider>().applyCoupon(coupon);
          setState(() => _couponSuccess = 'Coupon applied! You saved ${Formatters.currency(context.read<CartProvider>().discount)}');
        } else {
          setState(() => _couponError = 'Invalid or expired coupon');
        }
      } else {
        setState(() => _couponError = 'Invalid coupon code');
      }
    } catch (e) {
      setState(() => _couponError = 'Failed to validate coupon');
    } finally {
      setState(() => _isApplyingCoupon = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Browse restaurants and add items to get started',
              actionLabel: 'Browse Restaurants',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (_, index) => CartItemCard(
                    cartItem: cart.items[index],
                    index: index,
                    onRemove: () => cart.removeItem(index),
                    onQuantityChanged: (q) => cart.updateQuantity(index, q),
                  ),
                ),
              ),
              _buildCouponSection(),
              _buildOrderSummary(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.appliedCoupon != null) {
            return Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Coupon "${cart.appliedCoupon!.code}" applied',
                    style: const TextStyle(color: AppTheme.success, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    cart.removeCoupon();
                    _couponController.clear();
                    setState(() {
                      _couponError = null;
                      _couponSuccess = null;
                    });
                  },
                  child: const Text('Remove', style: TextStyle(fontSize: 12)),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    errorText: _couponError,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isApplyingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _isApplyingCoupon
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Apply'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                _summaryRow('Subtotal', Formatters.currency(cart.subtotal)),
                const SizedBox(height: 6),
                _summaryRow(
                  'Delivery',
                  cart.deliveryFee == 0 ? 'Free' : Formatters.currency(cart.deliveryFee),
                  valueColor: cart.deliveryFee == 0 ? AppTheme.success : null,
                ),
                if (cart.discount > 0) ...[
                  const SizedBox(height: 6),
                  _summaryRow('Discount', '-${Formatters.currency(cart.discount)}',
                      valueColor: AppTheme.success),
                ],
                const Divider(height: 20),
                _summaryRow(
                  'Total',
                  Formatters.currency(cart.total),
                  isTotal: true,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/checkout'),
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
