class LoyaltyTransaction {
  final String id;
  final String type;
  final int points;
  final int balanceAfter;
  final String? orderId;
  final String? benefitName;
  final String? description;
  final DateTime createdAt;

  LoyaltyTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.balanceAfter,
    this.orderId,
    this.benefitName,
    this.description,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'],
      type: json['type'],
      points: json['points'],
      balanceAfter: json['balanceAfter'],
      orderId: json['orderId'],
      benefitName: json['benefitName'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'EARNED':
        return 'Pontos ganhos';
      case 'REDEEMED':
        return 'Resgate';
      case 'ADJUSTMENT':
        return 'Ajuste';
      case 'REVERSAL':
        return 'Estorno';
      default:
        return type;
    }
  }
}
