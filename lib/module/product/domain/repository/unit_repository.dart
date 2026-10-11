import '../models/unit_item.dart';

abstract class UnitRepository {
  Future<List<UnitItem>> getUnits();
  Future<bool> addUnit(String name, {String? description});
  Future<bool> deleteUnit(String id);
}
