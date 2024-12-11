import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;

  void login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('localhost:3001/funcionario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': password,
        }),
      );

      final String? token = response.headers['authorization'];

      if (token != null) {
        //Navigator.pushReplacementNamed(context, route);

        _isLoggedIn = true;
        _currentUser = email;
        notifyListeners();
      }
    } catch (e) {
      print('Erro de login: $e');
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
