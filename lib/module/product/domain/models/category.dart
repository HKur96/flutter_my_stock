import 'package:flutter_catat_stok/module/product/domain/models/product.dart';

class CategoryItem {
  final String id;
  final String name;
  final List<Product> products;

  CategoryItem({required this.id, required this.name, required this.products});

  int get productCount => products.length;
}
