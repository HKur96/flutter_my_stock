import 'package:flutter_catat_stok/module/product/domain/models/unit_item.dart';

class UnitItemModel extends UnitItem {
  UnitItemModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory UnitItemModel.fromJson(Map<String, dynamic> json) =>
      UnitItemModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description'],
      );
}
