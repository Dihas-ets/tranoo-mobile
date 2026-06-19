import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tranoo/utils/notification_i18n.dart';

class AlertCallPayload {
  final String title;
  final String body;
  final Map<String, String> data;

  const AlertCallPayload({
    required this.title,
    required this.body,
    required this.data,
  });

  factory AlertCallPayload.fromRemoteMessage(
    RemoteMessage message, {
    String locale = 'fr',
  }) {
    final data = message.data.map(
      (k, v) => MapEntry(k, v?.toString() ?? ''),
    );
    final push = NotificationI18n.resolvePushFromData(
      notificationTitle: message.notification?.title,
      notificationBody: message.notification?.body,
      data: data,
      locale: locale,
      defaultTitle: 'Nouvelle proposition',
    );
    return AlertCallPayload(
      title: push.title,
      body: push.body,
      data: data,
    );
  }
}
