import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String role; // admin | supervisor | operator

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJsonString(String source) =>
      User.fromJson(jsonDecode(source) as Map<String, dynamic>);

  bool get isAdmin => role == 'admin';
  bool get isSupervisor => role == 'supervisor';
  bool get isOperator => role == 'operator';
}
