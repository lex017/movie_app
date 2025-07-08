import 'package:flutter/foundation.dart';

class Usermovie extends ChangeNotifier {
  String username = '';
  String email = '';
  String pass = '';
  int userId = 0;

  void setUser({
    required String username,
    required String email,
    required String pass,
    required int userId,
  }) {
    this.username = username;
    this.email = email;
    this.pass = pass;
    this.userId = userId;
    notifyListeners();
  }

  void clearUser() {
    username = '';
    email = '';
    pass = '';
    userId = 0;
    notifyListeners();
  }
}
