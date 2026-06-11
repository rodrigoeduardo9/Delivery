import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/user.dart';
import '../models/payment.dart';
import '../models/coupon.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/location_provider.dart';
import '../providers/order_provider.dart';
import '../utils/formatters.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  Address? _selectedAddress;
  PaymentMethod? _selectedPayment;
  double _tipPercentage = 0;
  double _customTip = 0;
  final _customTipController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadSavedAddresses();
    });
  }

  @override
  void dispose() {
    _customTipController.dispose();
    super.dispose();
  }

  double get _tipAmount {
    final cart = context.read<CartProvider>();
    if (_customTip > 0) return _customTip;
    return cart.subtotal * _tipPercentage / 100;
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final cart = context.read<CartProvider>();
    final orderData = {
      'restaurant_id': cart.restaurantId,
      'items': cart.items.map((item) => item.toJson()).toList(),
      'delivery_address_id': _selectedAddress!.id,
      'payment_method': _selectedPayment?.type ?? 'cash',
      'tip': _tipAmount,
      'notes': '',
      if (cart.appliedCoupon != null) 'coupon_code': cart.appliedCoupon!.code,
    };

    final orderProvider = context.read<OrderProvider>();
    final order = await orderProvider.createOrder(orderData);

    setState(() => _isPlacingOrder = false);

    if (order != null && mounted) {
      cart.clearCart();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmedScreen(
            orderId: order.id,
            orderNumber: order.orderNumber,
            estimatedTimeMin: order.estimatedTimeMin ?? 30,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: _buildStepContent(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Address', 'Payment', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppTheme.surface,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: index <= _currentStep ? () => setState(() => _currentStep = index) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary
                          : isCompleted
                              ? AppTheme.success
                              : AppTheme.divider,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddressStep() {
    return Consumer<LocationProvider>(
      builder: (context, location, _) {
        final addresses = location.savedAddresses;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Select Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            if (addresses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No saved addresses. Please add one.', textAlign: TextAlign.center),
              )
            else
              ...addresses.map((addr) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<Address>(
                  title: Text(addr.alias, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(addr.fullAddress, maxLines: 2, overflow: TextOverflow.ellipsis),
                  value: addr,
                  groupValue: _selectedAddress ?? location.selectedAddress,
                  onChanged: (v) => setState(() => _selectedAddress = v),
                  activeColor: AppTheme.primary,
                ),
              )),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/addresses'),
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentStep() {
    final payments = [
      PaymentMethod(type: 'cash', isDefault: true),
      PaymentMethod(type: 'card', lastFour: '4242', brand: 'Visa'),
      PaymentMethod(type: 'wallet', lastFour: null),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        ...payments.map((pm) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<PaymentMethod>(
            title: Text(pm.displayName),
            subtitle: pm.type == 'card' && pm.lastFour != null
                ? Text('${pm.brand ?? 'Card'} ending in ${pm.lastFour}')
                : null,
            value: pm,
            groupValue: _selectedPayment,
            onChanged: (v) => setState(() => _selectedPayment = v),
            activeColor: AppTheme.primary,
          ),
        )),
        const SizedBox(height: 24),
        const Text(
          'Add a Tip',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...AppConstants.tipPercentages.map((pct) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('$pct%'),
                  selected: _tipPercentage == pct && _customTip == 0,
                  onSelected: (_) => setState(() {
                    _tipPercentage = pct;
                    _customTip = 0;
                  }),
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: _tipPercentage == pct && _customTip == 0 ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: const Text('Custom'),
                  selected: _customTip > 0,
                  onSelected: (_) => _showCustomTipDialog(),
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: _customTip > 0 ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_tipPercentage > 0 || _customTip > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tip: ${Formatters.currency(_tipAmount)}',
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  void _showCustomTipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Tip'),
        content: TextField(
          controller: _customTipController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter amount',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(_customTipController.text);
              if (value != null && value > 0) {
                setState(() {
                  _customTip = value;
                  _tipPercentage = 0;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            if (cart.restaurantName != null)
              Text(
                cart.restaurantName!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 12),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(child: Text(item.product.name)),
                  Text(Formatters.currency(item.total)),
                ],
              ),
            )),
            const Divider(height: 24),
            _buildSummaryRow('Subtotal', Formatters.currency(cart.subtotal)),
            _buildSummaryRow('Delivery', cart.deliveryFee == 0 ? 'Free' : Formatters.currency(cart.deliveryFee)),
            if (cart.discount > 0) _buildSummaryRow('Discount', '-${Formatters.currency(cart.discount)}', AppTheme.success),
            if (_tipAmount > 0) _buildSummaryRow('Tip', Formatters.currency(_tipAmount)),
            const Divider(height: 12),
            _buildSummaryRow('Total', Formatters.currency(cart.total + _tipAmount), AppTheme.primary, true),
            const SizedBox(height: 16),
            if (_selectedAddress != null) ...[
              const Text('Deliver to:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(_selectedAddress!.fullAddress, style: const TextStyle(color: AppTheme.textSecondary)),
            ],
            const SizedBox(height: 8),
            Text(
              'Payment: ${_selectedPayment?.displayName ?? 'Not selected'}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, [Color? valueColor, bool isBold = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: isBold ? 16 : 14,
          )),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentStep < 2
                    ? () => setState(() => _currentStep++)
                    : (_isPlacingOrder ? null : _placeOrder),
                child: _isPlacingOrder
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_currentStep == 2 ? 'Place Order' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
