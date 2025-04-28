import 'dart:io'; // Pour utiliser File

import 'package:file_picker/file_picker.dart'; // Pour la sélection de fichiers
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour la sélection d'image

class Discussion extends StatefulWidget {
  const Discussion({super.key});

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
    // Demander à l'utilisateur de sélectionner un fichier PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // Si un fichier est sélectionné
      String filePath = result.files.single.path!;

      setState(() {
        messages.add({
          'author': currentUser,
          'type': 'document',
          'content': filePath, // Ajouter le chemin du fichier sélectionné
        });

        simulateReply(); // Réponse automatique (statique)
      });
    } else {
      // Si aucun fichier n'est sélectionné, afficher un message
      print('Aucun fichier sélectionné');
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
      body: Column(
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
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          isMe
                              ? Colors.orange[200]
                              : Colors.grey[300], // Orange pour le transitaire
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        message['type'] == 'text'
                            ? Text(
                              message['content'],
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isMe
                                        ? Colors.white
                                        : Colors
                                            .black, // Texte blanc pour transitaire
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
                                  message['content'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Icône pour la galerie (orange)
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.orange),
                  onPressed: pickImage,
                ),

                // Icône pour envoyer un document (orange)
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.orange),
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
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
