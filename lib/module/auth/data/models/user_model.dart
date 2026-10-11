import 'package:flutter_catat_stok/core/config/enum.dart';
import 'package:flutter_catat_stok/module/auth/domain/models/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: Role.fromValue(json['role'] ?? Role.operator),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'role': role.name};
  }
}
