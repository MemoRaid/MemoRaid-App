import 'package:flutter/material.dart';

class User {
  String name;
  String address;
  String telephone;

  User({
    required this.name,
    required this.address,
    required this.telephone,
  });
}

class UserProvider with ChangeNotifier {
  User _user =
      User(name: 'Mr.John', address: '123 Main St', telephone: '123-456-7890');

  User get user => _user;

  void updateUser(
      {required String name,
      required String address,
      required String telephone}) {
    _user = User(name: name, address: address, telephone: telephone);
    notifyListeners();
  }
}
