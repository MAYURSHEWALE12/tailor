class User {
  final String id;
  final String name;
  final String phone;
  final String shopName;
  final String? email;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.shopName,
    this.email,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      shopName: json['shopName'] ?? '',
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'shopName': shopName,
      'email': email,
      'token': token,
    };
  }
}
