import 'package:flutter/cupertino.dart';

class LoginInfo extends ChangeNotifier {
  String token = "";
  String name = "";
  String key = "";

  void login(String t, String n, String k) {
    token = t;
    name = n;
    key = k;
    notifyListeners();
  }

  void logout() {
    token = "";
    name = "";
    key = "";
    notifyListeners();
  }
}

class LoginInfoModel {
  final String token;
  final String id;
  final String key;

  const LoginInfoModel({
    this.token,
    this.id,
    this.key,
  });

  factory LoginInfoModel.fromJson(Map<String, dynamic> json) {
    return LoginInfoModel(
      token: json['token'],
      id: json['id'],
      key: json['key'],
    );
  }
}
