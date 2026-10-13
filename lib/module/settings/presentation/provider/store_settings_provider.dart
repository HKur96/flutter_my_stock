import 'package:flutter/material.dart';
import '../../domain/models/store_settings.dart';
import '../../domain/repository/store_settings_repository.dart';

class StoreSettingsProvider extends ChangeNotifier {
  final StoreSettingsRepository _repository;

  StoreSettingsProvider(this._repository);

  StoreSettings? _settings;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  StoreSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStoreSettings({bool isRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!isRefresh && _settings != null) {
        notifyListeners();
        return;
      }

      _settings = await _repository.getStoreSettings();
    } catch (e) {
      _errorMessage = 'Gagal memuat pengaturan toko';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStoreSettings({
    required String storeName,
    String? address,
    String? phoneNumber,
    String? headerFooterNote,
  }) async {
    _isSaving = true;
    notifyListeners();

    final currentId = _settings?.id ?? '';
    final newSettings = StoreSettings(
      id: currentId,
      storeName: storeName,
      address: address,
      phoneNumber: phoneNumber,
      headerFooterNote: headerFooterNote,
    );

    final success = await _repository.saveStoreSettings(newSettings);
    if (success) {
      _settings = newSettings;
    }
    _isSaving = false;
    notifyListeners();
    return success;
  }
}
