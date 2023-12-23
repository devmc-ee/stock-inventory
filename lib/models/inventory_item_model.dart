class InventoryItemModel {
  String code;
  String name;
  String price;
  int amount;
  String user;
  String inventory;

  InventoryItemModel({
    required this.code,
    required this.name,
    required this.price,
    required this.amount,
    required this.user,
    required this.inventory,
  });

  InventoryItemModel.fromMap(Map<dynamic, dynamic> item)
      : code = item['code'],
        name = item['name'],
        price = item['price'],
        amount = item['amount'],
        user = item['user'],
        inventory = item['inventory'];

  Map<String, Object> toMap() {
    return {
      'code': code,
      'name': name,
      'price': price,
      'amount': amount,
      'user': user,
      'inventory': inventory
    };
  }
}
