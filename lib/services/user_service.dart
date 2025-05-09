import 'package:flutter/material.dart';
import '../utils/role_redirect.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserRole? _currentRole;

  UserRole? get currentRole => _currentRole;
  bool get isTransitaire => _currentRole == UserRole.transitaire;
  bool get isVendeur => _currentRole == UserRole.vendeur;
  bool get isAcheteur => _currentRole == UserRole.acheteur;

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void clearRole() {
    _currentRole = null;
    notifyListeners();
  }
}
