import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'succes.dart'; // Assurez-vous que ce chemin est correct

class PayementScreen extends StatefulWidget {
  const PayementScreen({Key? key}) : super(key: key);

  @override
  State<PayementScreen> createState() => _PayementScreenState();
}

class _PayementScreenState extends State<PayementScreen> {
  String? selectedPiece;
  TextEditingController numeroController = TextEditingController(text: '245678399');
  String? selectedChauffeur;
  String? selectedTransitaire;
  File? uploadedImage;
  String? uploadedFileName;
  bool hasUploadedFile = false; // Added to track if a file has been uploaded

  final List<String> pieces = ['Carte d\'identité', 'Passeport', 'Permis de conduire'];
  final List<String> chauffeurs = ['Chauffeur 1', 'Chauffeur 2', 'Chauffeur 3'];
  final List<String> transitaires = ['Transitaire 1', 'Transitaire 2', 'Transitaire 3'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        uploadedImage = File(image.path);
        uploadedFileName = image.name;
        hasUploadedFile = true; // Update hasUploadedFile
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Informations supplémentaires',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // Action de partage
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pièce
                    _buildLabel('Pièce'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedPiece,
                      hint: 'Choisissez votre pièce',
                      items: pieces,
                      onChanged: (value) => setState(() => selectedPiece = value),
                    ),
                    const SizedBox(height: 24),

                    // Numéro de la pièce
                    _buildLabel('Numéro de la pièce'),
                    const SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width * 1, // Réduit la largeur
                      child: TextField(
                        controller: numeroController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Choix du Chauffeur
                    _buildLabel('Choix du Chauffeur'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedChauffeur,
                      hint: 'Choisissez votre chauffeur',
                      items: chauffeurs,
                      onChanged: (value) => setState(() => selectedChauffeur = value),
                    ),
                    const SizedBox(height: 24),

                    // Choix du transitaire
                    _buildLabel('Choix du transitaire'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedTransitaire,
                      hint: 'Choisissez votre transitaire',
                      items: transitaires,
                      onChanged: (value) => setState(() => selectedTransitaire = value),
                    ),
                    const SizedBox(height: 24),

                    // Télécharger des images
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Télécharger des images',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fichier téléchargé
                    if (hasUploadedFile)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              uploadedFileName!,
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            Stack(
                              children: [
                                const Icon(Icons.image, size: 24),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _buildPaymentButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SuccesScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text('Payement', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      ),
    );
  }
}

