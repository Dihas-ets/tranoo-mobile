import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';
<<<<<<< HEAD
=======
import 'package:flutter/foundation.dart' show kIsWeb;
>>>>>>> 4f4bd90b735a4682a406fe615c5da8ce3a99aa9d
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _loading = true;
  final Logger _logger = Logger('AuthProvider');

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;

  AuthProvider() {
    debugPrint('[AuthProvider] CONSTRUCTEUR appelé');
    _init();
  }

  Future<void> _sendFcmTokenToBackend() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        _logger.warning('Token FCM non disponible');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.warning('Utilisateur non connecté');
        return;
      }

      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse('http://192.168.100.21:5000/api/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200) {
        _logger.info('Token FCM envoyé au backend avec succès');
      } else {
        _logger.warning(
          'Erreur lors de l\'envoi du token FCM: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Erreur lors de l\'envoi du token FCM: $e');
    }
  }

  Future<void> _init() async {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      debugPrint('[AuthProvider] Firebase user: $firebaseUser');
      _loading = true;
      notifyListeners();
      if (firebaseUser != null) {
        debugPrint(
          '[AuthProvider] Firebase user (avant getIdToken): $firebaseUser',
        );
        final idToken = await firebaseUser.getIdToken();
        debugPrint('[AuthProvider] idToken (avant requête backend): $idToken');
        _token = idToken;
        try {
          // URL dynamique selon la plateforme
<<<<<<< HEAD
          final String baseUrl = 'https://api.tranoo.store/api';

          // final String baseUrl =
          //     kIsWeb
          //         ? 'http://localhost:5000/api' // compilation via web
          //         : (Platform.isAndroid &&
          //                 !Platform.isFuchsia &&
          //                 !isPhysicalDevice()
          //             ? 'http://10.0.2.2:5000/api' // émulateur Android
          //             : 'http://192.168.100.21:5000/api'); //  IP de la machine sur le réseau local téléphone physique (Android/iOS)
=======
          final String baseUrl =
              kIsWeb
                  ? 'http://localhost:5000/api' // compilation via web
                  : (Platform.isAndroid &&
                          !Platform.isFuchsia &&
                          !isPhysicalDevice()
                      ? 'http://10.0.2.2:5000/api' // émulateur Android
                      : 'http://192.168.100.21:5000/api'); //  IP de la machine sur le réseau local téléphone physique (Android/iOS)
>>>>>>> 4f4bd90b735a4682a406fe615c5da8ce3a99aa9d
          final dio = Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: {'Authorization': 'Bearer $idToken'},
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          try {
            final response = await dio.get('/protected/me');
            debugPrint('[AuthProvider] /protected/me: ${response.data}');
            _user = response.data['user'];
            // Envoyer le token FCM après connexion réussie
            await _sendFcmTokenToBackend();
            if (_user != null && _user!['role'] != null) {
              final role = stringToUserRole(_user!['role']);
              if (role != null) {
                debugPrint('[AuthProvider] setRole: $role');
                UserService().setRole(role);
              } else {
                debugPrint('[AuthProvider] clearRole (role null)');
                UserService().clearRole();
              }
            }
          } catch (e) {
            debugPrint(
              '[AuthProvider] Erreur lors de la récupération du user: $e',
            );
            if (e is DioError) {
              debugPrint(
                '[AuthProvider] DioError: ${e.response?.statusCode} - ${e.response?.data}',
              );
            }
            _user = null;
            debugPrint('[AuthProvider] clearRole (catch)');
            UserService().clearRole();
          } finally {
            _loading = false;
            debugPrint('[AuthProvider] _loading: $_loading, _user: $_user');
            notifyListeners();
          }
        } catch (e) {
          // Erreur de configuration Dio ou autre
          debugPrint('[AuthProvider] Erreur globale: $e');
          _user = null;
          UserService().clearRole();
          _loading = false;
          notifyListeners();
        }
      } else {
        debugPrint('[AuthProvider] Utilisateur Firebase null, clearRole');
        _token = null;
        _user = null;
        UserService().clearRole();
        _loading = false;
        debugPrint('[AuthProvider] _loading: $_loading, _user: $_user');
        notifyListeners();
      }
    });
  }

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
    _loading = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _token = null;
    _user = null;
    UserService().clearRole();
    notifyListeners();
  }

  // Ajout : méthode pour forcer le rechargement de l'utilisateur
  Future<void> reloadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    _loading = true;
    notifyListeners();
    if (firebaseUser != null) {
      final idToken = await firebaseUser.getIdToken();
      _token = idToken;
      try {
<<<<<<< HEAD
        final String baseUrl = 'https://api.tranoo.store/api';

        // final String baseUrl =
        //     kIsWeb
        //         ? 'http://localhost:5000/api'
        //         : (Platform.isAndroid &&
        //                 !Platform.isFuchsia &&
        //                 !isPhysicalDevice()
        //             ? 'http://10.0.2.2:5000/api'
        //             : 'http://192.168.100.21:5000/api');
=======
        final String baseUrl =
            kIsWeb
                ? 'http://localhost:5000/api'
                : (Platform.isAndroid &&
                        !Platform.isFuchsia &&
                        !isPhysicalDevice()
                    ? 'http://10.0.2.2:5000/api'
                    : 'http://192.168.100.21:5000/api');
>>>>>>> 4f4bd90b735a4682a406fe615c5da8ce3a99aa9d
        final dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {'Authorization': 'Bearer $idToken'},
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        final response = await dio.get('/protected/me');
        _user = response.data['user'];
        await _sendFcmTokenToBackend();
        if (_user != null && _user!['role'] != null) {
          final role = stringToUserRole(_user!['role']);
          if (role != null) {
            UserService().setRole(role);
          } else {
            UserService().clearRole();
          }
        }
      } catch (e) {
        _user = null;
        UserService().clearRole();
      } finally {
        _loading = false;
        notifyListeners();
      }
    } else {
      _token = null;
      _user = null;
      UserService().clearRole();
      _loading = false;
      notifyListeners();
    }
  }
}

bool isPhysicalDevice() {
  try {
    return Platform.isAndroid || Platform.isIOS;
  } catch (_) {
    return false;
  }
}
