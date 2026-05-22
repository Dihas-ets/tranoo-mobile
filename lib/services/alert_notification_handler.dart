import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/main.dart';
import 'package:tranoo/services/alert_call_payload.dart';
import 'package:tranoo/services/alert_pending_store.dart';
import 'package:tranoo/widgets/alert_incoming_call_overlay.dart';

class AlertNotificationHandler {
  static Future<void> handleResponse(NotificationResponse response) async {
    final payload = response.payload ?? '';
    if (!payload.startsWith('alert:')) return;

    Map<String, String> data = {};
    try {
      final decoded = jsonDecode(payload.substring(6));
      if (decoded is Map) {
        data = decoded.map(
          (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
        );
      }
    } catch (_) {
      return;
    }

    if (response.actionId == 'reject') {
      await AlertPendingStore.clear();
      return;
    }

    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;

    await AlertPendingStore.clear();

    final notificationId = data['notificationId'] ?? '';

    if (response.actionId == 'accept') {
      nav.push(
        MaterialPageRoute(
          builder: (_) => const Notifications(),
        ),
      );
      return;
    }

    // Tap sur la bannière : plein écran dans l'app
    await AlertIncomingCallService.showPayload(
      AlertCallPayload(
        title: data['title'] ?? 'Nouvelle proposition',
        body: data['message'] ?? 'Un vendeur a répondu à votre alerte',
        data: data,
      ),
      navigatorKey: rootNavigatorKey,
    );
  }

  @pragma('vm:entry-point')
  static void handleBackgroundResponse(NotificationResponse response) {
    handleResponse(response);
  }
}
