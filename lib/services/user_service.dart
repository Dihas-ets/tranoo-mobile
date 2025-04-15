import 'package:flutter/material.dart';
import '../utils/role_redirect.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserRole? _currentRole;

  UserRole? get currentRole => _currentRole;

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void clearRole() {
    _currentRole = null;
    notifyListeners();
  }
}
