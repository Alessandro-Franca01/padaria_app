class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final int loyaltyPoints;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.loyaltyPoints = 0,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'loyaltyPoints': loyaltyPoints,
    };
  }
}
