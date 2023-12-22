import 'package:flutter/material.dart';
import 'package:inventory/models/inventory_list_model.dart';
import 'package:inventory/repositories/inventory_list.dart';
import 'package:inventory/services/database.dart';

class InventoryProvider extends ChangeNotifier {
  List<InventoryListModel> _inventories = [];
  int _currentInventoryId = 0;
  InventoryListModel? _currentInventory;

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController(text: '1');
 
  bool _canSubmit = false;

  List<InventoryListModel> get inventories => _inventories;
  int get currentInventoryId => _currentInventoryId;
  bool get hasOpenInventory => _inventories.isNotEmpty
      ? _inventories.where((element) => element.finished == null).isNotEmpty
      : false;
  

  InventoryListModel? get currentInventory => _currentInventory;

  TextEditingController get codeController => _codeController;
  TextEditingController get nameController => _nameController;
  TextEditingController get priceController => _priceController;
  TextEditingController get amountController => _amountController;
  int get amount => int.parse(_amountController.text);

  bool get canSubmit => _canSubmit;

  void validateForm() {
     _canSubmit = _codeController.text.isNotEmpty && _nameController.text.isNotEmpty && _priceController.text.isNotEmpty && _amountController.text.isNotEmpty; 
    notifyListeners();
  }

  void setCurrentInventory(int id) {
    _currentInventory = _inventories.where((element) => element.id == id).first;
  }

  Future<void> getInventories() async {
    var inventory = await DatabaseService.getAll('inventories');

    if (inventory.isNotEmpty) {
      _inventories =
          inventory.map((item) => InventoryListModel.fromMap(item)).toList();
    }

    notifyListeners();
  }

  Future<void> addInventoryList(String userName) async {
    await InventoryListRepository.add(userName);
    await getInventories();
  }

  Future<void> finish() async {
    _currentInventoryId = await InventoryListRepository.update({
      'finished': DateTime.now().toString(),
    }, {
      'id': _inventories
          .firstWhere((element) => element.finished == null)
          .id
          .toString(),
    });
    await getInventories();
  }

  Future<void> addInventoryItem() async {
    if (_currentInventory != null) {
      print('Add item');
      // double price = double.parse(priceController.text);
      print(codeController.text);
      print(nameController.text);
      print(priceController.text);
      print(amountController.text);
      // await InventoryItemRepository.add(code: codeController.text, name: nameController.text, price: price, inventoryUuid: _currentInventory!.uuid, user: _currentInventory!.user);
    }
  }

  TextEditingController? getController(String name) {
    switch(name.toLowerCase()) {
      case 'code':
        return codeController;
      case 'name':
        return nameController;
      case 'price':
        return priceController;
      case 'amount':
        return amountController;
    }

    return null;
  }

  void changeAmount(bool isIncrease) {
    if (amountController.text == '' ) {
      amountController.text = '0';

      return;
    }
    if (isIncrease) {
      amountController.text = (int.parse(amountController.text) + 1).toString();
    } else {
      final decreasedValue = (int.parse(amountController.text) - 1);
      amountController.text = decreasedValue < 0 ? '0' : decreasedValue.toString();
    }
  }
}
