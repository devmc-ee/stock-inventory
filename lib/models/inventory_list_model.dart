class InventoryListModel {
  String user;
  DateTime started;
  String uuid;
  DateTime? finished;
  int? itemsAmount;
  int? id;
  int? synced;

  InventoryListModel(Map item,
      {required this.user,
      required this.started,
      required this.uuid,
      this.finished,
      this.itemsAmount,
      this.id,
      this.synced});

  InventoryListModel.fromMap(Map<dynamic, dynamic> item)
      : user = item['user'],
        started = DateTime.parse(item['started']) ,
        finished = item['finished'] != null? DateTime.parse(item['finished']): null ,
        synced = item['synced'],
        uuid = item['uuid'],
        itemsAmount = item['items_amount'],
        id = item['id'];

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'started': started.toLocal().toString(),
      'finished': finished?.toLocal().toString(),
      'synced': synced,
      'id': id,
      'uuid': uuid,
      'items_amount': itemsAmount,
    };
  }
}
