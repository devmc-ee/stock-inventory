class InventoryModel {
  String user;
  String started;
  String? finished;
  int? id;

  InventoryModel(Map item,
      {required this.user, required this.started, this.finished, this.id});

  InventoryModel.fromMap(Map<dynamic, dynamic> item)
      : user = item['user'],
        started = item['started'],
        finished = item['finished'],
        id = item['id'];

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'started': started,
      'finished': finished,
      'id': id,
    };
  }
}
