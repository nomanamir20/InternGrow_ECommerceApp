import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../models/product_model.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Fetches the main product listing for Home.
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchProducts(limit: 30);
});

/// Fetches a single product by ID for the Details screen.
final productDetailsProvider = FutureProvider.autoDispose.family<Product, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchProductById(id);
});

final categoriesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchCategories();
});

/// Fetches products filtered by a specific category slug.
final productsByCategoryProvider =
    FutureProvider.autoDispose.family<List<Product>, String>((ref, category) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchProductsByCategory(category);
});

/// Holds the current search query text, updated as the user types.
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Debounced search results — waits 400ms after the user stops typing
/// before actually calling the API, to avoid firing a request per keystroke.
final searchResultsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  if (query.trim().isEmpty) {
    return [];
  }

  // Debounce: cancel this computation if the query changes again within
  // 400ms (Riverpod cancels the previous future automatically when the
  // provider rebuilds due to a dependency change).
  await Future.delayed(const Duration(milliseconds: 400));

  final api = ref.watch(apiServiceProvider);
  return api.searchProducts(query.trim());
});