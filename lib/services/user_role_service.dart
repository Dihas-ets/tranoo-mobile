import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../config/backend_config.dart';

/// Service pour récupérer et gérer les rôles utilisateurs depuis le backend
class UserRoleService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: getApiBaseUrl(),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Rôles disponibles dans le système (selon le backend)
  static const List<String> availableRoles = [
    'vendeur',
    'acheteur', 
    'transitaire',
    'admin',
    'chauffeur',
    'livreur',
    'agentCommercial',
  ];

  /// Obtenir le rôle de l'utilisateur depuis le backend
  static Future<String?> getUserRole() async {
    try {
      developer.log('=== DÉBUT RÉCUPÉRATION RÔLE UTILISATEUR ===');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        developer.log('❌ Utilisateur non connecté');
        return null;
      }

      developer.log('Utilisateur connecté: ${user.uid}');
      developer.log('Email: ${user.email}');

      // Récupérer le token Firebase
      final token = await user.getIdToken();
      developer.log('Token Firebase obtenu');

      // Ajouter le token aux headers
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Appeler l'endpoint pour récupérer le profil utilisateur
      developer.log('URL de la requête: ${getApiBaseUrl()}/users/me');
      
      final response = await _dio.get('/users/me');
      developer.log('Statut réponse: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final userData = response.data;
        developer.log('Données utilisateur reçues: $userData');
        
        // Récupérer le rôle depuis les données
        String? role = userData['role'];
        
        // Vérifier aussi si le rôle est dans user (structure différente possible)
        role ??= userData['user']?['role'];
        
        if (role != null && availableRoles.contains(role)) {
          developer.log('✅ Rôle trouvé: $role');
          return role;
        } else {
          developer.log('⚠️ Rôle non trouvé ou invalide: $role');
          return null;
        }
      } else {
        developer.log('❌ Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      developer.log('❌ Erreur Dio lors de la récupération du rôle: ${e.message}');
      developer.log('Statut: ${e.response?.statusCode}');
      developer.log('Données: ${e.response?.data}');
      return null;
    } catch (e) {
      developer.log('❌ Erreur générale lors de la récupération du rôle: $e');
      return null;
    } finally {
      developer.log('=== FIN RÉCUPÉRATION RÔLE UTILISATEUR ===');
    }
  }

  /// Obtenir le rôle avec fallback sur l'email (pour le développement)
  static Future<String> getUserRoleWithFallback() async {
    // Essayer de récupérer le rôle depuis le backend
    final backendRole = await getUserRole();
    if (backendRole != null) {
      return backendRole;
    }

    // Fallback sur l'email pour le développement
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email ?? '';
      developer.log('Fallback sur l\'email pour déterminer le rôle: $email');
      
      if (email.contains('acheteur') || email.contains('buyer')) {
        return 'acheteur';
      } else if (email.contains('vendeur') || email.contains('seller')) {
        return 'vendeur';
      } else if (email.contains('admin')) {
        return 'admin';
      } else if (email.contains('chauffeur')) {
        return 'chauffeur';
      } else if (email.contains('livreur')) {
        return 'livreur';
      } else if (email.contains('transitaire')) {
        return 'transitaire';
      } else if (email.contains('agent')) {
        return 'agentCommercial';
      }
    }

    // Par défaut, retourner acheteur pour Tranoo
    return 'acheteur';
  }

  /// Vérifier si l'utilisateur peut accéder à Tranoo app (acheteur uniquement)
  static Future<bool> canAccessTranooApp() async {
    final role = await getUserRoleWithFallback();
    return role == 'acheteur';
  }

  /// Vérifier si l'utilisateur peut accéder à Tranoo Pro (tous sauf acheteurs)
  static Future<bool> canAccessTranooPro() async {
    final role = await getUserRoleWithFallback();
    return role != 'acheteur';
  }

  /// Obtenir le nom d'affichage du rôle
  static String getRoleDisplayName(String role) {
    switch (role) {
      case 'acheteur':
        return 'Acheteur';
      case 'vendeur':
        return 'Vendeur';
      case 'transitaire':
        return 'Transitaire';
      case 'admin':
        return 'Administrateur';
      case 'chauffeur':
        return 'Chauffeur';
      case 'livreur':
        return 'Livreur';
      case 'agentCommercial':
        return 'Agent Commercial';
      default:
        return role;
    }
  }
}
