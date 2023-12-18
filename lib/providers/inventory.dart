import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:inventory/models/inventory_imodel.dart';
import 'package:inventory/repositories/inventory.dart';
import 'package:inventory/services/database.dart';

class InventoryProvider extends ChangeNotifier {
  List<InventoryModel> _inventories = [];
  int _currentInventoryId = 0;
  InventoryModel? _currentInventory;

  List<InventoryModel> get inventories => _inventories;
  int get currentInventoryId => _currentInventoryId;
  bool get hasOpenInventory => _inventories.isNotEmpty
      ? _inventories.where((element) => element.finished == null).isNotEmpty
      : false;

  InventoryModel? get currentInventory => _currentInventory;

  void setCurrentInventory(int id) {
    _currentInventory = _inventories.where((element) => element.id == id).first;
  }

  Future<void> getInventories() async {
    var inventory = await DatabaseService.getAll('inventories');

    if (inventory.isNotEmpty) {
      _inventories =
          inventory.map((item) => InventoryModel.fromMap(item)).toList();
    }

    notifyListeners();
  }

  Future<void> addInventory(String userName) async {
    await InventoryRepository.addInventory(userName);
    await getInventories();
  }

  Future<void> finish() async {
    _currentInventoryId = await InventoryRepository.update({
      'finished': DateTime.now().toString(),
    }, {
      'id': _inventories
          .firstWhere((element) => element.finished == null)
          .id
          .toString(),
    });
    await getInventories();
  }

  Future<void> addItem() async {}
}
