import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tranoo/data/screens/paymentscreen.dart';

import 'mobilemoneypaymentscreen.dart';

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

  final List<String> voitures = ['Sponsorisée', 'À la une'];
  final List<String> moyensPaiement = ['Paiement bancaire', 'Mobile Money'];

  final ImagePicker picker = ImagePicker();

  Future<void> _pickMedia() async {
    var permissionPhotos = await Permission.photos.request();
    var permissionVideos = await Permission.videos.request();

    if (permissionPhotos.isGranted || permissionVideos.isGranted) {
      final List<XFile> images = await picker.pickMultiImage();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      setState(() {
        _mediaFiles.addAll(images.map((xfile) => File(xfile.path)));
        if (video != null) {
          _mediaFiles.add(File(video.path));
        }
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permission refusée')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: screenWidth * 0.95,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Demande de pub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Type de publicité
                    DropdownButtonFormField<String>(
                      value: _selectedVoiture,
                      items:
                          voitures
                              .map(
                                (voiture) => DropdownMenuItem(
                                  value: voiture,
                                  child: Text(voiture),
                                ),
                              )
                              .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Type de publicité',
                        border: OutlineInputBorder(),
                      ),
                      onChanged:
                          (value) => setState(() => _selectedVoiture = value),
                    ),
                    const SizedBox(height: 30),

                    // Moyen de paiement
                    DropdownButtonFormField<String>(
                      value: _selectedPaiement,
                      items:
                          moyensPaiement
                              .map(
                                (moyen) => DropdownMenuItem(
                                  value: moyen,
                                  child: Text(moyen),
                                ),
                              )
                              .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Moyen de paiement',
                        border: OutlineInputBorder(),
                      ),
                      onChanged:
                          (value) => setState(() => _selectedPaiement = value),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      'Télécharger des images / vidéos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Bouton Ajouter des fichiers
                    if (_mediaFiles.isEmpty)
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
                              Icon(
                                Icons.cloud_upload,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Cliquez pour ajouter des fichiers',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _pickMedia,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter d’autres fichiers'),
                      ),

                    if (_mediaFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        '${_mediaFiles.length} fichier(s) sélectionné(s)',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Affichage vertical avec suppression
                      Column(
                        children:
                            _mediaFiles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              final isImage =
                                  file.path.endsWith('.jpg') ||
                                  file.path.endsWith('.jpeg') ||
                                  file.path.endsWith('.png');

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child:
                                          isImage
                                              ? Image.file(
                                                file,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              )
                                              : Container(
                                                width: double.infinity,
                                                height: 200,
                                                color: Colors.black12,
                                                child: const Icon(
                                                  Icons.videocam,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _mediaFiles.removeAt(index);
                                          });
                                        },
                                        child: const CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.red,
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Bouton Valider
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedPaiement == 'Mobile Money') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const MobileMoneyPaymentScreen(),
                                ),
                              );
                            } else if (_selectedPaiement ==
                                'Paiement bancaire') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight < 600 ? 15 : 15,
                            horizontal: screenWidth < 600 ? 60 : 60,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text(
                          'Valider la demande',
                          style: TextStyle(fontSize: 16),
                        ),
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
