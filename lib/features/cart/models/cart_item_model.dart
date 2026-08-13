import '../../product/models/product_model.dart';

/// A product plus a quantity — one line item in the cart.
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get lineTotal => product.discountedPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
}