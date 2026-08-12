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

/// Fetches products filtered by a specific category slug (e.g. "smartphones").
final productsByCategoryProvider =
    FutureProvider.autoDispose.family<List<Product>, String>((ref, category) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchProductsByCategory(category);
});