class Discount {
  final String id;
  final String? imagePath;
  final String description;

  Discount({
    required this.id,
    this.imagePath,
    required this.description,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      imagePath: json['imagePath'],
      description: json['description'],
    );
  }
}
