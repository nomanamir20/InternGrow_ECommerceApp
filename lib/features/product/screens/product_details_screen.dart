import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Product Details — TODO (id: $productId)')),
    );
  }
}