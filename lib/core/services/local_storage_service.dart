import 'dart:convert';
import 'package:flutter_catat_stok/module/auth/data/models/user_model.dart';
import 'package:flutter_catat_stok/module/auth/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService _instance = LocalStorageService._();

  factory LocalStorageService() => _instance;

  Future<SharedPreferences> get _preferences async =>
      SharedPreferences.getInstance();

  /// Menyimpan data user ke local storage
  Future<void> saveUser(User user) async {
    final prefs = await _preferences;

    final userModel = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
    );

    await prefs.setString('user', jsonEncode(userModel.toJson()));
  }

  /// Mengambil data user dari local storage
  Future<User?> getUser() async {
    final prefs = await _preferences;
    final userJson = prefs.getString('user');

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> map = jsonDecode(userJson);
      return UserModel.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Menghapus data user
  Future<void> removeUser() async {
    final prefs = await _preferences;
    await prefs.remove('user');
  }
}
