import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'succes5.dart';

class Une extends StatefulWidget {
  const Une({super.key});

  @override
  State<Une> createState() => _UneState();
}

class _UneState extends State<Une> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVoiture;
  String? _selectedPaiement;

  List<File> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> voitures = ['Sponsorisée', 'À la une'];
  final List<String> moyensPaiement = ['Paiement bancaire', 'Mobile Money'];

  Future<void> _pickMedia() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage(); // pour les images

    if (pickedFiles != null) {
      setState(() {
        _mediaFiles = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mettre ma voiture à la une'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 380,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'Demande de pub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Dropdown "Type de publicité"
                    DropdownButtonFormField<String>(
                      value: _selectedVoiture,
                      items: voitures.map((voiture) {
                        return DropdownMenuItem(
                          value: voiture,
                          child: Text(voiture),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Type de publicité',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          setState(() => _selectedVoiture = value),
                    ),

                    const SizedBox(height: 30),

                    // Dropdown "Moyen de paiement"
                    DropdownButtonFormField<String>(
                      value: _selectedPaiement,
                      items: moyensPaiement.map((moyen) {
                        return DropdownMenuItem(
                          value: moyen,
                          child: Text(moyen),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Moyen de paiement',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          setState(() => _selectedPaiement = value),
                    ),

                    const SizedBox(height: 30),

                    // Section Télécharger des images/vidéo
                    const Text(
                      'Télécharger des images / vidéo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Cliquez pour télécharger des images ou vidéos',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_mediaFiles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_mediaFiles.length} fichier(s) sélectionné(s)',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _mediaFiles.map((file) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.file(
                                file,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Bouton de validation
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SuccesScreen5(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        'Valider la demande',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
