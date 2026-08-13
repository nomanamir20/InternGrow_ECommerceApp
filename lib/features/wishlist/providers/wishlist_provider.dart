import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../product/models/product_model.dart';

class WishlistNotifier extends StateNotifier<List<Product>> {
  static const _prefsKey = 'wishlist_items';

  WishlistNotifier() : super([]) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      state = decoded.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((product) => product.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  bool isWishlisted(int productId) {
    return state.any((product) => product.id == productId);
  }

  void toggle(Product product) {
    if (isWishlisted(product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
    _saveToPrefs();
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<Product>>((ref) {
  return WishlistNotifier();
});