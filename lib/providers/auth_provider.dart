import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';
// import 'package:flutter/foundation.dart' show kIsWeb; // unused
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:tranoo/services/chat_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _loading = true;
  final Logger _logger = Logger('AuthProvider');

  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;

  AuthProvider() {
    debugPrint('[AuthProvider] CONSTRUCTEUR appelé');
    _init();
  }

  // --- PERSISTENCE SHARED PREFERENCES ---
  static Future<void> saveUserToPrefs(
    String? token,
    Map<String, dynamic>? user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      debugPrint('[AuthProvider] Sauvegarde token dans SharedPreferences');
      await prefs.setString(_tokenKey, token);
    }
    if (user != null) {
      debugPrint('[AuthProvider] Sauvegarde user dans SharedPreferences');
      await prefs.setString(_userKey, jsonEncode(user));
    }
  }

  static Future<void> clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('[AuthProvider] Suppression user/token du cache');
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<Map<String, dynamic>?> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    debugPrint('[AuthProvider] Chargement user du cache: $userStr');
    if (userStr != null) {
      try {
        return jsonDecode(userStr) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('[AuthProvider] Erreur décodage user du cache: $e');
      }
    }
    return null;
  }

  static Future<String?> loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    debugPrint('[AuthProvider] Chargement token du cache: $token');
    return token;
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
        Uri.parse('${getBaseUrl().replaceAll('/api', '')}/api/users/fcm-token'),
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
    debugPrint('[AuthProvider] _init() démarré');
    // 1. Charger d'abord le user/token du cache pour affichage immédiat
    _token = await loadTokenFromPrefs();
    _user = await loadUserFromPrefs();
    debugPrint(
      '[AuthProvider] Après chargement cache: _token=$_token, _user=$_user',
    );
    _loading = false;
    notifyListeners();
    debugPrint('[AuthProvider] notifyListeners() après cache');

    // Initialiser le WebSocket si l'utilisateur est connecté
    if (_user != null) {
      await ChatService().initializeSocket();
    }

    // 2. Ensuite, écouter FirebaseAuth pour les changements d'état
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      debugPrint('[AuthProvider] Firebase user: $firebaseUser');
      _loading = true;
      notifyListeners();
      debugPrint('[AuthProvider] notifyListeners() loading=true');
      if (firebaseUser != null) {
        debugPrint(
          '[AuthProvider] Firebase user (avant getIdToken): $firebaseUser',
        );
        final idToken = await firebaseUser.getIdToken();
        debugPrint('[AuthProvider] idToken (avant requête backend): $idToken');
        _token = idToken;
        try {
          final String baseUrl = getBaseUrl();
          final dio = Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: {'Authorization': 'Bearer $idToken'},
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );
          try {
            debugPrint('[AuthProvider] Appel backend /protected/me');
            final response = await dio.get('/protected/me');
            debugPrint('[AuthProvider] /protected/me: ${response.data}');
            _user = response.data['user'];
            debugPrint('[AuthProvider] _user après /protected/me: \n${_user}');
            await saveUserToPrefs(_token, _user);
            await _sendFcmTokenToBackend();

            // Initialiser le WebSocket après connexion réussie
            await ChatService().initializeSocket();

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
            await clearUserFromPrefs();
            debugPrint('[AuthProvider] clearRole (catch)');
            UserService().clearRole();
          } finally {
            _loading = false;
            debugPrint('[AuthProvider] _loading: $_loading, _user: $_user');
            notifyListeners();
            debugPrint('[AuthProvider] notifyListeners() après backend');
          }
        } catch (e) {
          debugPrint('[AuthProvider] Erreur globale: $e');
          _user = null;
          await clearUserFromPrefs();
          UserService().clearRole();
          _loading = false;
          notifyListeners();
          debugPrint('[AuthProvider] notifyListeners() après erreur globale');
        }
      } else {
        debugPrint('[AuthProvider] Utilisateur Firebase null, clearRole');
        _token = null;
        _user = null;
        await clearUserFromPrefs();
        UserService().clearRole();

        // Déconnecter le WebSocket
        ChatService().disconnect();

        _loading = false;
        debugPrint('[AuthProvider] _loading: $_loading, _user: $_user');
        notifyListeners();
        debugPrint('[AuthProvider] notifyListeners() après déconnexion');
      }
    });
  }

  Future<void> login(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
    _token = token;
    _user = user;
    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _token = null;
    _user = null;
    await clearUserFromPrefs();
    UserService().clearRole();

    // Déconnecter le WebSocket
    ChatService().disconnect();

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
        final String baseUrl = getBaseUrl();
        final dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {'Authorization': 'Bearer $idToken'},
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
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
