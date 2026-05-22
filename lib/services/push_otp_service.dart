import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/backend_config.dart';

class PushOTPService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final String _baseUrl = getPushOtpBaseUrl();

  static Future<String?> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        // info.id est l'ID unique du device Android (remplace androidId dans les nouvelles versions)
        return info.id.isNotEmpty ? info.id : null;
      }
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.identifierForVendor;
      }
      return null;
    } catch (e) {
      print('Erreur récupération deviceId: $e');
      return null;
    }
  }

  // Récupérer le token FCM de l'utilisateur
  static Future<String?> getFCMToken() async {
    try {
      // Demander les permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? token = await _messaging.getToken();
        print('FCM Token obtenu: $token');

        // Sauvegarder le token localement
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token ?? '');

        return token;
      } else {
        print('Permissions de notification refusées');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du token FCM: $e');
      return null;
    }
  }

  // Envoyer le token FCM au backend
  static Future<bool> sendFCMTokenToBackend(String fcmToken) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final idToken = await user.getIdToken();
      final deviceId = await getDeviceId();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/fcm-token'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fcmToken': fcmToken, 'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        print('Token FCM envoyé au backend avec succès');
        return true;
      } else {
        print('Erreur envoi token FCM: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erreur envoi token FCM: $e');
      return false;
    }
  }

  /// Mot de passe oublié : OTP WhatsApp au numéro enregistré sur le compte.
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String telephone,
  }) async {
    try {
      if (telephone.trim().isEmpty) {
        return {'success': false, 'message': 'Veuillez entrer votre numéro.'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/push-otp/request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'telephone': telephone.trim(),
        }),
      );

      final data = json.decode(response.body) as Map<String, dynamic>? ?? {};

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] as String? ?? 'Code envoyé sur WhatsApp.',
          'requestId': data['requestId'],
          'deviceId': data['deviceId'],
          'expiresInSeconds': data['expiresInSeconds'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] as String? ?? 'Erreur inconnue',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyResetCode({
    required String requestId,
    required String deviceId,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push-otp/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'requestId': requestId,
          'deviceId': deviceId,
          'code': code,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Code vérifié.'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur inconnue',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String requestId,
    required String deviceId,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push-otp/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'requestId': requestId,
          'deviceId': deviceId,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Mot de passe réinitialisé.'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur inconnue',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // Configurer les handlers de notifications
  static void setupNotificationHandlers() {
    // Notification reçue en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notification reçue en foreground: ${message.notification?.title}');
      print('Notification body: ${message.notification?.body}');
      print('Notification data: ${message.data}');

      if (message.data['type'] == 'otp') {
        // Extraire le code depuis data.code (prioritaire) ou depuis notification.body
        String? code = message.data['code'] as String?;
        if (code == null || code.isEmpty) {
          // Fallback: extraire depuis notification.body (format: "Votre code : 123456")
          final body = message.notification?.body ?? '';
          final match = RegExp(r'(\d{6})').firstMatch(body);
          code = match?.group(1);
        }
        
        if (code != null && code.isNotEmpty) {
          print('Code OTP extrait: $code');
          _showOTPNotification(code);
        } else {
          print('⚠️ Code OTP non trouvé dans la notification');
        }
      }
    });

    // Notification tapée (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapée: ${message.notification?.title}');
      print('Notification body: ${message.notification?.body}');
      print('Notification data: ${message.data}');

      if (message.data['type'] == 'otp') {
        // Extraire le code depuis data.code (prioritaire) ou depuis notification.body
        String? code = message.data['code'] as String?;
        if (code == null || code.isEmpty) {
          // Fallback: extraire depuis notification.body (format: "Votre code : 123456")
          final body = message.notification?.body ?? '';
          final match = RegExp(r'(\d{6})').firstMatch(body);
          code = match?.group(1);
        }
        
        if (code != null && code.isNotEmpty) {
          print('Code OTP extrait: $code');
          _showOTPNotification(code);
        } else {
          print('⚠️ Code OTP non trouvé dans la notification');
        }
      }
    });
  }

  // Afficher une notification avec le code OTP
  static void _showOTPNotification(String code) {
    // Cette méthode sera appelée depuis le contexte de l'app
    // L'implémentation sera dans les pages qui utilisent le service
  }

  // Initialiser le service complet
  static Future<bool> initialize() async {
    try {
      // Configurer les handlers
      setupNotificationHandlers();

      // Récupérer le token FCM
      final token = await getFCMToken();
      if (token != null) {
        // Envoyer le token au backend
        await sendFCMTokenToBackend(token);
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur initialisation PushOTPService: $e');
      return false;
    }
  }
}

String getPushOtpBaseUrl() => getBackendBaseUrl();
