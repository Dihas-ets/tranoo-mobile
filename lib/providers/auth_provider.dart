import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _loading = true;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    if (storedToken != null) {
      _token = storedToken;
      try {
        final res = await http.get(
          Uri.parse('https://ton-backend.com/api/protected/me'),
          headers: {'Authorization': 'Bearer $storedToken'},
        );
        if (res.statusCode == 200) {
          _user = jsonDecode(res.body)['user'];
        } else {
          _user = null;
        }
      } catch (_) {
        _user = null;
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
    _loading = true;
    notifyListeners();
    await _loadUser();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    _user = null;
    notifyListeners();
  }
}
