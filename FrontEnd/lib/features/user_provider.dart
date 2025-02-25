import 'package:flutter/material.dart';

class User {
  String username;
  String profileName;
  String? profileImage;
  String? dateOfBirth;
  String? country;
  String? bio;
  String? gender;
  String? email;
  String? phoneNumber;

  User({
    required this.username,
    required this.profileName,
    this.profileImage,
    this.dateOfBirth,
    this.country,
    this.bio,
    this.gender,
    this.email,
    this.phoneNumber,
  });
}

class UserProvider with ChangeNotifier {
  User _user = User(
    username: 'johnfern3',
    profileName: 'Mr.John',
    country: 'United States',
    email: 'john@example.com',
  );

  User get user => _user;

  void updateUser({
    required String username,
    required String profileName,
    String? profileImage,
    String? dateOfBirth,
    String? country,
    String? bio,
    String? gender,
    String? email,
    String? phoneNumber,
  }) {
    _user = User(
      username: username,
      profileName: profileName,
      profileImage: profileImage ?? _user.profileImage,
      dateOfBirth: dateOfBirth ?? _user.dateOfBirth,
      country: country ?? _user.country,
      bio: bio ?? _user.bio,
      gender: gender ?? _user.gender,
      email: email ?? _user.email,
      phoneNumber: phoneNumber ?? _user.phoneNumber,
    );
    notifyListeners();
  }
}
