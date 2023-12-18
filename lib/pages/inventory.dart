import 'package:flutter/material.dart';
import 'package:inventory/models/inventory_imodel.dart';
import 'package:inventory/pages/item.dart';
import 'package:inventory/providers/inventory.dart';
import 'package:inventory/providers/login_info.dart';
import 'package:provider/provider.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: const InventoryItemsList(),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
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
    InventoryModel? currentInventory;
    if (context.mounted) {
      currentInventory = context.watch<InventoryProvider>().currentInventory;
    }
    return AppBar(
      title: Text(
        'Inventory ${currentInventory?.id}',
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
  InventoryModel? _currentInventory;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _currentInventory = context.watch<InventoryProvider>().currentInventory;

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
