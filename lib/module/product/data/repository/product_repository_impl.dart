import 'package:flutter_catat_stok/core/services/local_storage_service.dart';
import 'package:flutter_catat_stok/core/services/supabase_service.dart';
import 'package:flutter_catat_stok/module/product/data/models/category_model.dart';
import 'package:flutter_catat_stok/module/product/data/models/product_model.dart';
import 'package:flutter_catat_stok/module/product/domain/models/category.dart';
import 'package:flutter_catat_stok/module/product/domain/models/product.dart';
import 'package:flutter_catat_stok/module/product/domain/repository/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepositoryImpl implements ProductRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<List<CategoryItem>> getCategories() async {
    try {
      final res = await _client
          .from('categories')
          .select('''
            id, 
            name, 
            products(
              id,
              name,
              sku,
              purchase_price,
              recommended_selling_price,
              minimum_stock,
              current_stock,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .order('created_at');

      return (res as List<dynamic>)
          .map<CategoryItem>(
            (item) => CategoryItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryItem?> addCategory({required String name}) async {
    final currentUser = await LocalStorageService().getUser();
    if (currentUser == null) {
      throw Exception('User tidak ditemukan');
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nama kategori tidak boleh kosong');
    }

    try {
      final newCategory = await _client
          .from('categories')
          .insert({'name': trimmed, 'user_id': currentUser.id})
          .select()
          .single();

      return CategoryItem(
        id: newCategory['id'],
        name: newCategory['name'],
        products: [],
      );
    } on PostgrestException catch (_) {
      return null;
    }
  }

  @override
  Future<bool> deleteCategory(String id) async {
    try {
      await _client.from('categories').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<CategoryItem?> updateCategoryName({
    required String id,
    required String name,
    required List<Product> products,
  }) async {
    try {
      final updatedCategory = await _client
          .from('categories')
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();

      return CategoryItem(
        id: updatedCategory['id'],
        name: updatedCategory['name'],
        products: products,
      );
    } on PostgrestException catch (_) {
      return null;
    }
  }

  @override
  Future<Product?> addProduct({required Product product}) async {
    try {
      final currentUser = await LocalStorageService().getUser();
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      final response = await _client
          .from('products')
          .insert({...product.toJson(), 'user_id': currentUser.id})
          .select('''
              id,
              name,
              sku,
              purchase_price,
              recommended_selling_price,
              minimum_stock,
              current_stock,
              is_active,
              created_at,
              updated_at,
              unit,
              description,
              categories (
                id, 
                name
              )
      ''')
          .single();
      return ProductModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteProduct(String id) async {
    try {
      // Soft delete: nonaktifkan produk alih-alih hapus permanen
      // untuk menghindari konflik dengan trigger DB pada product_logs.
      await _client.from('products').update({'is_active': false}).eq('id', id);
      return true;
    } on PostgrestException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('''
              id,
              name,
              sku,
              purchase_price,
              recommended_selling_price,
              minimum_stock,
              current_stock,
              is_active,
              created_at,
              updated_at,
              unit,
              description,
              categories (
                id, 
                name
              )
      ''')
          .eq('is_active', true)
          .order('current_stock', ascending: true);
      return (response as List)
          .map<Product>((x) => ProductModel.fromJson(x))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Product?> updateProduct({required Product product}) async {
    try {
      final response = await _client
          .from('products')
          .update({...product.toJson()})
          .eq('id', product.id)
          .select('''
              id,
              name,
              sku,
              purchase_price,
              recommended_selling_price,
              minimum_stock,
              current_stock,
              is_active,
              created_at,
              updated_at,
              unit,
              description,
              categories (
                id, 
                name
              )
      ''')
          .single();
      return ProductModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
