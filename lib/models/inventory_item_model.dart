class InventoryItemModel {
  String code;
  String name;
  double price;
  int amount;
  String user;
  String inventory;
  DateTime createdAt;
  DateTime updatedAt;

  InventoryItemModel({
    required this.code,
    required this.name,
    required this.price,
    required this.amount,
    required this.user,
    required this.inventory,
    required this.createdAt,
    required this.updatedAt,
  });

  InventoryItemModel.fromMap(Map<dynamic, dynamic> item)
      : code = item['code'],
        name = item['name'],
        price = item['price'],
        amount = item['amount'],
        user = item['user'],
        inventory = item['inventory'],
        createdAt = DateTime.parse(item['created_at']),
        updatedAt = DateTime.parse(item['updated_at']);

  Map<String, Object> toMap() {
    return {
      'code': code,
      'name': name,
      'price': price,
      'amount': amount,
      'user': user,
      'inventory': inventory,
      'created_at': createdAt.toLocal().toString(),
      'updated_at': updatedAt.toLocal().toString(),
    };
  }
}
