import 'package:flutter_catat_stok/core/config/enum.dart';

class User {
  final String id;
  final String name;
  final String? email;
  final Role role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  User copyWith({String? id, String? name, String? email, Role? role}) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    role: role ?? this.role,
  );
}
