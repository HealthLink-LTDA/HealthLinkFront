import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;

  void login(String email, String password) {
    // Accept any credentials for now
    _isLoggedIn = true;
    _currentUser = email;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}