import 'dart:io'; // Pour utiliser File

import 'package:file_picker/file_picker.dart'; // Pour la sélection de fichiers
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour la sélection d'image

class Discussion extends StatefulWidget {
  final VoidCallback? onBack;
  const Discussion({super.key, this.onBack});

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ImagePicker _picker = ImagePicker();

  String currentUser = 'transitaire'; // utilisateur actuel (transitaire)

  // Fonction pour envoyer un message texte
  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add({
          'author': currentUser,
          'type': 'text',
          'content': _messageController.text,
        });
        _messageController.clear();

        simulateReply(); // Réponse automatique (statique)
      });
    }
  }

  // Fonction pour envoyer une image
  void sendImage(XFile image) {
    setState(() {
      messages.add({
        'author': currentUser,
        'type': 'image',
        'content': image.path,
      });

      simulateReply(); // Réponse automatique (statique)
    });
  }

  // Fonction pour envoyer un document (choisir un fichier PDF)
  void sendDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;

      setState(() {
        messages.add({
          'author': currentUser,
          'type': 'document',
          'content': filePath,
        });

        simulateReply(); // Réponse automatique (statique)
      });
    }
  }

  // Fonction de réponse automatique (statique)
  void simulateReply() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add({
          'author': 'vendeur',
          'type': 'text',
          'content': 'Ok, message reçu !',
        });
      });
    });
  }

  // Fonction pour choisir une image
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      sendImage(pickedFile);
    }
  }

  @override
  void initState() {
    super.initState();

    // Messages statiques lors de l'initialisation
    messages.addAll([
      {
        'author': 'vendeur',
        'type': 'text',
        'content': 'Bonjour, comment puis-je vous aider ?',
      },
      {
        'author': 'transitaire',
        'type': 'text',
        'content': 'Bonjour, je cherche des informations sur le transport.',
      },
      {
        'author': 'vendeur',
        'type': 'text',
        'content': 'D\'accord, voici ce que nous proposons.',
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/jenifer.jpg'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Vendeur', style: TextStyle(fontSize: 16)),
                Text(
                  'En ligne',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/images/care.png', // Remplacez par le chemin de votre image
              fit: BoxFit.cover,
            ),
          ),

          // Contenu de la discussion
          Column(
            children: [
              // Liste des messages
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['author'] == 'transitaire';

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.amber[200] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft:
                                isMe ? const Radius.circular(12) : Radius.zero,
                            bottomRight:
                                isMe ? Radius.zero : const Radius.circular(12),
                          ),
                          border: Border.all(
                            color: Colors.grey.withOpacity(
                              0.5,
                            ), // Bordure grise
                          ),
                        ),
                        child:
                            message['type'] == 'text'
                                ? Text(
                                  message['content'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isMe ? Colors.black : Colors.black87,
                                  ),
                                )
                                : message['type'] == 'image'
                                ? Image.file(
                                  File(message['content']),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.insert_drive_file,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Document',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                      ),
                    );
                  },
                ),
              ),

              // Barre d'entrée de message
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    // Icône pour la galerie
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.amber),
                      onPressed: pickImage,
                    ),

                    // Icône pour envoyer un document
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.amber),
                      onPressed: sendDocument,
                    ),

                    // Champ de texte pour le message
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Écrire un message...',
                        ),
                      ),
                    ),

                    // Icône pour envoyer le message
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.amber),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
