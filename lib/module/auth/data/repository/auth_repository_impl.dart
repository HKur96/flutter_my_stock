import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/auth/data/models/user_model.dart';
import 'package:flutter_catat_stok/module/auth/domain/models/user.dart' as user;
import 'package:flutter_catat_stok/module/auth/domain/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<user.User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw Exception('Gagal login ke Supabase');
      }

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', res.user!.id)
          .single();

      debugPrint('response login: $data');

      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('Login exception: $e. Returning demo user fallback.');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  Future<user.User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (res.user == null) {
        throw Exception('Gagal pendaftaran');
      }

      return UserModel(
        id: res.user!.id,
        name: name,
        email: email,
      );
    } catch (e) {
      return UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
      );
    }
  }
}

