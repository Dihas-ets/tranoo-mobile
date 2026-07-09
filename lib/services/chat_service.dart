import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'user_service.dart';
import '../config/backend_config.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final UserService _userService = UserService();
  final String _baseUrl = getApiBaseUrl();
  IO.Socket? _socket;
  bool _isConnected = false;

  // Callbacks pour les événements temps réel
  Function(Map<String, dynamic>)? onNewMessage;
  Function(Map<String, dynamic>)? onTypingIndicator;
  Function(String)? onUserOnline;
  Function(String)? onUserOffline;

  // Initialiser la connexion WebSocket
  Future<void> initializeSocket() async {
    if (_socket != null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();

      _socket = IO.io(_baseUrl.replaceAll('/api', ''), <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
      });

      _setupSocketListeners();
      _socket!.connect();

      print('[ChatService] Tentative de connexion WebSocket...');
    } catch (e) {
      print('[ChatService] Erreur lors de l\'initialisation WebSocket: $e');
    }
  }

  void _setupSocketListeners() {
    _socket!.onConnect((_) {
      print('[ChatService] WebSocket connecté');
      _isConnected = true;
      _authenticateSocket();
    });

    _socket!.onDisconnect((_) {
      print('[ChatService] WebSocket déconnecté');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('[ChatService] Erreur de connexion WebSocket: $error');
    });

    // Écouter les nouveaux messages
    _socket!.on('new-message', (data) {
      print('[ChatService] Nouveau message reçu: $data');
      if (onNewMessage != null) {
        onNewMessage!(data);
      }
    });

    // Écouter les typing indicators
    _socket!.on('typing-indicator', (data) {
      print('[ChatService] Typing indicator: $data');
      if (onTypingIndicator != null) {
        onTypingIndicator!(data);
      }
    });

    // Écouter les changements de statut utilisateur
    _socket!.on('user-online', (data) {
      print('[ChatService] Utilisateur en ligne: $data');
      if (onUserOnline != null) {
        onUserOnline!(data['userId']);
      }
    });

    _socket!.on('user-offline', (data) {
      print('[ChatService] Utilisateur hors ligne: $data');
      if (onUserOffline != null) {
        onUserOffline!(data['userId']);
      }
    });
  }

  Future<void> _authenticateSocket() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        _socket!.emit('authenticate', token);
        print('[ChatService] Authentification WebSocket envoyée');
      }
    } catch (e) {
      print('[ChatService] Erreur lors de l\'authentification WebSocket: $e');
    }
  }

  // Rejoindre une room de chat
  void joinRoom(String roomId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join-room', roomId);
      print('[ChatService] Rejoint la room: $roomId');
    }
  }

  // Quitter une room de chat
  void leaveRoom(String roomId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave-room', roomId);
      print('[ChatService] Quitté la room: $roomId');
    }
  }

  // Envoyer un typing indicator
  void sendTypingIndicator(String roomId, bool isTyping) {
    if (_socket != null && _isConnected) {
      if (isTyping) {
        _socket!.emit('typing-start', roomId);
      } else {
        _socket!.emit('typing-stop', roomId);
      }
    }
  }

  // Déconnecter le WebSocket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      print('[ChatService] WebSocket déconnecté');
    }
  }

  bool get isConnected => _isConnected;

  // Récupérer le token d'authentification
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

  // Créer ou récupérer une room de chat
  Future<Map<String, dynamic>?> createOrGetRoom({
    required String user1Id,
    required String user2Id,
    required String articleId,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/room'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user1': user1Id,
          'user2': user2Id,
          'article': articleId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur lors de la création de la room: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la création de la room: $e');
      return null;
    }
  }

  // Récupérer toutes les rooms de l'utilisateur avec leurs messages
  Future<List<Map<String, dynamic>>> getUserRooms() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse('$_baseUrl/chat/rooms'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> rooms = data.cast<Map<String, dynamic>>();

        // Pour chaque room, récupérer les messages
        for (int i = 0; i < rooms.length; i++) {
          try {
            final messagesResponse = await http.get(
              Uri.parse('$_baseUrl/chat/messages/${rooms[i]['_id']}'),
              headers: {'Authorization': 'Bearer $token'},
            );

            if (messagesResponse.statusCode == 200) {
              final List<dynamic> messagesData = jsonDecode(
                messagesResponse.body,
              );
              rooms[i]['messages'] = messagesData;
            } else {
              rooms[i]['messages'] = [];
            }
          } catch (e) {
            print(
              'Erreur lors de la récupération des messages pour la room ${rooms[i]['_id']}: $e',
            );
            rooms[i]['messages'] = [];
          }
        }

        return rooms;
      } else {
        print(
          'Erreur lors de la récupération des rooms: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des rooms: $e');
      return [];
    }
  }

  // Envoyer un message
  Future<Map<String, dynamic>?> sendMessage({
    required String roomId,
    required String content,
    String? fileUrl,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'roomId': roomId,
          'content': content,
          'fileUrl': fileUrl,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Erreur lors de l\'envoi du message: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      return null;
    }
  }

  // Récupérer les messages d'une room
  Future<List<Map<String, dynamic>>> getRoomMessages(String roomId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse('$_baseUrl/chat/messages/$roomId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
          'Erreur lors de la récupération des messages: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des messages: $e');
      return [];
    }
  }

  // Marquer les messages comme lus
  Future<bool> markMessagesAsRead(String roomId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/messages/$roomId/read'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors du marquage des messages: $e');
      return false;
    }
  }

  // Récupérer le nombre de messages non lus
  Future<Map<String, int>> getUnreadCount() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return {};

      final response = await http.get(
        Uri.parse('$_baseUrl/chat/unread-count'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      } else {
        print(
          'Erreur lors de la récupération du nombre de messages non lus: ${response.statusCode}',
        );
        return {};
      }
    } catch (e) {
      print('Erreur lors de la récupération du nombre de messages non lus: $e');
      return {};
    }
  }

  // Obtenir le nombre total de messages non lus
  Future<int> getTotalUnreadCount() async {
    try {
      final unreadCounts = await getUnreadCount();
      int total = 0;
      unreadCounts.forEach((roomId, count) {
        total += count;
      });
      return total;
    } catch (e) {
      print('Erreur lors du calcul du nombre total de messages non lus: $e');
      return 0;
    }
  }

  // Modifier un message
  Future<Map<String, dynamic>?> editMessage({
    required String roomId,
    required String messageId,
    required String newContent,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.put(
        Uri.parse('$_baseUrl/chat/messages/$messageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'content': newContent}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Erreur lors de la modification du message: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Erreur lors de la modification du message: $e');
      return null;
    }
  }

  // Supprimer un message
  Future<bool> deleteMessage(String messageId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/messages/$messageId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la suppression du message: $e');
      return false;
    }
  }

  // Récupérer le statut des participants
  Future<List<Map<String, dynamic>>> getParticipantsStatus(
    String roomId,
  ) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse('$_baseUrl/chat/rooms/$roomId/participants-status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
          'Erreur lors de la récupération du statut des participants: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération du statut des participants: $e');
      return [];
    }
  }

  // Rechercher dans les messages
  Future<Map<String, dynamic>?> searchMessages({
    required String roomId,
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/chat/messages/$roomId/search?query=$query&limit=$limit&skip=$skip',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur lors de la recherche: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return null;
    }
  }
}
