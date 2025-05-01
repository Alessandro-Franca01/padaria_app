import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  String? notes;
  
  CartItem({
    required this.product,
    this.quantity = 1,
    this.notes,
  });
  
  double get totalPrice => product.price * quantity;
  
  factory CartItem.fromJson(Map<String, dynamic> json, Product product) {
    return CartItem(
      product: product,
      quantity: json['quantity'] ?? 1,
      notes: json['notes'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'notes': notes,
    };
  }
}
