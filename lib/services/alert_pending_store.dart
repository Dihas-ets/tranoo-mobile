import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertPendingStore {
  static const _key = 'tranoo_pending_alert_v1';

  static Future<void> save(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'messageId': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    };
    await prefs.setString(_key, jsonEncode(map));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
