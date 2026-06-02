import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Permissions pour les notifications d'alertes vendeur (sans plein écran — politique Play).
class AlertDisplayPermissionService {
  static const String _promptedKey = 'tranoo_buyer_alert_display_permission_v1';

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
    if (prefs.getBool(_promptedKey) == true) return false;
    if (await ensureNotificationPermission()) {
      await markPromptSeen();
      return false;
    }
    return true;
  }

  static Future<void> markPromptSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promptedKey, true);
  }
}
