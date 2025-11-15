import 'cart_item.dart';

class SubscriptionPlan {
  final String id;
  final String userId;
  List<CartItem> items;
  List<String> days;
  String time;
  String deliveryAddress;
  bool active;

  SubscriptionPlan({
    required this.id,
    required this.userId,
    required this.items,
    required this.days,
    required this.time,
    required this.deliveryAddress,
    this.active = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((i) => i.toJson()).toList(),
      'days': days,
      'time': time,
      'deliveryAddress': deliveryAddress,
      'active': active,
    };
  }
}
