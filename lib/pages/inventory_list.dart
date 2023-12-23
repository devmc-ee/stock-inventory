import 'package:flutter/material.dart';
import 'package:inventory/models/inventory_item_model.dart';
import 'package:inventory/models/inventory_list_model.dart';
import 'package:inventory/pages/inventory_item.dart';
import 'package:inventory/providers/inventory.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class InventoryListPage extends StatelessWidget {
  const InventoryListPage({super.key});
  @override
  Widget build(BuildContext context) {
    bool isOpenSearchBar = context.watch<InventoryProvider>().isOpenedSearchBar;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(isOpenSearchBar ? 140 : 60),
          child: const TopBar()),
      body: const InventoryItemsList(),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (context.mounted) {
              context.read<InventoryProvider>().dropCurrentIventoryItem();

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  InventoryItemPage()));
            }
          },
          tooltip: 'New',
          child: const Icon(Icons.add)),
    );
  }
}

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    bool isOpenSearchBar = context.watch<InventoryProvider>().isOpenedSearchBar;
    InventoryListModel? currentInventory;
    if (context.mounted) {
      currentInventory = context.watch<InventoryProvider>().currentInventory;
    }
    return AppBar(
        title: Text(
          'Inventory ${currentInventory?.id} by ${currentInventory?.user}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search items',
            onPressed: context.read<InventoryProvider>().toggleOpenSearchBar,
          ),
        ],
        bottom: !isOpenSearchBar
            ? null
            : PreferredSize(
                preferredSize: const Size(0, 0),
                child: TextField(
                  autofocus: true,
                  style: const TextStyle(fontSize: 30.0, height: 1.0),
                  controller:
                      context.read<InventoryProvider>().searchController,
                  decoration:  InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Search',
                    suffix: TextButton(onPressed: () {
                      context.read<InventoryProvider>().clearSearch();
                    }, child: const Icon(Icons.close),),
                  ),
                ),
              ));
  }
}

class InventoryItemsList extends StatefulWidget {
  const InventoryItemsList({super.key});

  @override
  State<InventoryItemsList> createState() => _InventoryItemsListState();
}

class _InventoryItemsListState extends State<InventoryItemsList> {
  InventoryListModel? _currentInventory;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  @override
  void initState() {
    super.initState();

    context.read<InventoryProvider>().getInventorieItems();
    context.read<InventoryProvider>().initSearchController();
  }

  @override
  Widget build(BuildContext context) {
    _currentInventory = context.watch<InventoryProvider>().currentInventory;

    List<InventoryItemModel> inventoryItems =
        context.watch<InventoryProvider>().inventoryItems;

    return inventoryItems.isEmpty
        ? const Center(child: Text('No items found, add new one'))
        : ListView.builder(
            itemCount: inventoryItems.length,
            itemBuilder: (context, index) {
              return Dismissible(
                  key: Key(inventoryItems[index].code),
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm delete"),
                            content: const Text(
                                "Are you sure you wish to delete this item?"),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("DELETE")),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCEL"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  onDismissed: (direction) {
                    context
                        .read<InventoryProvider>()
                        .deleteInventoryItem(inventoryItems[index].code);
                  },
                  child: Card(
                      child: ListTile(
                    leading: Text(
                      inventoryItems[index].amount.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () async {
                      if (context.mounted) {
                        context
                            .read<InventoryProvider>()
                            .setCurrentInventoryItem(
                                inventoryItems[index].code);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    InventoryItemPage()));
                      }
                    },
                    subtitle: Text('${inventoryItems[index].name} (${formatter.format(inventoryItems[index].updatedAt)})'),
                    title: Text(inventoryItems[index].code, style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                    trailing:  Text('€${inventoryItems[index].price.toString()}'),
                  )));
            });
  }
}
