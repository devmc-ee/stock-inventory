import 'package:inventory/models/inventory_imodel.dart';
import 'package:inventory/services/database.dart';
import 'package:uuid/uuid.dart';
class InventoryRepository {
  static const _tableName = 'inventories';
  static const model = InventoryModel;
  static const uuid = Uuid();

  static Future<void> addInventory(
    userName,
  ) async {
    await DatabaseService.insert(
        'inventories',
        InventoryModel(
          {},
          user: userName,
          uuid: uuid.v1(),
          started: DateTime.now().toString(),
        ).toMap());
  }

  static Future<int> update(
      Map<String, dynamic> values, Map<String, String> where) async {
    int updatedId = 0;

    try {
      updatedId = await DatabaseService.update(_tableName, values, where);
    } catch (error) {
      print(error);
    }

    return updatedId;
  }
}