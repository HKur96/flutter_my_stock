import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/global.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/repository/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository;

  ProductProvider(this._productRepository);

  List<CategoryItem> _categories = [];
  bool _isLoading = false;

  List<CategoryItem> get categories => _categories;
  bool get isLoading => _isLoading;

  List<String> get categoriesChipFilter => [
    'Semua',
    ...categories.map((x) => x.name),
  ];

  Future<void> getCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _productRepository.getCategories();
      _categories = response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory({required String name}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _productRepository.addCategory(name: name);
      if (response != null) {
        _categories = [response, ..._categories];
      }
      notifyListeners();

      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil ditambahkan!'),
          backgroundColor: AppColors.stockIn,
        ),
      );
    } catch (e) {
      showFlashError('Tidak dapat menambahkan kategori');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productRepository.deleteCategory(id);
      _categories = _categories.where((x) => x.id != id).toList();
      ScaffoldMessenger.of(
        gNavigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Kategori dihapus')));
    } catch (e) {
      ScaffoldMessenger.of(
        gNavigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus kategori')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategoryName({
    required CategoryItem category,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _productRepository.updateCategoryName(
        id: category.id,
        name: category.name,
        products: category.products,
      );
      if (response != null) {
        _categories = _categories
            .map((x) => x.id == category.id ? response : x)
            .toList();
      }
      notifyListeners();

      ScaffoldMessenger.of(gNavigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil diupdate!'),
          backgroundColor: AppColors.stockIn,
        ),
      );
    } catch (e) {
      showFlashError('Tidak dapat mengupdate kategori');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
