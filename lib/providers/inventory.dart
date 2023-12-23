import 'package:flutter/material.dart';
import 'package:inventory/models/inventory_item_model.dart';
import 'package:inventory/models/inventory_list_model.dart';
import 'package:inventory/repositories/inventory_item.dart';
import 'package:inventory/repositories/inventory_list.dart';
import 'package:inventory/services/database.dart';

class InventoryProvider extends ChangeNotifier {
  List<InventoryListModel> _inventories = [];
  int _currentInventoryId = 0;
  InventoryListModel? _currentInventory;
  List<InventoryItemModel> _inventoryItems = [];
  List<InventoryItemModel> _filteredInventoryItems = [];
  InventoryItemModel? _currentInventoryItem;
  final FocusNode _focusNode = FocusNode();

  bool _isOpenedSearchBar = false;
  bool _canSubmit = false;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController(text: '1');
  final _searchController = TextEditingController();
  List<InventoryListModel> get inventories => _inventories;
  List<InventoryItemModel> get inventoryItems => _filteredInventoryItems;

  FocusNode get focusNode => _focusNode;
  int get currentInventoryId => _currentInventoryId;
  bool get hasOpenInventory => _inventories.isNotEmpty
      ? _inventories.where((element) => element.finished == null).isNotEmpty
      : false;
  bool get hasCurrentInventoryItem => _currentInventoryItem != null;
  bool get isOpenedSearchBar => _isOpenedSearchBar;

  InventoryListModel? get currentInventory => _currentInventory;
  InventoryItemModel? get currentInventoryItem => _currentInventoryItem;
  TextEditingController get codeController => _codeController;
  TextEditingController get nameController => _nameController;
  TextEditingController get priceController => _priceController;
  TextEditingController get amountController => _amountController;
  TextEditingController get searchController => _searchController;

  String get searchedCode => _searchController.text;

  int get amount => int.parse(_amountController.text);

  bool get canSubmit => _canSubmit;

  
  void clearSearch() {
    _searchController.text = '';
    _isOpenedSearchBar = false;
    
    notifyListeners();
  }

  void deleteInventoryItem(String code) async {
    _inventoryItems.removeWhere((element) => element.code == code);
    notifyListeners();
    int amount = await InventoryItemRepository.delete(code: code);
    print('deleted $amount rows');
  }

  void toggleOpenSearchBar() {
    _isOpenedSearchBar = !_isOpenedSearchBar;
    notifyListeners();
  }

  void setCurrentInventoryItem(String code) {
    if (_inventoryItems.isNotEmpty) {
      _currentInventoryItem =
          _inventoryItems.firstWhere((element) => element.code == code);
      if (_currentInventoryItem != null) {
        _amountController.text = _currentInventoryItem?.amount != null
            ? _currentInventoryItem!.amount.toString()
            : '';
        _nameController.text = _currentInventoryItem?.name != null
            ? _currentInventoryItem!.name
            : '';
        _codeController.text = _currentInventoryItem?.code != null
            ? _currentInventoryItem!.code
            : '';
        _priceController.text = _currentInventoryItem?.price != null
            ? _currentInventoryItem!.price.toString()
            : '';
      }
      notifyListeners();
    }
  }

  void dropCurrentIventoryItem() {
    if (_inventoryItems.isNotEmpty) {
      _currentInventoryItem = null;
      _amountController.text = '1';
      _nameController.text = '';
      _codeController.text = '';
      _priceController.text = '';
      notifyListeners();
    }
  }

  Future<void> getInventorieItems() async {
    _inventoryItems = await InventoryItemRepository.getAll();
    _filteredInventoryItems = _inventoryItems;
    notifyListeners();
  }

  void initSearchController () {
    _searchController.addListener(() {
      String searchCode = _searchController.text;
     
     if (searchedCode.isNotEmpty) {
      _filteredInventoryItems = _inventoryItems.where((element) {
              return element.code.toLowerCase().contains(searchCode.toLowerCase());
            }).toList();
     } else {
      _filteredInventoryItems = _inventoryItems;
     }
       notifyListeners();
    });
  }
  void initControllers() {
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && codeController.text.isNotEmpty) {
        try {
          InventoryItemModel? existingItem = _inventoryItems.firstWhere((element) => element.code.toLowerCase() == codeController.text);

          if (existingItem != null) {
            setCurrentInventoryItem(existingItem.code);
          }
        } catch (error) {
          print('Not found ${error.toString()}');
        }
      }
    });
    amountController.addListener(() {
      validateForm();
    });

    codeController.addListener(() {
      validateForm();
    });

    priceController.addListener(() {
      validateForm();
    });


    nameController.addListener(() {
      validateForm();
    });
  
    if (_currentInventoryItem != null) {
      _amountController.text = _currentInventoryItem?.amount != null
          ? _currentInventoryItem!.amount.toString()
          : '';
      _nameController.text = _currentInventoryItem?.name != null
          ? _currentInventoryItem!.name
          : '';
      _codeController.text = _currentInventoryItem?.code != null
          ? _currentInventoryItem!.code
          : '';
      _priceController.text = _currentInventoryItem?.price != null
          ? _currentInventoryItem!.price.toString()
          : '';
    }
  }

  Future<void> validateForm() async {
    _canSubmit = _codeController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _amountController.text.isNotEmpty;
    await Future.delayed(Duration.zero);

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

  void dropFormData() {
    _codeController.text = '';
    _nameController.text = '';
    _priceController.text = '';
    _amountController.text = '1';
  }

  Future<SnakbarMessage> handleInventoryItem() async {
    if(!_canSubmit) {
      return SnakbarMessage(
        content: const Text('There are some invalid fields'),
        color: Colors.red,
      );
    }

    if (_currentInventoryItem == null) {
      // handle new item data
       try {
        double price = double.parse(priceController.text);

        await InventoryItemRepository.add(
            code: codeController.text,
            name: nameController.text,
            price: price,
            inventoryUuid: _currentInventory!.uuid,
            user: _currentInventory!.user,
            amount: int.parse(_amountController.text));
      } catch (error) {
        String errorMessage = error.toString();

        if (errorMessage.contains('UNIQUE')) {
          return SnakbarMessage(
            content: const Text('Failed! Code should be UNIQUE'),
            color: Colors.red,
          );
        }
        return SnakbarMessage(
          content: Text('Failed! $errorMessage'),
          color: Colors.red,
        );
      }
    }

    if (_currentInventoryItem?.createdAt != null) {
      // handle item update
      try {
        await InventoryItemRepository.update(
            code: codeController.text,
            amount: int.parse(_amountController.text));
      } catch (error) {
        String errorMessage = error.toString();
        return SnakbarMessage(
          content: Text('Failed! $errorMessage'),
          color: Colors.red,
        );
      }
    } 
    
    await getInventorieItems();

    dropFormData();
    return SnakbarMessage(
      content: const Text('Success! Scan next one!'),
      color: Colors.green,
    );
  }

  TextEditingController? getController(String name) {
    switch (name.toLowerCase()) {
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
    if (amountController.text == '') {
      amountController.text = '0';

      return;
    }
    if (isIncrease) {
      amountController.text = (int.parse(amountController.text) + 1).toString();
    } else {
      final decreasedValue = (int.parse(amountController.text) - 1);
      amountController.text =
          decreasedValue < 0 ? '0' : decreasedValue.toString();
    }
  }
}

class SnakbarMessage {
  Widget content;
  Color color;

  SnakbarMessage({required this.color, required this.content});
}
