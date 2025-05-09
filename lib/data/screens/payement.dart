import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'succes.dart'; // Assurez-vous que ce chemin est correct
import 'finalisation_achat.dart';

class PayementScreen extends StatefulWidget {
  const PayementScreen({Key? key}) : super(key: key);

  @override
  State<PayementScreen> createState() => _PayementScreenState();
}

class _PayementScreenState extends State<PayementScreen> with SingleTickerProviderStateMixin {
  String? selectedPiece;
  TextEditingController numeroController = TextEditingController(text: null);
  String? selectedTransitaire;
  File? uploadedImage;
  String? uploadedFileName;
  bool hasUploadedFile = false;

  bool isCarburantChecked = false;
  bool isChauffeurChecked = false;
  bool isFraisDeRouteChecked = false;

  late AnimationController _animationController;

  final List<String> pieces = ['Copie de la Carte d\'identité', 'Permis de conduire', 'Passeport'];

  final List<Map<String, String>> transitaires = [
    {'name': 'Transitaire 1', 'price': '50,000 f'},
    {'name': 'Transitaire 2', 'price': '60,000 f'},
    {'name': 'Transitaire 3', 'price': '70,000 f'},
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        uploadedImage = File(image.path);
        uploadedFileName = image.name;
        hasUploadedFile = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                      hint: 'Copie de la Carte d\'identité',
                      items: pieces,
                      onChanged: (value) => setState(() => selectedPiece = value),
                    ),
                    const SizedBox(height: 24),

                    // Numéro de la pièce
                    _buildLabel('Numéro de la pièce'),
                    const SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
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
                          hintText: '245678399',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Choix du transitaire
                    _buildLabel('Choix du transitaire'),
                    const SizedBox(height: 8),
                    _buildTransitaireDropdown(),
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
                            const Icon(Icons.image, size: 24),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Processus d'achat nécessaires
                    _buildLabel('Processus d\'achat nécessaires'),
                    const SizedBox(height: 8),
                    _buildCheckbox('Carburant', isCarburantChecked, (value) {
                      setState(() {
                        isCarburantChecked = value!;
                      });
                    }),
                    _buildCheckbox('Chauffeur', isChauffeurChecked, (value) {
                      setState(() {
                        isChauffeurChecked = value!;
                      });
                    }),
                    _buildCheckbox('Frais de route', isFraisDeRouteChecked, (value) {
                      setState(() {
                        isFraisDeRouteChecked = value!;
                      });
                    }),
                    const SizedBox(height: 16),

                    // Note
                    const Text(
                      'NB: Pour le service d\'entretien veuillez cliquer sur le bouton ci-dessous.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Bouton clignotant avec animation en utilisant FadeTransition
                    // et AnimationController
                    Center(
                      child: FadeTransition(
                        opacity: _animationController,
                        child: ElevatedButton(
                          onPressed: () {
                            // Action pour contacter le service d'entretien
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Contacter le service entretien',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
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

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.amber,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
      ],
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

  Widget _buildTransitaireDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTransitaire,
          hint: const Text(
            'Choisissez votre transitaire',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          isExpanded: true,
          items: transitaires.map((transitaire) {
            return DropdownMenuItem<String>(
              value: transitaire['name'],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(transitaire['name']!), // Nom du transitaire
                  Text(
                    transitaire['price']!, // Prix du transitaire
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedTransitaire = value),
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
          if (isCarburantChecked && isChauffeurChecked && isFraisDeRouteChecked) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FinalisationAchatScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez cocher toutes les cases avant de continuer.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text('Valider pour finaliser', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      ),
    );
  }
}