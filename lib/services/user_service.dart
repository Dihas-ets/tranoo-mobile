import 'package:flutter/material.dart';
import '../utils/role_redirect.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocked_user_service.dart';
import 'push_otp_service.dart';
import '../config/backend_config.dart';
import '../utils/phone_country_config.dart';

String getBaseUrl() => getApiBaseUrl();

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: getApiBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 403) {
            final data = error.response?.data;
            if (data is Map && data['blocked'] == true) {
              await _handleUserBlocked(data['message'] ?? 'Compte bloqué');
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  UserRole? _currentRole;

  // =============================
  // IMPORTANT : URL DU BACKEND
  // Change uniquement `kUseProdBackend` dans `lib/config/backend_config.dart`
  // ou commente/décommente les lignes proposées dans ce fichier de config.
  // (Plus besoin de modifier toutes les classes/services à la main.)
  // =============================
  late final Dio _dio;

  Dio get dio => _dio;

  UserRole? get currentRole => _currentRole;
  bool get isAcheteur => _currentRole == UserRole.acheteur;

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  // Ancien système WhatsApp OTP supprimé - Remplacé par Push Notifications

  void clearRole() {
    _currentRole = null;
    notifyListeners();
  }

  // Inscription : crée l'utilisateur Firebase, puis l'enregistre dans MongoDB via le backend
  Future<Response> registerUser({
    required String email,
    required String password,
    required String nom,
    required String prenoms,
    required String telephone,
    required String role,
    required String authApp,
    String? fcmToken,
    String? entreprise,
    String? registreCommerce,
    String? numeroIFU,
    String? entrepriseProvenance,
    String? referralCode,
  }) async {
    UserCredential? credential;
    try {
      // 1. Création Firebase Auth
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final idToken = await credential.user!.getIdToken();

      // 2. Appel backend
      final Map<String, dynamic> data = {
        'email': email,
        'nom': nom,
        'prenoms': prenoms,
        'telephone': telephone,
        'role': role.toLowerCase(),
        'authApp': authApp,
        'fcmToken': fcmToken,
      };

      // Ajouter les champs spécifiques selon le rôle
      if (entreprise != null) data['entreprise'] = entreprise;
      if (registreCommerce != null) data['registreCommerce'] = registreCommerce;
      if (numeroIFU != null) data['numeroIFU'] = numeroIFU;
      if (entrepriseProvenance != null)
        data['entrepriseProvenance'] = entrepriseProvenance;
      if (referralCode != null) data['referralCode'] = referralCode;

      final response = await _dio.post(
        '/auth/register',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
      return response;
    } catch (e) {
      // Si l'appel backend échoue après la création Firebase, rollback : suppression du user Firebase
      if (credential != null && credential.user != null) {
        try {
          await credential.user!.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  // Connexion : authentifie avec Firebase, puis récupère le token
  Future<UserCredential> loginWithPhone({
    required String countryCode,
    required String nationalNumber,
    required String password,
    TranooAuthApp app = TranooAuthApp.buyer,
  }) {
    final email = syntheticEmailFromPhone(
      countryCode,
      nationalNumber,
      app: app,
    );
    return loginUser(email: email, password: password);
  }

  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Envoyer le token FCM au backend après connexion
    try {
      final fcmToken = await PushOTPService.getFCMToken();
      if (fcmToken != null) {
        await PushOTPService.sendFCMTokenToBackend(fcmToken);
      }
    } catch (e) {
      print('Erreur envoi FCM token: $e');
      // Ne pas faire échouer la connexion pour une erreur de FCM
    }

    return credential;
  }

  // Gestion des utilisateurs bloqués
  Future<void> _handleUserBlocked(String message) async {
    try {
      // Déconnexion Firebase
      await FirebaseAuth.instance.signOut();

      // Nettoyage SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Nettoyage du rôle
      clearRole();

      // Affichage du dialogue de blocage
      BlockedUserService.showBlockedDialog(message);
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  // Vérification du statut de blocage au démarrage
  Future<bool> checkUserBlockedStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final idToken = await user.getIdToken();
      await _dio.get(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      return false; // Si pas d'erreur, utilisateur non bloqué
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map && data['blocked'] == true) {
          return true; // Utilisateur bloqué
        }
      }
      return false;
    }
  }
}
