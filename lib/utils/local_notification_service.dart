import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String tricycleChannelId = 'tricycle_channel';
  static const String tricycleSoundAndroid = 'driver_request_sound'; // res/raw/driver_request_sound.*
  static const String tricycleSoundIOS = 'driver_request_sound.wav';

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapée: ${details.payload}');
      },
    );

    // Créer le channel Tricycle avec son custom (Android 8+)
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          tricycleChannelId,
          'Tricycle',
          description: 'Notifications Tricycle (demandes, annulations, rejets)',
          importance: Importance.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(tricycleSoundAndroid),
        ),
      );
    }

    _initialized = true;
  }

  static Future<void> showOTPNotification(String code) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'otp_channel',
      'Codes OTP',
      channelDescription: 'Notifications pour les codes de vérification OTP',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1001,
      '🔐 Code de vérification Tranoo',
      'Votre code : $code',
      details,
      payload: code,
    );
  }

  static Future<void> showNotification(String title, String body) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'Notifications générales',
      channelDescription: 'Notifications générales de l\'application',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  static Future<void> showTricycleNotification(String title, String body) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      tricycleChannelId,
      'Tricycle',
      channelDescription: 'Notifications Tricycle (demandes, annulations, rejets)',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: RawResourceAndroidNotificationSound(tricycleSoundAndroid),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: tricycleSoundIOS,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }
}
