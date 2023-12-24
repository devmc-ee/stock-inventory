import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:inventory/models/inventory_item_model.dart';
import 'package:inventory/pages/text_detector_view.dart';
import 'package:inventory/providers/inventory.dart';
import 'package:provider/provider.dart';

class InventoryItemPage extends StatelessWidget {
  InventoryItemPage({super.key});
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    InventoryItemModel? currentInventoryItem =
        context.watch<InventoryProvider>().currentInventoryItem;
    bool hasCode = context.watch<InventoryProvider>().hasCode;
    final bool isExistingItem = currentInventoryItem?.updatedAt != null;

    final createdAt =
        isExistingItem ? formatter.format(currentInventoryItem!.createdAt) : '';
    final updatedAt =
        isExistingItem ? formatter.format(currentInventoryItem!.updatedAt) : '';
    final lastCountedAmount =
        isExistingItem ? currentInventoryItem!.amount.toString() : '';
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: appBar(currentInventoryItem),
      body: Column(
        children: [
          const SubmittableTextField('Code'),
          const SubmittableTextField('Name'),
          const SubmittableTextField('Price'),
          const SubmittableTextField('Amount'),
          const Button(),
          const SizedBox(height: 30),
          isExistingItem
              ? Container(
                  decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: 50,
                  width: 300,
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Already counted item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                  ),
                )
              :  hasCode ? Container(
                  decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: 50,
                  width: 300,
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('New item',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
                  ),
                ):
                const Text('')
              ,
          Text(isExistingItem ? 'Created at: $createdAt' : ''),
          Text(isExistingItem ? 'Last update at: $updatedAt' : ''),
          Text(isExistingItem ? 'Last amount: $lastCountedAmount' : ''),
        ],
      ),
    );
  }

  AppBar appBar(InventoryItemModel? currentInventoryItem) {
    bool isExistingItem =
        currentInventoryItem != null && currentInventoryItem.createdAt != null;
    return AppBar(
      title: Text(
        isExistingItem ? currentInventoryItem.code : 'New Item',
        style: const TextStyle(fontWeight: FontWeight.bold),
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
  TextEditingController? amountController;
  TextEditingController? codeController;
  TextEditingController? priceController;
  TextEditingController? nameController;

  @override
  void initState() {
    if (mounted) {
      amountController = Provider.of<InventoryProvider>(context, listen: false)
          .amountController;
      codeController =
          Provider.of<InventoryProvider>(context, listen: false).codeController;
      priceController = Provider.of<InventoryProvider>(context, listen: false)
          .priceController;
      nameController =
          Provider.of<InventoryProvider>(context, listen: false).nameController;
      Provider.of<InventoryProvider>(context, listen: false).initControllers();
      Provider.of<InventoryProvider>(context, listen: false).validateForm();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fieldName = widget.fieldName;
    final readOnly = context.watch<InventoryProvider>().hasCurrentInventoryItem;
    Row _field = _textField(context, fieldName, readOnly);

    if (fieldName.toLowerCase() == 'price') {
      _field = _priceField(context, fieldName, readOnly);
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
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
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

  Row _priceField(BuildContext context, String fieldName, bool readOnly) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              flex: 4,
              child: TextField(
                readOnly: readOnly,
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
          Expanded(child: _submitFieldButton(fieldName, readOnly))
        ]);
  }

  Row _textField(BuildContext context, String fieldName, bool readOnly) {
    FocusNode focusNode = context.watch<InventoryProvider>().focusNode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            flex: 4,
            child: TextField(
              focusNode: fieldName.toLowerCase() == 'code' ? focusNode : null,
              readOnly: readOnly,
              controller:
                  context.read<InventoryProvider>().getController(fieldName),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: fieldName,
              ),
            )),
        const SizedBox(width: 10),
        Expanded(child: _submitFieldButton(fieldName, readOnly))
      ],
    );
  }

  FilledButton _submitFieldButton(String fieldName, bool readOnly) {
    return FilledButton(
      onPressed: fieldName.toLowerCase() == 'price' || readOnly
          ? null
          : () {
              context.read<InventoryProvider>().setRecognisedField(fieldName);
              showAlertDialog(context, fieldName);
            },
      style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
          minimumSize: const Size.fromHeight(65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          )),
      child: const Icon(Icons.camera_alt),
    );
  }

  FilledButton _changeAmountButton(bool isIncrease, BuildContext context) {
    int _amount = context.read<InventoryProvider>().amount;
    InventoryItemModel? _existingItem =
        context.read<InventoryProvider>().currentInventoryItem;
    int _minAmount = _existingItem != null ? _existingItem.amount : 0;

    bool _isEnabled = _amount > _minAmount;

    void _toggleEnabled() {
      setState(() {
        _isEnabled = _amount > _minAmount;
      });
    }

    void _setAmount() {
      setState(() {
        _amount = context.read<InventoryProvider>().amount;
      });
    }

    return FilledButton(
      onPressed: _isEnabled && !isIncrease || isIncrease
          ? () {
              context.read<InventoryProvider>().changeAmount(isIncrease);
              _setAmount();
              _toggleEnabled();
              print(_isEnabled && !isIncrease || isIncrease);
            }
          : null,
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
  void initState() {
    if (mounted) {
      Provider.of<InventoryProvider>(context, listen: false).validateForm();
    }
    super.initState();
  }

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
              onPressed: canSubmit
                  ? () async {
                      final msg = await context
                          .read<InventoryProvider>()
                          .handleInventoryItem();

                      final snackBar = SnackBar(
                          content: msg.content, backgroundColor: msg.color);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

showAlertDialog(BuildContext context, String calledBy) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: const Text("SAVE"),
    onPressed: () async {
      context.read<InventoryProvider>().submitRecognisedText();
      Navigator.pop(context);
    },
  );
  // set up the AlertDialog
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String recognisedText =
          context.watch<InventoryProvider>().recognisedTextGroup;

      return AlertDialog(
        title: Text(calledBy),
        content: Container(
          height: 400,
          child: Column(
            children: [
              Expanded(flex: 2, child: TextRecognizerView()),
              Expanded(
                flex: 1,
                child: Center(
                    child: Text(recognisedText,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
              )
            ],
          ),
        ),
        actions: [
          cancelButton,
          continueButton,
        ],
      );
    },
  );
}
