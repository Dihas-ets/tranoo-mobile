import 'package:file_picker/file_picker.dart'; // Pour la sélection de fichiers
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour la sélection d'image
import '../../services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/l10n/app_localizations.dart';

class Discussion extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> roomData;
  final VoidCallback? onBack;

  const Discussion({
    super.key,
    required this.roomId,
    required this.roomData,
    this.onBack,
  });

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();

  String? currentUserId;
  bool isLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Récupérer l'ID Mongo (_id) de l'utilisateur actuel
      final auth = Provider.of<myauth.AuthProvider>(context, listen: false);
      currentUserId = auth.user?['_id']?.toString();

      // Marquer les messages comme lus
      await _chatService.markMessagesAsRead(widget.roomId);

      // Charger les messages
      await _loadMessages();

      // Configurer les callbacks WebSocket
      _chatService.onNewMessage = (data) {
        if (data['roomId'] == widget.roomId) {
          _loadMessages(); // Recharger les messages
        }
      };

      _chatService.onTypingIndicator = (data) {
        if (data['roomId'] == widget.roomId) {
          // Gérer l'affichage du typing indicator
          setState(() {
            // Tu peux ajouter une variable pour afficher "X est en train d'écrire..."
          });
        }
      };

      // Rejoindre la room WebSocket
      _chatService.joinRoom(widget.roomId);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation du chat: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Quitter la room WebSocket
    _chatService.leaveRoom(widget.roomId);
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messagesData = await _chatService.getRoomMessages(widget.roomId);

      if (mounted) {
        setState(() {
          messages.clear();
          messages.addAll(messagesData);
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des messages: $e');
    }
  }

  // Fonction pour envoyer un message texte
  Future<void> sendMessage() async {
    if (_messageController.text.isNotEmpty && !isSending) {
      setState(() {
        isSending = true;
      });

      try {
        final message = await _chatService.sendMessage(
          roomId: widget.roomId,
          content: _messageController.text,
        );

        if (message != null) {
          _messageController.clear();
          // Pas besoin de recharger car le WebSocket va recevoir le nouveau message
        }
      } catch (e) {
        print('Erreur lors de l\'envoi du message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'envoi du message'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            isSending = false;
          });
        }
      }
    }
  }

  // Fonction pour envoyer une image
  Future<void> sendImage(XFile image) async {
    setState(() {
      isSending = true;
    });

    try {
      // TODO: Upload image to cloud storage and get URL
      // Pour l'instant, on simule
      final message = await _chatService.sendMessage(
        roomId: widget.roomId,
        content: 'Image envoyée',
        fileUrl: image.path, // Remplacer par l'URL après upload
      );

      if (message != null) {
        await _loadMessages();
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi de l\'image'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // Fonction pour envoyer un document
  Future<void> sendDocument() async {
    setState(() {
      isSending = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        String filePath = result.files.single.path!;

        // TODO: Upload file to cloud storage and get URL
        final message = await _chatService.sendMessage(
          roomId: widget.roomId,
          content: 'Document envoyé',
          fileUrl: filePath, // Remplacer par l'URL après upload
        );

        if (message != null) {
          await _loadMessages();
        }
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi du document'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // Fonction pour sélectionner une image
  Future<void> pickImage() async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await sendImage(image);
      }
    } catch (e) {
      print('Erreur lors de la sélection d\'image: $e');
    }
  }

  // Fonction pour gérer les changements de texte (typing indicator)
  void _onTextChanged(String text) {
    // TODO: Implémenter le typing indicator
    // _chatService.sendTypingIndicator(widget.roomId, text.isNotEmpty);
  }

  // Formater l'heure du message
  String _formatMessageTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inHours > 0) {
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}min';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      return 'Récent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF0F0F0); // Fond WhatsApp-like
    final accentColor = const Color(0xFFF8BF13); // Amber
    final bubbleColorMe = const Color(0xFFF8BF13); // Amber pour mes messages
    final bubbleColorOther = Colors.white; // Blanc pour les autres
    final textColorMe = Colors.black87;
    final textColorOther = Colors.black87;
    final borderRadiusMe = const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(4),
    );
    final borderRadiusOther = const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomRight: Radius.circular(4),
    );
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: accentColor,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  _getOtherParticipantPhoto() != null
                      ? NetworkImage(_getOtherParticipantPhoto()!)
                      : null,
              child:
                  _getOtherParticipantPhoto() == null
                      ? const Icon(Icons.person, color: Colors.black)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getOtherParticipantName(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _getArticleTitle(),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF8BF13),
                      ),
                    )
                    : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[messages.length - 1 - index];
                        final isMe = msg['sender']?['_id'] == currentUserId;
                        final avatarUrl = msg['sender']?['photo'];
                        return Container(
                          margin: EdgeInsets.only(
                            top: 4,
                            bottom: 4,
                            left: isMe ? 80 : 12,
                            right: isMe ? 12 : 80,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage:
                                        avatarUrl != null &&
                                                avatarUrl.isNotEmpty
                                            ? NetworkImage(avatarUrl)
                                            : null,
                                    child:
                                        avatarUrl == null || avatarUrl.isEmpty
                                            ? const Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.black,
                                            )
                                            : null,
                                  ),
                                ),
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                        0.75,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe ? bubbleColorMe : bubbleColorOther,
                                    borderRadius:
                                        isMe
                                            ? borderRadiusMe
                                            : borderRadiusOther,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (msg['fileUrl'] != null &&
                                          msg['fileUrl'].toString().isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: _buildFilePreview(
                                            msg['fileUrl'],
                                          ),
                                        ),
                                      Text(
                                        msg['content'] ?? '',
                                        style: TextStyle(
                                          color:
                                              isMe
                                                  ? textColorMe
                                                  : textColorOther,
                                          fontSize: 15,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          _formatMessageTime(
                                            msg['createdAt'] ?? '',
                                          ),
                                          style: TextStyle(
                                            color:
                                                isMe
                                                    ? Colors.black54
                                                    : Colors.grey[600],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isMe) const SizedBox(width: 8),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: isSending ? null : sendDocument,
                  color: accentColor,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: isSending ? null : pickImage,
                  color: accentColor,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Tapez votre message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      enabled: !isSending,
                      onChanged: _onTextChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: accentColor,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: isSending ? null : sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getOtherParticipantPhoto() {
    final participants = widget.roomData['participants'] as List<dynamic>?;
    if (participants == null || participants.isEmpty) return null;
    for (final participant in participants) {
      if (participant['_id'] != currentUserId) {
        return participant['photo'] as String?;
      }
    }
    return null;
  }

  Widget _buildFilePreview(String fileUrl) {
    if (fileUrl.endsWith('.jpg') ||
        fileUrl.endsWith('.jpeg') ||
        fileUrl.endsWith('.png')) {
      return GestureDetector(
        onTap: () => _showImagePreview(fileUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              fileUrl.startsWith('http')
                  ? Image.network(
                    fileUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  )
                  : Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
        ),
      );
    } else if (fileUrl.endsWith('.pdf')) {
      return GestureDetector(
        onTap: () => _openPdf(fileUrl),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red[700]),
              const SizedBox(width: 8),
              const Text('PDF', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _downloadFile(fileUrl),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_present, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                'Document',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageUrl.startsWith('http')
                  ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  )
                  : Image.asset(imageUrl, fit: BoxFit.cover),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openPdf(String pdfUrl) async {
    try {
      final Uri url = Uri.parse(pdfUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture du PDF: $e');
    }
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      final Uri url = Uri.parse(fileUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      print('Erreur lors du téléchargement du fichier: $e');
    }
  }

  String _getOtherParticipantName() {
    final participants = widget.roomData['participants'] as List<dynamic>?;
    if (participants == null || participants.isEmpty) return 'Inconnu';
    for (final participant in participants) {
      if (participant['_id'] != currentUserId) {
        return '${participant['prenoms'] ?? ''} ${participant['nom'] ?? ''}'
            .trim();
      }
    }
    return 'Inconnu';
  }

  String _getArticleTitle() {
    if (widget.roomData['contextType'] == 'tricycle') {
      return AppLocalizations.of(context)?.service_tricycle ?? 'Tricycle';
    }
    final article = widget.roomData['article'] as Map<String, dynamic>?;
    return article?['titre'] ?? 'Article';
  }
}