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
import 'package:tranoo/services/blocked_user_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _loading = true;
  final Logger _logger = Logger('AuthProvider');

  /// Invalide les réponses /me obsolètes (évite la race inscription).
  int _meGeneration = 0;

  /// Pendant Firebase create + POST /register, ne pas appeler /me
  /// (le user Mongo n'existe pas encore).
  bool _registrationInProgress = false;

  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;
  bool get registrationInProgress => _registrationInProgress;

  /// À appeler AVANT createUserWithEmailAndPassword.
  void beginRegistration() {
    _registrationInProgress = true;
    _meGeneration++;
    debugPrint(
      '[AuthProvider] beginRegistration (gen=$_meGeneration) — /me ignoré',
    );
  }

  /// Annule le mode inscription (échec register / rollback Firebase).
  void abortRegistration() {
    _registrationInProgress = false;
    debugPrint('[AuthProvider] abortRegistration');
  }

  /// Applique le user renvoyé par POST /register (évite un /me prématuré).
  Future<void> completeRegistration(Map<String, dynamic>? user) async {
    try {
      if (user != null) {
        await _applyUserProfile(user);
        return;
      }
      await reloadUser(maxAttempts: 6);
    } finally {
      _registrationInProgress = false;
      debugPrint('[AuthProvider] completeRegistration done');
    }
  }

  bool _isUserNotFoundError(Object e) {
    if (e is! DioException) return false;
    if (e.response?.statusCode != 401) return false;
    final data = e.response?.data;
    if (data is Map) {
      final code = data['code']?.toString() ?? data['errorCode']?.toString();
      if (code == 'USER_NOT_FOUND') return true;
    }
    return false;
  }

  Future<void> _applyUserProfile(Map<String, dynamic> user) async {
    final gen = ++_meGeneration;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _token = await firebaseUser.getIdToken();
    }
    if (gen != _meGeneration) return;
    final cleaned = Map<String, dynamic>.from(user)..remove('password');
    _user = cleaned;
    await saveUserToPrefs(_token, _user);
    if (_user != null && _user!['role'] != null) {
      final role = stringToUserRole(_user!['role']);
      if (role != null) {
        UserService().setRole(role);
        final vendeurType = _user!['vendeurType']?.toString();
        UserService().setVendeurType(
          vendeurType != null && vendeurType.trim().isNotEmpty
              ? vendeurType.trim()
              : null,
        );
      } else {
        UserService().clearRole();
      }
    }
    _loading = false;
    notifyListeners();
    try {
      await _sendFcmTokenToBackend();
      await ChatService().initializeSocket();
    } catch (e) {
      debugPrint('[AuthProvider] post-apply side effects: $e');
    }
  }

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
      // Pendant l'inscription : Firebase est connecté mais Mongo pas encore
      // créé — ne pas appeler /me (race condition).
      if (firebaseUser != null && _registrationInProgress) {
        _token = await firebaseUser.getIdToken();
        _loading = false;
        notifyListeners();
        debugPrint(
          '[AuthProvider] authStateChanges ignoré (inscription en cours)',
        );
        return;
      }
      // Jamais bloquer l'UI si un profil est déjà affiché (retour app / sync).
      final blockUi = firebaseUser != null && _user == null;
      if (blockUi) {
        _loading = true;
        notifyListeners();
        debugPrint('[AuthProvider] notifyListeners() loading=true (première sync)');
      }
      if (firebaseUser != null) {
        debugPrint(
          '[AuthProvider] Firebase user (avant getIdToken): $firebaseUser',
        );
        final idToken = await firebaseUser.getIdToken();
        debugPrint('[AuthProvider] idToken (avant requête backend): $idToken');
        _token = idToken;
        final gen = ++_meGeneration;
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
            if (gen != _meGeneration || _registrationInProgress) {
              debugPrint(
                '[AuthProvider] /me obsolète ignoré (gen=$gen/$_meGeneration)',
              );
              return;
            }
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
                final vendeurType = _user!['vendeurType']?.toString();
                UserService().setVendeurType(
                  vendeurType != null && vendeurType.trim().isNotEmpty
                      ? vendeurType.trim()
                      : null,
                );
              } else {
                debugPrint('[AuthProvider] clearRole (role null)');
                UserService().clearRole();
              }
            }
          } catch (e) {
            debugPrint(
              '[AuthProvider] Erreur lors de la récupération du user: $e',
            );
            if (gen != _meGeneration || _registrationInProgress) {
              debugPrint('[AuthProvider] erreur /me obsolète ignorée');
              return;
            }
            if (e is DioException) {
              debugPrint(
                '[AuthProvider] DioException: ${e.response?.statusCode} - ${e.response?.data}',
              );

              // Vérifier si l'utilisateur est bloqué
              if (e.response?.statusCode == 403) {
                final data = e.response?.data;
                if (data is Map && data['blocked'] == true) {
                  await _handleBlockedUser(data['message'] ?? 'Compte bloqué');
                  return;
                }
              }

              // USER_NOT_FOUND : souvent la race inscription (Firebase OK, Mongo pas prêt).
              // Ne pas effacer un profil déjà chargé par reloadUser / register.
              if (_isUserNotFoundError(e)) {
                debugPrint(
                  '[AuthProvider] USER_NOT_FOUND — pas de logout forcé',
                );
                if (_user != null) return;
                _loading = false;
                notifyListeners();
                return;
              }
            }
            _user = null;
            await clearUserFromPrefs();
            debugPrint('[AuthProvider] clearRole (catch)');
            UserService().clearRole();
          } finally {
            if (gen == _meGeneration) {
              _loading = false;
              debugPrint('[AuthProvider] _loading: $_loading, _user: $_user');
              notifyListeners();
              debugPrint('[AuthProvider] notifyListeners() après backend');
            }
          }
        } catch (e) {
          debugPrint('[AuthProvider] Erreur globale: $e');
          if (gen != _meGeneration || _registrationInProgress) return;
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
  Future<void> reloadUser({int maxAttempts = 1}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final silent = _user != null;
    if (!silent) {
      _loading = true;
      notifyListeners();
    }
    if (firebaseUser != null) {
      final gen = ++_meGeneration;
      Object? lastError;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        if (gen != _meGeneration) return;
        try {
          final idToken = await firebaseUser.getIdToken();
          _token = idToken;
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
          if (gen != _meGeneration) return;
          _user = response.data['user'];
          await saveUserToPrefs(_token, _user);
          await _sendFcmTokenToBackend();
          if (_user != null && _user!['role'] != null) {
            final role = stringToUserRole(_user!['role']);
            if (role != null) {
              UserService().setRole(role);
              final vendeurType = _user!['vendeurType']?.toString();
              UserService().setVendeurType(
                vendeurType != null && vendeurType.trim().isNotEmpty
                    ? vendeurType.trim()
                    : null,
              );
            } else {
              UserService().clearRole();
            }
          }
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
          if (e is DioException && e.response?.statusCode == 403) {
            final data = e.response?.data;
            if (data is Map && data['blocked'] == true) {
              await _handleBlockedUser(data['message'] ?? 'Compte bloqué');
              return;
            }
          }
          // Retry si Mongo pas encore prêt juste après inscription.
          if (_isUserNotFoundError(e) && attempt < maxAttempts) {
            debugPrint(
              '[AuthProvider] reloadUser USER_NOT_FOUND attempt $attempt/$maxAttempts',
            );
            await Future.delayed(Duration(milliseconds: 200 * attempt));
            continue;
          }
          if (gen != _meGeneration) return;
          // Ne pas écraser un profil déjà présent (réponse /me tardive en échec).
          if (_user == null) {
            UserService().clearRole();
          }
        }
      }
      if (lastError != null && _user == null && gen == _meGeneration) {
        debugPrint('[AuthProvider] reloadUser échec: $lastError');
      }
      if (gen == _meGeneration) {
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

  // Gestion des utilisateurs bloqués
  Future<void> _handleBlockedUser(String message) async {
    try {
      // Déconnexion complète
      await FirebaseAuth.instance.signOut();
      await clearUserFromPrefs();
      
      _token = null;
      _user = null;
      _loading = false;
      
      UserService().clearRole();
      ChatService().disconnect();
      
      notifyListeners();
      
      // Afficher le dialogue de blocage
      BlockedUserService.showBlockedDialog(message);
    } catch (e) {
      debugPrint('Erreur lors de la gestion de l\'utilisateur bloqué: $e');
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