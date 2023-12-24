import 'package:inventory/models/inventory_list_model.dart';
import 'package:inventory/services/database.dart';
import 'package:uuid/uuid.dart';
class InventoryListRepository {
  static const _tableName = 'inventories';
  static const model = InventoryListModel;
  static const uuid = Uuid();

  static Future<void> add(
    userName,
  ) async {
    await DatabaseService.insert(
        _tableName,
        InventoryListModel(
          {},
          user: userName,
          uuid: uuid.v1(),
          started: DateTime.now(),
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
