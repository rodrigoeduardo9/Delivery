import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/coupon.dart';
import '../config/constants.dart';

class CartItem {
  final Product product;
  final ProductVariant? selectedVariant;
  final List<Extra> selectedExtras;
  int quantity;
  final String? notes;

  CartItem({
    required this.product,
    this.selectedVariant,
    this.selectedExtras = const [],
    this.quantity = 1,
    this.notes,
  });

  double get unitPrice {
    double price = product.price;
    if (selectedVariant != null) {
      price += selectedVariant!.priceAdjustment;
    }
    for (final extra in selectedExtras) {
      price += extra.price;
    }
    return price;
  }

  double get total => unitPrice * quantity;

  String get identifier {
    final variantId = selectedVariant?.id.toString() ?? '';
    final extrasIds = selectedExtras.map((e) => e.id.toString()).toList()..sort();
    return '${product.id}_$variantId_${extrasIds.join(',')}';
  }

  Map<String, dynamic> toJson() => {
        'product_id': product.id,
        'quantity': quantity,
        'variant_id': selectedVariant?.id,
        'extra_ids': selectedExtras.map((e) => e.id).toList(),
        'notes': notes,
      };
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  Coupon? _appliedCoupon;
  String? _restaurantName;
  int? _restaurantId;

  List<CartItem> get items => List.unmodifiable(_items);
  Coupon? get appliedCoupon => _appliedCoupon;
  String? get restaurantName => _restaurantName;
  int? get restaurantId => _restaurantId;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  double get deliveryFee {
    if (subtotal >= AppConstants.freeDeliveryThreshold) return 0;
    return AppConstants.deliveryFee;
  }

  double get discount {
    if (_appliedCoupon == null) return 0;
    return _appliedCoupon!.calculateDiscount(subtotal);
  }

  double get total => subtotal + deliveryFee - discount;

  bool get isEmpty => _items.isEmpty;

  void initRestaurant(int restaurantId, String restaurantName) {
    _restaurantId = restaurantId;
    _restaurantName = restaurantName;
  }

  void addItem(CartItem item) {
    if (_items.isNotEmpty && _items.first.product.restaurantId != item.product.restaurantId) {
      clearCart();
    }
    final index = _items.indexWhere((i) => i.identifier == item.identifier);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    _restaurantId = item.product.restaurantId;
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void applyCoupon(Coupon coupon) {
    _appliedCoupon = coupon;
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    _restaurantName = null;
    _restaurantId = null;
    notifyListeners();
  }
}
