import 'package:inventory/models/inventory_item_model.dart';
import 'package:inventory/services/database.dart';

class InventoryItemRepository {
  static const _tableName = 'inventory_items';
  static const model = InventoryItemModel;

  static Future<void> add({required String code, required String name, required double price, required String inventoryUuid, required String user, int amount = 1, }) async {
    await DatabaseService.insert(_tableName, InventoryItemModel(code: code, name: name, price: '$price €', amount: amount, user: user, inventory: inventoryUuid));
  }
}