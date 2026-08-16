import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/card_formatters.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/models/order_model.dart';
import '../../orders/providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shipping fields
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Payment fields (simulated — never actually processed or transmitted)
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);

    // Simulated processing delay — no real payment gateway is contacted.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final cartItems = ref.read(cartProvider);
    final cartTotal = ref.read(cartTotalProvider);
    final rawCardNumber = _cardNumberController.text.replaceAll(' ', '');

    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items: List.of(cartItems),
      total: cartTotal,
      recipientName: _nameController.text.trim(),
      shippingAddress:
          '${_addressController.text.trim()}, ${_cityController.text.trim()} ${_postalCodeController.text.trim()}',
      cardLast4: rawCardNumber.length >= 4
          ? rawCardNumber.substring(rawCardNumber.length - 4)
          : '0000',
      orderDate: DateTime.now(),
    );

    ref.read(ordersProvider.notifier).addOrder(order);
    ref.read(cartProvider.notifier).clearCart();

    setState(() => _isPlacingOrder = false);

    context.go('${AppRoutes.orderConfirmation}/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = ref.watch(cartTotalProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionHeader(icon: Icons.local_shipping_outlined, title: 'Shipping Address'),
            const SizedBox(height: 16),

            AppTextField(
              controller: _nameController,
              label: 'Full Name',
              hintText: 'Enter recipient name',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _addressController,
              label: 'Address',
              hintText: 'Street address',
              prefixIcon: const Icon(Icons.home_outlined),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _cityController,
                    label: 'City',
                    hintText: 'City',
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    hintText: '00000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _SectionHeader(icon: Icons.credit_card_outlined, title: 'Payment Details'),
            const SizedBox(height: 4),
            Text(
              'This is a UI demonstration only — no real payment is processed.',
              style: TextStyle(color: subTextColor, fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),

            // Simulated card preview — updates live as the user types
            _CardPreview(
              cardNumber: _cardNumberController,
              cardName: _cardNameController,
              expiry: _expiryController,
            ),
            const SizedBox(height: 20),

            AppTextField(
              controller: _cardNumberController,
              label: 'Card Number',
              hintText: '1234 5678 9012 3456',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.credit_card),
              inputFormatters: [CardNumberInputFormatter()],
              validator: (value) {
                final digits = (value ?? '').replaceAll(' ', '');
                if (digits.length != 16) return 'Enter a valid 16-digit card number';
                return null;
              },
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _cardNameController,
              label: 'Cardholder Name',
              hintText: 'Name on card',
              prefixIcon: const Icon(Icons.badge_outlined),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _expiryController,
                    label: 'Expiry',
                    hintText: 'MM/YY',
                    keyboardType: TextInputType.number,
                    inputFormatters: [ExpiryDateInputFormatter()],
                    validator: (value) {
                      if (value == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                        return 'MM/YY';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _cvvController,
                    label: 'CVV',
                    hintText: '123',
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.length < 3) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _SectionHeader(icon: Icons.receipt_long_outlined, title: 'Order Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'Items ($cartItemCount)', value: '\$${cartTotal.toStringAsFixed(2)}'),
                  const _SummaryRow(label: 'Shipping', value: 'Free'),
                  Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, height: 24),
                  _SummaryRow(
                    label: 'Total',
                    value: '\$${cartTotal.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Place Order — \$${cartTotal.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? null : subTextColor)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// A live-updating visual card preview, purely cosmetic — reinforces that
/// this checkout mimics a real payment gateway's UI (like Stripe's card
/// element) without actually processing any payment.
class _CardPreview extends StatelessWidget {
  final TextEditingController cardNumber;
  final TextEditingController cardName;
  final TextEditingController expiry;

  const _CardPreview({
    required this.cardNumber,
    required this.cardName,
    required this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([cardNumber, cardName, expiry]),
      builder: (context, _) {
        final number = cardNumber.text.isEmpty ? '•••• •••• •••• ••••' : cardNumber.text;
        final name = cardName.text.isEmpty ? 'YOUR NAME' : cardName.text.toUpperCase();
        final exp = expiry.text.isEmpty ? 'MM/YY' : expiry.text;

        return Container(
          width: double.infinity,
          height: 190,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.contactless, color: Colors.white70, size: 28),
              const Spacer(),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    exp,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}