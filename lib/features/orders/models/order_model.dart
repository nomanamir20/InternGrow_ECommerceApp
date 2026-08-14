import '../../cart/models/cart_item_model.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final String recipientName;
  final String shippingAddress;
  final String cardLast4;
  final DateTime orderDate;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.recipientName,
    required this.shippingAddress,
    required this.cardLast4,
    required this.orderDate,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'recipientName': recipientName,
      'shippingAddress': shippingAddress,
      'cardLast4': cardLast4,
      'orderDate': orderDate.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      recipientName: json['recipientName'] as String,
      shippingAddress: json['shippingAddress'] as String,
      cardLast4: json['cardLast4'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
    );
  }
}