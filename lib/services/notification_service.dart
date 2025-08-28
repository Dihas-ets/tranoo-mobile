import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final UserService _userService = UserService();
  final String _baseUrl = getBaseUrl();

  Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  // Récupérer les notifications de l'utilisateur
  Future<Map<String, dynamic>> getUserNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/notifications?page=$page&limit=$limit&unreadOnly=$unreadOnly',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Erreur lors de la récupération des notifications: ${response.statusCode}',
        );
        return {
          'notifications': [],
          'total': 0,
          'unreadCount': 0,
          'hasMore': false,
        };
      }
    } catch (e) {
      print('Erreur lors de la récupération des notifications: $e');
      return {
        'notifications': [],
        'total': 0,
        'unreadCount': 0,
        'hasMore': false,
      };
    }
  }

  // Obtenir le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/unread-count'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unreadCount'] ?? 0;
      } else {
        print(
          'Erreur lors de la récupération du nombre de notifications: ${response.statusCode}',
        );
        return 0;
      }
    } catch (e) {
      print('Erreur lors de la récupération du nombre de notifications: $e');
      return 0;
    }
  }

  // Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors du marquage de la notification: $e');
      return false;
    }
  }

  // Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/mark-all-read'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors du marquage de toutes les notifications: $e');
      return false;
    }
  }

  // Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la suppression de la notification: $e');
      return false;
    }
  }
}

String getBaseUrl() {
  // Retourner l'URL de base de votre API
  // return 'http://10.0.2.2:5000/api'; // Pour l'émulateur Android
  // return 'http://localhost:5000/api'; // Pour le web
  return 'http://192.168.1.75:5000/api'; // Pour un appareil physique
}
