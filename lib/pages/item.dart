import 'package:flutter/material.dart';
import 'package:inventory/providers/inventory.dart';
import 'package:provider/provider.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    int inventoryId = context.watch<InventoryProvider>().currentInventoryId;
    return Scaffold(
      appBar: appBar(inventoryId),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Code',
              ),
            ),
          ),
          ElevatedButtonExample()
        ],
      ),
    );
  }

  AppBar appBar(int id) {
    return AppBar(
      title: Text(
        'Inventory id $id',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}

class ElevatedButtonExample extends StatefulWidget {
  const ElevatedButtonExample({super.key});

  @override
  State<ElevatedButtonExample> createState() => _ElevatedButtonExampleState();
}

class _ElevatedButtonExampleState extends State<ElevatedButtonExample> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {
              print('Clicked');
            },
            child: const Text('Enabled'),
          ),
        ],
      ),
    );
  }
}
