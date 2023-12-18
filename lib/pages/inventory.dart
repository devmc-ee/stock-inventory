import 'package:flutter/material.dart';
import 'package:inventory/models/inventory_imodel.dart';
import 'package:inventory/pages/home.dart';
import 'package:inventory/pages/item.dart';
import 'package:inventory/providers/inventory.dart';
import 'package:inventory/providers/login_info.dart';
import 'package:provider/provider.dart';

class InventoryPage extends StatelessWidget {
  final int? inventoryId;
  const InventoryPage(this.inventoryId, {super.key});

  @override
  Widget build(BuildContext context) {
    String userName = context.watch<LoginInfo>().userName;

    return Scaffold(
      appBar: appBar(context),
      body: const InventoryItemsList(),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.read<InventoryProvider>().create(userName);

            if (context.mounted) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ItemPage()));
            }
          },
          tooltip: 'New',
          child: const Icon(Icons.add)),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Inventory $inventoryId',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}

class InventoryItemsList extends StatefulWidget {
  const InventoryItemsList({super.key});

  @override
  State<InventoryItemsList> createState() => _InventoryItemsListState();
}

class _InventoryItemsListState extends State<InventoryItemsList> {
  @override
  Widget build(BuildContext context) {
    List<InventoryModel> inventoryItems = [];

    return Center(
        child: inventoryItems.isEmpty
            ? const Text('No items counted, add new one')
            : ListView.builder(
                physics: const ScrollPhysics(parent: null),
                itemCount: inventoryItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.table_view),
                    title: Text('Started: ${inventoryItems[index].started}'),
                    subtitle: Text(inventoryItems[index].user),
                    trailing: inventoryItems[index].finished != null
                        ? const Icon(Icons.done)
                        : const Icon(Icons.edit),
                  );
                }));
  }
}

showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {},
  );
  Widget continueButton = TextButton(
    child: Text("Continue"),
    onPressed: () {},
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("AlertDialog"),
    content:
        Text("Would you like to continue learning how to use Flutter alerts?"),
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
