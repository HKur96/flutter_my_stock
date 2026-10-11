import '../models/store_settings.dart';

abstract class StoreSettingsRepository {
  Future<StoreSettings?> getStoreSettings();
  Future<bool> saveStoreSettings(StoreSettings settings);
}
