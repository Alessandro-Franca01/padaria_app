import 'product.dart';
import 'subscription_template.dart';

enum DiscountTargetType { product, subscription }

DiscountTargetType _targetTypeFromJson(String? value) {
  return value == 'SUBSCRIPTION' ? DiscountTargetType.subscription : DiscountTargetType.product;
}

class Discount {
  final String id;
  final String? imagePath;
  final String description;
  final double percentage;
  final DiscountTargetType targetType;
  final Product? product;
  final SubscriptionTemplate? subscriptionTemplate;

  Discount({
    required this.id,
    this.imagePath,
    required this.description,
    required this.percentage,
    required this.targetType,
    this.product,
    this.subscriptionTemplate,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      imagePath: json['imagePath'],
      description: json['description'],
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      targetType: _targetTypeFromJson(json['targetType']),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      subscriptionTemplate: json['subscriptionTemplate'] != null
          ? SubscriptionTemplate.fromJson(json['subscriptionTemplate'])
          : null,
    );
  }
}
