import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Permissions pour afficher les alertes « appel entrant » hors app.
class AlertDisplayPermissionService {
  static const String _promptedKey = 'tranoo_buyer_alert_display_permission_v1';

  static const MethodChannel _channel =
      MethodChannel('tranoo/alert_permissions');

  /// Android 14+ (API 34) : autorisation « notifications plein écran ».
  static Future<bool> needsFullScreenIntentPrompt() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    if (info.version.sdkInt < 34) return false;
    try {
      final granted =
          await _channel.invokeMethod<bool>('canUseFullScreenIntent');
      return granted != true;
    } catch (_) {
      return true;
    }
  }

  static Future<bool> canUseFullScreenIntent() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    final info = await DeviceInfoPlugin().androidInfo;
    if (info.version.sdkInt < 34) return true;
    try {
      return await _channel.invokeMethod<bool>('canUseFullScreenIntent') == true;
    } catch (_) {
      return false;
    }
  }

  /// Ouvre l'écran système dédié (Android 14+) ou les paramètres de l'app.
  static Future<bool> openFullScreenIntentSettings() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;

    final info = await DeviceInfoPlugin().androidInfo;
    if (info.version.sdkInt >= 34) {
      final ok = await android.requestFullScreenIntentPermission();
      return ok == true;
    }
    await openAppSettings();
    return true;
  }

  static Future<bool> ensureNotificationPermission() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    final info = await DeviceInfoPlugin().androidInfo;
    if (info.version.sdkInt < 33) return true;
    var status = await Permission.notification.status;
    if (status.isGranted) return true;
    status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> shouldShowPrompt() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_promptedKey) == true) {
      // Re-proposer si l'autorisation plein écran a été révoquée (Android 14+).
      if (await needsFullScreenIntentPrompt()) return true;
      return false;
    }
    return true;
  }

  static Future<void> markPromptSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promptedKey, true);
  }

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
}
