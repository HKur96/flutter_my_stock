import 'package:flutter/material.dart';
import '../../domain/models/unit_item.dart';
import '../../domain/repository/unit_repository.dart';

class UnitProvider extends ChangeNotifier {
  final UnitRepository _repository;

  UnitProvider(this._repository);

  List<UnitItem> _units = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UnitItem> get units => _units;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getUnits({bool isRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!isRefresh && _units.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _units = await _repository.getUnits();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar satuan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addUnit({required String name, String? description}) async {
    final success = await _repository.addUnit(name, description: description);
    if (success) {
      await getUnits();
    }
    return success;
  }

  Future<bool> deleteUnit(String id) async {
    final success = await _repository.deleteUnit(id);
    if (success) {
      await getUnits();
    }
    return success;
  }
}
