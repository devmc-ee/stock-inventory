import 'package:flutter/material.dart';
import 'package:inventory/providers/login_info.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.all(8), child: UserNameField()),
          Button()
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Inventory',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}

class UserNameField extends StatefulWidget {
  const UserNameField({super.key});

  @override
  State<UserNameField> createState() => _UserNameFieldState();
}

class _UserNameFieldState extends State<UserNameField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: context.read<LoginInfo>().userNameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Name',
      ),
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
    context.read<LoginInfo>().init();
    final ButtonStyle style = FilledButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        minimumSize: const Size.fromHeight(50),
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
              onPressed: () {
                context.read<LoginInfo>().login();
              },
              child: const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}
