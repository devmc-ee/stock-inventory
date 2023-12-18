import 'package:flutter/material.dart';
import 'package:inventory/services/database.dart';

class LoginInfo extends ChangeNotifier {
  var _userName = '';
  final _controller = TextEditingController();

  String get userName => _userName;
  TextEditingController get userNameController => _controller;
  bool get loggedIn => _userName.isNotEmpty;

  void init() async {
    _userName = await DatabaseService.getUser();

    notifyListeners();
  }

  void login() async {
    int userId = 0;
    _userName = await DatabaseService.getUser();

    print('_userName');
    print(_userName);
    // single time login
    if (_userName.isEmpty) {
      _userName = _controller.text;

      if (_userName.isNotEmpty) {
        try {
          userId = await DatabaseService.saveUser({'name': _userName});

          if (userId == 0) {
            print('Failed to insert new username');
          }
        } catch (error) {
          print(error);
        }
      }
    }

    if (_userName.isNotEmpty) {
      notifyListeners();
    }
  }
}
