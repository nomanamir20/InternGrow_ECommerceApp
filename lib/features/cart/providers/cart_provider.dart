import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../product/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  static const _prefsKey = 'cart_items';

  CartNotifier() : super([]) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      state = decoded.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      final newQuantity = (existing.quantity + quantity).clamp(1, product.stock);
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex) existing.copyWith(quantity: newQuantity) else state[i],
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: quantity.clamp(1, product.stock))];
    }

    _saveToPrefs();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity.clamp(1, item.product.stock))
        else
          item,
    ];
    _saveToPrefs();
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _saveToPrefs();
  }

  void clearCart() {
    state = [];
    _saveToPrefs();
  }

  bool isInCart(int productId) {
    return state.any((item) => item.product.id == productId);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// Derived total item count (sum of quantities) — used for the cart badge.
final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

/// Derived cart subtotal.
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.lineTotal);
});