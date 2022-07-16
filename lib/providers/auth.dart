// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:flutter/widgets.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import "dart:convert";

import 'package:muqaddas_shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    try {
      var url = Uri.parse("http://192.168.0.190:4000/users/validate-login");
      var reqData = {"email": email, "password": password};

      if (urlSegment == 'signUp') {
        url = Uri.parse("http://192.168.0.190:4000/users");
        reqData = {
          "email": email,
          "password": password,
          "confirmPassword": password,
          "title": "N-A",
          "firstName": "N-A",
          "lastName": "N-A",
          "role": "User"
        };
      }

      final response = await http.post(
        url,
        body: reqData,
      );

      final responseData = json.decode(response.body);

      if (responseData["error"] != null) {
        throw HttpException(
          responseData["error"]["message"],
        );
      }

      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData["expiresIn"]),
        ),
      );
      autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate!.toIso8601String(),
      });

      prefs.setString("userData", userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("userData")) {
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString("userData").toString());

    final expiryDate =
        DateTime.parse(extractedUserData["expiryDate"].toString());

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData["token"].toString();
    _userId = extractedUserData["user"].toString();
    _expiryDate = expiryDate;

    notifyListeners();
    autoLogout();
    return true;
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }

    final timeExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeExpiry), logout);
  }
}
