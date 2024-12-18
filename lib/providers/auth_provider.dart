import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUser;
  String? _authToken;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get authToken => _authToken;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': password,
        }),
      );

      if (response.statusCode == 200) {
        final String? token = jsonDecode(response.body)['access_token'];

        if (token != null) {
          _isLoggedIn = true;
          _currentUser = email;
          _authToken = token;
          notifyListeners();
          return true;
        }
      } else {
        debugPrint('Login failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erro de login: $e');
      return false;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}

