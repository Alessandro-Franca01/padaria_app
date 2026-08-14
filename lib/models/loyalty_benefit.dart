class LoyaltyBenefit {
  final String id;
  final String name;
  final String? description;
  final int requiredPoints;
  final String effectType;
  final double? effectValue;
  final String? productId;
  final String? productName;
  final int? freeProductQuantity;
  final bool active;
  final bool available;

  LoyaltyBenefit({
    required this.id,
    required this.name,
    this.description,
    required this.requiredPoints,
    required this.effectType,
    this.effectValue,
    this.productId,
    this.productName,
    this.freeProductQuantity,
    required this.active,
    required this.available,
  });

  factory LoyaltyBenefit.fromJson(Map<String, dynamic> json) {
    return LoyaltyBenefit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      requiredPoints: json['requiredPoints'],
      effectType: json['effectType'],
      effectValue: json['effectValue'] != null ? (json['effectValue'] as num).toDouble() : null,
      productId: json['productId'],
      productName: json['productName'],
      freeProductQuantity: json['freeProductQuantity'],
      active: json['active'] ?? true,
      available: json['available'] ?? false,
    );
  }

  String get effectSummary {
    switch (effectType) {
      case 'PERCENTAGE_DISCOUNT':
        return '${effectValue?.toStringAsFixed(0)}% de desconto';
      case 'FIXED_DISCOUNT':
        return 'R\$ ${effectValue?.toStringAsFixed(2)} de desconto';
      case 'FREE_PRODUCT':
        return '${freeProductQuantity ?? 1}x ${productName ?? "produto"} grátis';
      case 'FREE_DELIVERY':
        return 'Entrega grátis';
      default:
        return description ?? '';
    }
  }
}
