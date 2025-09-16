import 'package:flutter/material.dart';
import 'discussion.dart';
<<<<<<< HEAD

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de données statiques pour les rooms
    final List<Map<String, dynamic>> rooms = [
      {
        'participantName': 'Transitaire Jean',
        'participantPhoto': 'assets/images/jenifer.jpg',
        'articleTitle': 'Tesla Model 3',
        'articlePhoto': 'assets/images/car.png',
        'lastMessage': 'Merci, j\'attends votre retour.',
        'date': '12:30',
      },
      {
        'participantName': 'Vendeur Alice',
        'participantPhoto': 'assets/images/jenijeni/1 (2).png',
        'articleTitle': 'Disque de frein',
        'articlePhoto': 'assets/images/image1.png',
        'lastMessage': 'La pièce est disponible.',
        'date': 'Hier',
      },
    ];

=======
import '../../services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Récupérer l'ID de l'utilisateur actuel
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUserId = user.uid;
      }

      // Récupérer les rooms depuis le backend
      final roomsData = await _chatService.getUserRooms();

      if (mounted) {
        setState(() {
          rooms = roomsData;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des rooms: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Formater la date pour l'affichage
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}j';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}min';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      return 'Récent';
    }
  }

  // Obtenir le dernier message
  String _getLastMessage(Map<String, dynamic> room) {
    final messages = room['messages'] as List<dynamic>?;
    print('DEBUG: Messages dans la room: ${messages?.length ?? 0}');
    if (messages != null && messages.isNotEmpty) {
      final lastMessage = messages.last;
      print('DEBUG: Dernier message: ${lastMessage['content']}');
      return lastMessage['content'] ?? 'Aucun message';
    }
    return 'Aucun message';
  }

  // Obtenir l'heure du dernier message
  String _getLastMessageTime(Map<String, dynamic> room) {
    final messages = room['messages'] as List<dynamic>?;
    if (messages != null && messages.isNotEmpty) {
      final lastMessage = messages.last;
      final dateString =
          lastMessage['createdAt'] ??
          room['updatedAt'] ??
          room['createdAt'] ??
          '';
      return _formatDate(dateString);
    }
    return _formatDate(room['createdAt'] ?? '');
  }

  // Obtenir le nom de l'autre participant
  String _getOtherParticipantName(Map<String, dynamic> room) {
    final participants = room['participants'] as List<dynamic>?;
    if (participants == null || participants.isEmpty) return 'Inconnu';

    for (final participant in participants) {
      if (participant['_id'] != currentUserId) {
        return '${participant['prenoms'] ?? ''} ${participant['nom'] ?? ''}'
            .trim();
      }
    }
    return 'Inconnu';
  }

  // Obtenir la photo de l'autre participant
  String _getOtherParticipantPhoto(Map<String, dynamic> room) {
    final participants = room['participants'] as List<dynamic>?;
    if (participants == null || participants.isEmpty)
      return 'assets/images/jenifer.jpg';

    for (final participant in participants) {
      if (participant['_id'] != currentUserId) {
        // Si le participant a une photo, l'utiliser, sinon image par défaut
        final photo = participant['photo'];
        if (photo != null && photo.isNotEmpty) {
          return photo;
        }
        return 'assets/images/jenifer.jpg';
      }
    }
    return 'assets/images/jenifer.jpg';
  }

  // Obtenir le titre de l'article
  String _getArticleTitle(Map<String, dynamic> room) {
    final article = room['article'] as Map<String, dynamic>?;
    return article?['titre'] ?? 'Article';
  }

  // Obtenir la photo de l'article
  String _getArticlePhoto(Map<String, dynamic> room) {
    final article = room['article'] as Map<String, dynamic>?;
    final photos = article?['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      return photos.first;
    }
    return 'assets/images/car.png';
  }

  // Vérifier si le chat a des messages non lus
  bool _hasUnreadMessages(Map<String, dynamic> room) {
    final messages = room['messages'] as List<dynamic>?;
    if (messages == null || messages.isEmpty) return false;

    // Vérifier s'il y a des messages non lus (non marqués comme lus par l'utilisateur actuel)
    for (final message in messages) {
      if (message['sender'] != currentUserId &&
          (message['isRead'] == null || message['isRead'] == false)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Discussions'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 1,
<<<<<<< HEAD
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Discussion()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(
                      Colors.amber.r.toInt(),
                      Colors.amber.g.toInt(),
                      Colors.amber.b.toInt(),
                      0.08,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Photo de l'autre participant
                  CircleAvatar(
                    backgroundImage: AssetImage(room['participantPhoto']),
                    radius: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                room['participantName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              room['date'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                room['articlePhoto'],
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                room['articleTitle'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          room['lastMessage'],
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
=======
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRooms),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
              : rooms.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune discussion',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Commencez une discussion avec un vendeur',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadRooms,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Discussion(
                                  roomId: room['_id'],
                                  roomData: room,
                                ),
                          ),
                        ).then((_) {
                          // Recharger les rooms après retour de la discussion
                          _loadRooms();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(
                                Colors.amber.r.toInt(),
                                Colors.amber.g.toInt(),
                                Colors.amber.b.toInt(),
                                0.08,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Photo de l'autre participant
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                _getOtherParticipantPhoto(room),
                              ),
                              radius: 28,
                              onBackgroundImageError: (exception, stackTrace) {
                                // Fallback vers une image locale en cas d'erreur
                              },
                              child:
                                  _getOtherParticipantPhoto(
                                        room,
                                      ).startsWith('http')
                                      ? null
                                      : Image.asset(
                                        _getOtherParticipantPhoto(room),
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              _getOtherParticipantName(room),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (_hasUnreadMessages(room))
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _getLastMessageTime(room),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          _getArticlePhoto(room),
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Image.asset(
                                              'assets/images/car.png',
                                              width: 36,
                                              height: 36,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _getArticleTitle(room),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _getLastMessage(room),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
    );
  }
}
