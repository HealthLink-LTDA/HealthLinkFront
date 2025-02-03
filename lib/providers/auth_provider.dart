import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUser;
  String? _authToken;
  int? _userRole;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get authToken => _authToken;
  int? get userRole => _userRole;

  Future<bool> login(String email, String password) async {
    try {
      final loginResponse = await http.post(
        Uri.parse('http://localhost:3001/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': password,
        }),
      );

      if (loginResponse.statusCode == 200) {
        final String? token = jsonDecode(loginResponse.body)['access_token'];

        if (token != null) {
          final userResponse = await http.get(
            Uri.parse('http://localhost:3001/funcionario/email/$email'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (userResponse.statusCode == 200) {
            final userData = jsonDecode(userResponse.body);
            _isLoggedIn = true;
            _currentUser = email;
            _authToken = token;
            _userRole = userData['cargo']['id'];
            notifyListeners();
            return true;
          }
        }
      }
      debugPrint(
          'Login failed: ${loginResponse.statusCode} ${loginResponse.body}');
      return false;
    } catch (e) {
      debugPrint('Erro de login: $e');
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _authToken = null;
    _userRole = null;
    notifyListeners();
  }
}
