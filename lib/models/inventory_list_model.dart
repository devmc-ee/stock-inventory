class InventoryListModel {
  String user;
  String started;
  String uuid;
  String? finished;
  int? id;
  int? synced;

  InventoryListModel(Map item,
      {required this.user,
      required this.started,
      required this.uuid,
      this.finished,
      this.id,
      this.synced});

  InventoryListModel.fromMap(Map<dynamic, dynamic> item)
      : user = item['user'],
        started = item['started'],
        finished = item['finished'],
        synced = item['synced'],
        uuid = item['uuid'],
        id = item['id'];

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'started': started,
      'finished': finished,
      'synced': synced,
      'id': id,
      'uuid': uuid,
    };
  }
}
