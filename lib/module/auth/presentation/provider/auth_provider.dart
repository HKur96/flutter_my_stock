import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/exceptions.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/core/services/local_storage_service.dart';
import 'package:flutter_catat_stok/core/utils/smooth_page_route.dart';
import 'package:flutter_catat_stok/module/auth/domain/models/user.dart';
import 'package:flutter_catat_stok/module/auth/domain/repository/auth_repository.dart';
import 'package:flutter_catat_stok/module/auth/presentation/screens/login_screen.dart';
import 'package:flutter_catat_stok/screens/main_navigation_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;

  Future<void> getCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await LocalStorageService().getUser();

      if (response == null) {
        throw DataException("Gagal mengambil data user");
      }

      _user = response;

      if (gNavigatorKey.currentContext != null) {
        Navigator.of(gNavigatorKey.currentContext!).pushReplacement(
          SmoothPageRoute(page: const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (gNavigatorKey.currentContext != null) {
        Navigator.of(gNavigatorKey.currentContext!).pushReplacement(
          SmoothPageRoute(page: const LoginScreen()),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response == null) {
        throw DataException("Gagal masuk. Silakan periksa email dan kata sandi Anda.");
      }

      _user = response;
      await LocalStorageService().saveUser(response);

      if (gNavigatorKey.currentContext != null) {
        Navigator.of(gNavigatorKey.currentContext!).pushReplacement(
          SmoothPageRoute(page: const MainNavigationScreen()),
        );
      }
    } on DataException catch (e) {
      showFlashError(e.message);
    } catch (e) {
      showFlashError("Terjadi kesalahan saat masuk");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await LocalStorageService().removeUser();
    if (gNavigatorKey.currentContext != null) {
      Navigator.of(gNavigatorKey.currentContext!).pushAndRemoveUntil(
        SmoothPageRoute(page: const LoginScreen()),
        (route) => false,
      );
    }
    notifyListeners();
  }
}

