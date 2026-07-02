import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache local JSON avec TTL — stale-while-revalidate côté écrans.
class LocalDataCache {
  LocalDataCache._();

  static const Duration defaultTtl = Duration(seconds: 30);

  static Future<List<dynamic>?> readJsonList(
    String key, {
    Duration maxAge = defaultTtl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    final ts = prefs.getInt('$key:ts');
    if (raw == null || ts == null) return null;
    if (DateTime.now().millisecondsSinceEpoch - ts > maxAge.inMilliseconds) {
      return null;
    }
    try {
      final decoded = json.decode(raw);
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }

  /// Lit le cache même expiré (affichage immédiat stale-while-revalidate).
  static Future<List<dynamic>?> readJsonListStale(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = json.decode(raw);
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }

  static Future<void> writeJsonList(String key, List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
    await prefs.setInt(
      '$key:ts',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<Map<String, dynamic>?> readJsonMap(
    String key, {
    Duration maxAge = defaultTtl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    final ts = prefs.getInt('$key:ts');
    if (raw == null || ts == null) return null;
    if (DateTime.now().millisecondsSinceEpoch - ts > maxAge.inMilliseconds) {
      return null;
    }
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> readJsonMapStale(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  static Future<void> writeJsonMap(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
    await prefs.setInt(
      '$key:ts',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
