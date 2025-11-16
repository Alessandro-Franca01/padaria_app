class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final bool isFeatured;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.isFeatured = false,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    final idVal = json['id']?.toString();
    final priceVal = (json['price'] ?? json['price_value'] ?? json['total_price']) is String
        ? double.tryParse((json['price'] ?? json['price_value'] ?? json['total_price'])) ?? 0.0
        : ((json['price'] ?? json['price_value'] ?? json['total_price'])?.toDouble() ?? 0.0);
    final imageVal = json['imageUrl'] ?? json['image_url'] ?? '';
    final categoryVal = json['category'] is Map
        ? json['category']['name']
        : (json['category'] ?? json['category_name'] ?? 'Geral');
    final isAvailableVal = json['isAvailable'] ?? json['is_available'] ?? true;
    final isFeaturedVal = json['isFeatured'] ?? json['is_featured'] ?? false;
    return Product(
      id: idVal ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: priceVal,
      imageUrl: imageVal,
      category: categoryVal,
      isAvailable: isAvailableVal,
      isFeatured: isFeaturedVal,
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
    };
  }
}
