import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
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
    _isLoading = true;
    notifyListeners();
    try {
      if (await _repository.addUnit(name, description: description)) {
        _units = [
          UnitItem(name: name, description: description, id: ''),
          ..._units,
        ];

        ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Unit berhasil ditambahkan!'),
            backgroundColor: AppColors.stockIn,
          ),
        );
        return true;
      }

      showFlashError('Gagal menambahkan satuan');
      return false;
    } catch (e) {
      showFlashError('Gagal menambahkan satuan');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUnit(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (await _repository.deleteUnit(id)) {
        _units = _units.where((x) => x.id != id).toList();
        ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Unit berhasil dihapus!'),
            backgroundColor: AppColors.stockIn,
          ),
        );
        return true;
      }

      showFlashError('Gagal menghapus satuan');
      return false;
    } catch (e) {
      showFlashError('Gagal menambahkan satuan');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
