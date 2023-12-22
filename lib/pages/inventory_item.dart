import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory/providers/inventory.dart';
import 'package:provider/provider.dart';

class InventoryItemPage extends StatelessWidget {
  const InventoryItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: appBar(),
      body: const Column(
        children: [
          SubmittableTextField('Code'),
          SubmittableTextField('Name'),
          SubmittableTextField('Price'),
          SubmittableTextField('Amount'),
          Button(),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'New Item',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}
class SubmittableTextField extends StatefulWidget {
  final String fieldName;

  const SubmittableTextField(this.fieldName, {super.key});
  @override
  State<SubmittableTextField> createState() => _SubmittableTextField();
}

class _SubmittableTextField extends State<SubmittableTextField> {
  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    Provider.of<InventoryProvider>(context, listen: false)
        .amountController
        .addListener(() {
      Provider.of<InventoryProvider>(context, listen: false).validateForm();
    });
    Provider.of<InventoryProvider>(context, listen: false)
        .codeController
        .addListener(() {
      Provider.of<InventoryProvider>(context, listen: false).validateForm();
    });
    Provider.of<InventoryProvider>(context, listen: false)
        .priceController
        .addListener(() {
      Provider.of<InventoryProvider>(context, listen: false).validateForm();
    });
    Provider.of<InventoryProvider>(context, listen: false)
        .nameController
        .addListener(() {
      Provider.of<InventoryProvider>(context, listen: false).validateForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fieldName = widget.fieldName;

    var _field = _textField(context, fieldName);

    if (fieldName.toLowerCase() == 'price') {
      _field = _priceField(context, fieldName);
    }

    if (fieldName.toLowerCase() == 'amount') {
      _field = _amountField(context, fieldName);
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: _field,
    );
  }

  Row _amountField(BuildContext context, String fieldName) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _changeAmountButton(false, context)),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                readOnly: true,
            textAlign: TextAlign.center,
            controller: context.read<InventoryProvider>().amountController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
               FilteringTextInputFormatter.deny(
                      RegExp(r'\s')),
            ],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: fieldName,
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: _changeAmountButton(true, context)),
        ]);
  }

  Row _priceField(BuildContext context, String fieldName) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              flex: 4,
              child: TextField(
                controller: context.read<InventoryProvider>().priceController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                ],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Price',
                    suffixIcon: Icon(Icons.euro)),
              )),
          const SizedBox(width: 10),
          Expanded(child: _submitFieldButton(fieldName))
        ]);
  }

  Row _textField(BuildContext context, String fieldName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            flex: 4,
            child: TextField(
              controller:
                  context.read<InventoryProvider>().getController(fieldName),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: fieldName,
              ),
            )),
        const SizedBox(width: 10),
        Expanded(child: _submitFieldButton(fieldName))
      ],
    );
  }

  FilledButton _submitFieldButton(fieldName) {
    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
          minimumSize: const Size.fromHeight(65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          )),
      child: const Icon(Icons.done),
    );
  }

  FilledButton _changeAmountButton(bool isIncrease, BuildContext context) {
    int _amount = context.read<InventoryProvider>().amount;
    bool _isEnabled = _amount > 0;

    void _toggleEnabled() {
      print('amount');
      print(_amount);
      print( _amount > 0);
      setState(() {
        _isEnabled = _amount > 0;
      });
    }

    void _setAmount() {
      setState(() {
        _amount = context.read<InventoryProvider>().amount;
      });
    }
    return FilledButton(
      onPressed: _isEnabled && !isIncrease || isIncrease ? () {
        context.read<InventoryProvider>().changeAmount(isIncrease);
        _setAmount();
        _toggleEnabled();
        print(_isEnabled && !isIncrease || isIncrease);
      } : null,
      style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 30),
          minimumSize: const Size.fromHeight(65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          )),
      child: Text(isIncrease ? '+' : '-'),
    );
  }
}

class Button extends StatefulWidget {
  const Button({super.key});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    bool canSubmit = context.watch<InventoryProvider>().canSubmit;

    final ButtonStyle style = FilledButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        minimumSize: const Size.fromHeight(65),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ));
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton(
              style: style,
              onPressed: canSubmit ?  () {
                context.read<InventoryProvider>().addInventoryItem();
              }: null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
