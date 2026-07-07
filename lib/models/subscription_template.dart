class SubscriptionTemplateProduct {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;

  SubscriptionTemplateProduct({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
  });

  factory SubscriptionTemplateProduct.fromJson(Map<String, dynamic> json) {
    return SubscriptionTemplateProduct(
      productId: json['productId'],
      productName: json['productName'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class SubscriptionTemplate {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final bool active;
  final List<SubscriptionTemplateProduct> products;

  SubscriptionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.active,
    required this.products,
  });

  factory SubscriptionTemplate.fromJson(Map<String, dynamic> json) {
    return SubscriptionTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? '',
      active: json['active'] ?? true,
      products: (json['products'] as List)
          .map((p) => SubscriptionTemplateProduct.fromJson(p))
          .toList(),
    );
  }
}
