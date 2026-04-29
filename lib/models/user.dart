// lib/models/user.dart

class User {
  final int id;
  final String name;
  final String email;
  final String city;
  final String username;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      city: json['address']?['city'] ?? '',
    );
  }
}
