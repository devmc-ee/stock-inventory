import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory/models/inventory_list_model.dart';
import 'package:inventory/pages/inventory_list.dart';
import 'package:inventory/providers/inventory.dart';
import 'package:inventory/providers/login_info.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: const InventoryList(),
      floatingActionButton: const ActionButton(),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Inventories',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}

class ActionButton extends StatefulWidget {
  const ActionButton({super.key});

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  void initState() {
    super.initState();

    context.read<InventoryProvider>().getInventories();
  }

  addNewInventory(userName) async {
    await context.read<InventoryProvider>().addInventoryList(userName);
  }

  finishStartedInventory(context) async {
    await context.read<InventoryProvider>().finish();
  }

  @override
  Widget build(BuildContext context) {
    String userName = context.watch<LoginInfo>().userName;
    bool hasOpenInventory = context.watch<InventoryProvider>().hasOpenInventory;
    return FloatingActionButton(
        onPressed: !hasOpenInventory
            ? () => addNewInventory(userName)
            : () => showAlertDialog(context),
        tooltip: !hasOpenInventory ? 'New' : 'Close',
        child:
            !hasOpenInventory ? const Icon(Icons.add) : const Icon(Icons.done));
  }
}

class InventoryList extends StatefulWidget {
  const InventoryList({super.key});

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    List<InventoryListModel> inventories =
        context.watch<InventoryProvider>().inventories;
    int openedInventoryItemsAmount =
        context.watch<InventoryProvider>().inventoryItemsAmount;

    return Center(
        child: inventories.isEmpty
            ? const Text('No inventories, start new one')
            : ListView.builder(
                physics: const ScrollPhysics(parent: null),
                itemCount: inventories.length,
                itemBuilder: (context, index) {
                  final InventoryListModel currentInventory = inventories[index];
                  bool isFinished = inventories[index].finished != null;
                  String title = isFinished
                      ? '${currentInventory.id}: [Finished] ${formatter.format(currentInventory.finished!)}'
                      : '${currentInventory.id}: Started: ${formatter.format(currentInventory.started)}';
                  return Card(child: ListTile(
                    onTap: () async {
                      context
                          .read<InventoryProvider>()
                          .setCurrentInventory(currentInventory.id!);
                      if (context.mounted) {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InventoryListPage()));
                      }
                    },
                    leading: const Icon(Icons.table_view),
                    title: Text(title),
                    subtitle: Text('Items: ${isFinished? currentInventory.itemsAmount : openedInventoryItemsAmount} pcs'),
                    trailing: isFinished
                        ? const Icon(Icons.done, color: Colors.green)
                        : const Icon(Icons.edit),
                  ),)
                   ;
                }));
  }
}

showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: Text("Finish"),
    onPressed: () async {
      await context.read<InventoryProvider>().finish();
      if (context.mounted) {
        Navigator.pop(context);
      }
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Confirm inventory finish"),
    content: const Text("Are you sure that the inventory is done?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
