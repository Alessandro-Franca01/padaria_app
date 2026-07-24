class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final bool isFeatured;
  final double? discountedPrice;
  final double? discountPercentage;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.isFeatured = false,
    this.discountedPrice,
    this.discountPercentage,
  });

  double get effectivePrice => discountedPrice ?? price;
  bool get hasDiscount => discountedPrice != null;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      isAvailable: json['isAvailable'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'discountedPrice': discountedPrice,
      'discountPercentage': discountPercentage,
    };
  }
}
