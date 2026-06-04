import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/backend_config.dart';

class PushOTPService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final String _baseUrl = getPushOtpBaseUrl();

  /// Dernier code OTP reçu (FCM). Les pages de vérification écoutent ce notifier.
  static final ValueNotifier<String?> pendingOtpCode = ValueNotifier(null);

  static String? extractOtpFromRemoteMessage(RemoteMessage message) {
    if (message.data['type'] != 'otp') return null;
    String? code = message.data['code'] as String?;
    if (code == null || code.isEmpty) {
      final body = message.notification?.body ??
          (message.data['body'] as String?) ??
          '';
      code = RegExp(r'\b(\d{6})\b').firstMatch(body)?.group(1);
    }
    code = code?.trim();
    if (code != null && RegExp(r'^\d{6}$').hasMatch(code)) return code;
    return null;
  }

  static void notifyOtpCode(String code) {
    final trimmed = code.trim();
    if (RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      pendingOtpCode.value = trimmed;
    }
  }

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

  /// Mot de passe oublié : OTP WhatsApp + notification push (fallback FCM).
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String telephone,
    String? countryCode,
    String? nationalNumber,
    required String app,
  }) async {
    try {
      if (telephone.trim().isEmpty) {
        return {'success': false, 'message': 'Veuillez entrer votre numéro.'};
      }

      // Token FCM de cet appareil (fallback si WhatsApp invisible)
      String? fcmToken = await getFCMToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        fcmToken = prefs.getString('fcm_token');
      }

      final url = '$_baseUrl/api/push-otp/request';
      debugPrint(
        '[RESET] POST $url telephone=${telephone.trim()} app=$app fcm=${fcmToken != null}',
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'telephone': telephone.trim(),
          if (countryCode != null) 'countryCode': countryCode,
          if (nationalNumber != null) 'nationalNumber': nationalNumber,
          'app': app,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        }),
      );

      final data = json.decode(response.body) as Map<String, dynamic>? ?? {};
      developer.log(
        '[RESET] request status=${response.statusCode} body=$data',
        name: 'PushOTPService',
      );

      if (response.statusCode == 200) {
        final requestId = data['requestId']?.toString();
        final deviceId = data['deviceId']?.toString();
        if (requestId == null ||
            requestId.isEmpty ||
            deviceId == null ||
            deviceId.isEmpty) {
          return {
            'success': false,
            'message':
                'Aucun compte trouvé pour ce numéro WhatsApp. Vérifiez le numéro utilisé à l\'inscription.',
          };
        }
        return {
          'success': true,
          'message': data['message'] as String? ??
              'Code envoyé. Vérifiez WhatsApp ou la notification Tranoo.',
          'requestId': requestId,
          'deviceId': deviceId,
          'expiresInSeconds': data['expiresInSeconds'],
          'sentToMasked': data['sentToMasked']?.toString(),
          'channels': data['channels'],
          if (data['devOtp'] != null) 'devOtp': data['devOtp']?.toString(),
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
      developer.log(
        '[RESET] verify status=${response.statusCode} body=$data',
        name: 'PushOTPService',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Code vérifié.'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur inconnue',
        };
      }
    } catch (e) {
      developer.log('[RESET] verify error: $e', name: 'PushOTPService');
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
      developer.log(
        '[RESET] reset-password status=${response.statusCode}',
        name: 'PushOTPService',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Mot de passe réinitialisé.'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur inconnue',
        };
      }
    } catch (e) {
      developer.log('[RESET] reset-password error: $e', name: 'PushOTPService');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  static void setupNotificationHandlers() {
    void handleOtpMessage(RemoteMessage message) {
      final code = extractOtpFromRemoteMessage(message);
      if (code != null) {
        developer.log('[RESET] OTP FCM → remplissage auto', name: 'PushOTPService');
        notifyOtpCode(code);
      }
    }

    FirebaseMessaging.onMessage.listen(handleOtpMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleOtpMessage);
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
