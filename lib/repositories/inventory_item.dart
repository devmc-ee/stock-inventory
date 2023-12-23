import 'package:inventory/models/inventory_item_model.dart';
import 'package:inventory/services/database.dart';

class InventoryItemRepository {
  static const _tableName = 'inventory_items';
  static const model = InventoryItemModel;

  static Future<int> add({required String code, required String name, required double price, required String inventoryUuid, required String user, int amount = 1, }) async {
      final data = InventoryItemModel(code: code, name: name, price: price, amount: amount, user: user, inventory: inventoryUuid, createdAt: DateTime.now(), updatedAt: DateTime.now()).toMap();
      return await DatabaseService.insert(_tableName, data);
  }

  static Future<List<InventoryItemModel>> getAll() async{
    final items = await DatabaseService.getAll(_tableName);

    if (items.isNotEmpty) {
      return items.map((item) => InventoryItemModel.fromMap(item)).toList();
    }  

    return [];  
  }

  static Future<int> delete({ required String code }) async {
    return await DatabaseService.delete(tableName: _tableName, idName: 'code', idValue: code);
  }
}