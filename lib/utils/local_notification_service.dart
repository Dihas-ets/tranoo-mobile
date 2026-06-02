import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tranoo/services/alert_notification_handler.dart';
import 'package:tranoo/utils/notification_sounds.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: AlertNotificationHandler.handleResponse,
      onDidReceiveBackgroundNotificationResponse:
          AlertNotificationHandler.handleBackgroundResponse,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          NotificationSounds.tricycleChannelId,
          'Tricycle',
          description: 'Notifications Tricycle',
          importance: Importance.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(
            NotificationSounds.generalAndroid,
          ),
        ),
      );
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          NotificationSounds.generalChannelId,
          'Notifications Tranoo',
          description: 'Annonces et mises à jour',
          importance: Importance.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(
            NotificationSounds.generalAndroid,
          ),
        ),
      );
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          NotificationSounds.alertCallChannelId,
          'Propositions alerte',
          description: 'Réponses vendeur à vos alertes',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound(
            NotificationSounds.alertRingAndroid,
          ),
        ),
      );
    }

    _initialized = true;
  }

  static Future<Map<String, String>?> getAlertLaunchData() async {
    await initialize();
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    final payload = details?.notificationResponse?.payload ?? '';
    if (!payload.startsWith('alert:')) return null;
    try {
      final decoded = jsonDecode(payload.substring(6));
      if (decoded is Map) {
        return decoded.map(
          (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
        );
      }
    } catch (_) {}
    return null;
  }

  static Future<void> showOTPNotification(String code) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'otp_channel',
      'Codes OTP',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        NotificationSounds.generalAndroid,
      ),
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: NotificationSounds.generalIos,
    );
    await _notifications.show(
      id: 1001,
      title: 'Code de vérification Tranoo',
      body: 'Votre code : $code',
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: code,
    );
  }

  static Future<void> showNotification(String title, String body) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      NotificationSounds.generalChannelId,
      'Notifications Tranoo',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        NotificationSounds.generalAndroid,
      ),
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: NotificationSounds.generalIos,
    );
    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  static Future<void> showAlertIncomingCallNotification({
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    await initialize();
    final payload = 'alert:${jsonEncode(data)}';
    final androidDetails = AndroidNotificationDetails(
      NotificationSounds.alertCallChannelId,
      'Propositions alerte',
      channelDescription: 'Réponses vendeur — style appel',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: false,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      sound: const RawResourceAndroidNotificationSound(
        NotificationSounds.alertRingAndroid,
      ),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Tranoo',
      ),
      icon: '@mipmap/ic_launcher',
      actions: const [
        AndroidNotificationAction(
          'reject',
          'Plus tard',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'accept',
          'Voir',
          showsUserInterface: true,
        ),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      sound: NotificationSounds.alertRingIos,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    await _notifications.show(
      id: 9001,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  static Future<void> showTricycleNotification(String title, String body) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      NotificationSounds.tricycleChannelId,
      'Tricycle',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        NotificationSounds.generalAndroid,
      ),
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: NotificationSounds.generalIos,
    );
    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }
}
