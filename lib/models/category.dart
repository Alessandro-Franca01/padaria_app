class Category {
  final String id;
  final String name;
  final String? title;
  final String? imagePath;

  Category({
    required this.id,
    required this.name,
    this.title,
    this.imagePath,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      imagePath: json['imagePath'],
    );
  }
}
