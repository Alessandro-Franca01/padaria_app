import 'cart_item.dart';
import 'product.dart';

class SubscriptionPlan {
  final String id;
  final String userId;
  final String templateId;
  final String templateName;
  List<CartItem> items;
  List<String> days;
  String time;
  String deliveryAddress;
  bool active;
  final double totalPrice;
  final DateTime? createdAt;

  SubscriptionPlan({
    required this.id,
    required this.userId,
    required this.templateId,
    required this.templateName,
    required this.items,
    required this.days,
    required this.time,
    required this.deliveryAddress,
    this.active = true,
    this.totalPrice = 0,
    this.createdAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List).map((itemJson) {
      final thinProduct = Product(
        id: itemJson['productId'],
        name: itemJson['productName'],
        description: '',
        price: (itemJson['unitPrice'] as num).toDouble(),
        imageUrl: 'assets/images/paes_artesanais.jpeg',
        category: '',
      );
      return CartItem(product: thinProduct, quantity: itemJson['quantity']);
    }).toList();

    return SubscriptionPlan(
      id: json['id'],
      userId: json['userId'],
      templateId: json['templateId'],
      templateName: json['templateName'] ?? '',
      items: items,
      days: List<String>.from(json['days'] ?? []),
      time: json['time'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      active: json['active'] ?? true,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'templateId': templateId,
      'items': items.map((i) => i.toJson()).toList(),
      'days': days,
      'time': time,
      'deliveryAddress': deliveryAddress,
      'active': active,
    };
  }
}
