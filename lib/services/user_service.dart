import 'package:flutter/material.dart';
import '../utils/role_redirect.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

String getBaseUrl() {
  // Détection automatique selon la plateforme
  if (kIsWeb) {
    return 'http://localhost:5000/api'; //sur web
  } else {
    // Remplace par l'IP de ton PC sur le réseau local
    return 'http://192.168.100.21:5000/api';  //sur mobile
  }
}

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserRole? _currentRole;

  // =============================
  // IMPORTANT : URL du backend
  // - Sur ÉMULATEUR ANDROID : utilisez 'http://10.0.2.2:5000/api'
  // - Sur TÉLÉPHONE PHYSIQUE : utilisez l'IP locale de votre PC, ex : 'http://192.168.1.10:5000/api'
  // - Sur le WEB : 'http://localhost:5000/api' ou l'IP locale
  // - En PRODUCTION : l'URL de votre serveur déployé
  // =============================
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: getBaseUrl(), // Utilise la fonction getBaseUrl()
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Dio get dio => _dio;

  UserRole? get currentRole => _currentRole;
  bool get isTransitaire => _currentRole == UserRole.transitaire;
  bool get isVendeur => _currentRole == UserRole.vendeur;
  bool get isAcheteur => _currentRole == UserRole.acheteur;
  bool get isChauffeur => _currentRole == UserRole.chauffeur;

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

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
    String? fcmToken,
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
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'nom': nom,
          'prenoms': prenoms,
          'telephone': telephone,
          'role': role.toLowerCase(),
          'fcmToken': fcmToken,
        },
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
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  }
}
