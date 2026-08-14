import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';

class OrdersNotifier extends StateNotifier<List<Order>> {
  static const _prefsKey = 'order_history';

  OrdersNotifier() : super([]) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      state = decoded.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((order) => order.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  void addOrder(Order order) {
    // Newest orders first.
    state = [order, ...state];
    _saveToPrefs();
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<Order>>((ref) {
  return OrdersNotifier();
});