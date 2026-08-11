import 'package:dio/dio.dart';

import '../../features/product/models/product_model.dart';

/// Wraps all DummyJSON REST API calls in one place.
class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Product>> fetchProducts({int limit = 30, int skip = 0}) async {
    final response = await _dio.get(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    final List<dynamic> productsJson = response.data['products'];
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> fetchProductById(int id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data);
  }

  Future<List<String>> fetchCategories() async {
    final response = await _dio.get('/products/categories');
    // DummyJSON returns a list of {slug, name, url} objects.
    final List<dynamic> data = response.data;
    return data.map((e) => e['slug'] as String).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await _dio.get('/products/category/$category');
    final List<dynamic> productsJson = response.data['products'];
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await _dio.get(
      '/products/search',
      queryParameters: {'q': query},
    );
    final List<dynamic> productsJson = response.data['products'];
    return productsJson.map((json) => Product.fromJson(json)).toList();
  }
}