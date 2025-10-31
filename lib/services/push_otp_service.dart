import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushOTPService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final String _baseUrl = getPushOtpBaseUrl();

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
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/update-fcm-token'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fcmToken': fcmToken}),
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

  // Récupérer le numéro de téléphone par email
  static Future<Map<String, dynamic>> getPhoneByEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/public/users/phone-by-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'phoneNumber': data['phoneNumber'],
          'message': data['message'],
        };
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

  // Demander un code OTP
  static Future<Map<String, dynamic>> requestOTP(String telephone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push-otp/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'telephone': telephone}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'messageId': data['messageId'],
        };
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

  // Vérifier seulement le code OTP (sans réinitialiser le mot de passe)
  static Future<Map<String, dynamic>> verifyOTPCode({
    required String telephone,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push-otp/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'telephone': telephone, 'code': code}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
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

  // Vérifier le code OTP et réinitialiser le mot de passe
  static Future<Map<String, dynamic>> verifyOTPAndResetPassword({
    required String telephone,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push-otp/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'telephone': telephone,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
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

      if (message.data['type'] == 'otp') {
        final code = message.data['code'];
        if (code != null) {
          _showOTPNotification(code);
        }
      }
    });

    // Notification tapée (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapée: ${message.notification?.title}');

      if (message.data['type'] == 'otp') {
        final code = message.data['code'];
        if (code != null) {
          _showOTPNotification(code);
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

String getPushOtpBaseUrl() {
  // URL de base pour les endpoints push OTP (sans /api)
  return 'http://192.168.1.87:5000';
}
