import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'mastervacpage.dart'; // Importez la page MastervacPage
import '../../utils/cloudinary_upload.dart';

class CreateSellPage2 extends StatefulWidget {
  const CreateSellPage2({Key? key}) : super(key: key);

  @override
  CreateSellPage2State createState() => CreateSellPage2State();
}

class CreateSellPage2State extends State<CreateSellPage2> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String? _selectedType; // Gardé en String pour "Rare" et "Normal"
  int? _selectedModel; // Modèle
  // int? _selectedtypes;
  // int? _selectedPortes; // Portes
  // int? _selectedVitesse; // Vitesse
  // int? _selectedCarburant; // Carburant
  // int? _selectedClimatiseur; // Climatiseur
  // int? _selectedDistance; // Distance
  // int? _selectedSieges; // Sièges
  File? _uploadedImage;
  String? _uploadedFileName;
  bool _hasUploadedFile = false;
  String? _cloudinaryUrl;

  final List<String> _types = ['Nouveau ', 'Occasion']; // Reste en String
  final List<String> _fuelTypes = ['Essence', 'Gazoil'];
  final List<String> _models = ['Modèle1', 'Modèle2']; // Modèles
  // final List<int> _portes = [1, 2]; // Portes
  // // final List<int> _vitesses = [1, 2]; // Vitesses
  // final List<int> _carburants = [1, 2]; // Carburants
  // final List<int> _climatiseurs = [1, 2]; // Climatiseurs
  // final List<int> _distances = [1, 2]; // Distances
  // final List<int> _sieges = [1, 2]; // Sièges

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _uploadedImage = File(image.path);
        _uploadedFileName = image.name;
        _hasUploadedFile = true;
      });
      // Upload vers Cloudinary via utilitaire
      final url = await uploadImageToCloudinary(_uploadedImage!);
      if (url != null) {
        setState(() {
          _cloudinaryUrl = url;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 800;
    final isLargeScreen = screenWidth >= 800;

    return Scaffold(
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
                    // Titre
                    _buildLabel(
                      'Nom de la pièce',
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Nom de la pièce',
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Type et Année
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'Type',
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              // Utilisation de MediaQuery pour détecter la taille de l'écran
                              Builder(
                                builder: (context) {
                                  // Récupération de la largeur de l'écran
                                  final screenWidth =
                                      MediaQuery.of(context).size.width;

                                  // Si l'écran est petit (moins de 400px), on utilise Wrap
                                  // Sinon, on utilise Row pour une meilleure performance
                                  if (screenWidth < 400) {
                                    return Wrap(
                                      spacing:
                                          8, // Espacement horizontal entre les éléments
                                      children:
                                          _types.map((type) {
                                            return Row(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min, // Réduit la taille au minimum nécessaire
                                              children: [
                                                Radio<String>(
                                                  value: type,
                                                  groupValue: _selectedType,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedType = value;
                                                    });
                                                  },
                                                  activeColor: Colors.amber,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap, // Réduit la zone de toucher
                                                ),
                                                Text(
                                                  type,
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen
                                                            ? 14
                                                            : isMediumScreen
                                                            ? 16
                                                            : 18, // Ajustement de la taille du texte
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    );
                                  } else {
                                    // Pour les grands écrans, on utilise Row
                                    return Row(
                                      children:
                                          _types.map((type) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 16,
                                              ), // Espacement entre les radio buttons
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Radio<String>(
                                                    value: type,
                                                    groupValue: _selectedType,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedType = value;
                                                      });
                                                    },
                                                    activeColor: Colors.amber,
                                                  ),
                                                  Text(
                                                    type,
                                                    style: TextStyle(
                                                      fontSize:
                                                          isSmallScreen
                                                              ? 14
                                                              : isMediumScreen
                                                              ? 16
                                                              : 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'Année',
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _yearController,
                                decoration: InputDecoration(
                                  hintText: 'Entrer l\'année',
                                  filled: true,
                                  fillColor: const Color(0xFFF2F2F2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Type et Modèle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'Type de moteur',
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: _selectedType,
                                hint: 'Essence',
                                items:
                                    _fuelTypes
                                        .map((e) => e.toString())
                                        .toList(),
                                onChanged:
                                    (value) =>
                                        setState(() => _selectedType = value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'Modèle',
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: _selectedModel?.toString(),
                                hint: 'Choisissez le modèle',
                                items:
                                    _models.map((e) => e.toString()).toList(),
                                onChanged:
                                    (value) => setState(
                                      () => _selectedModel = int.parse(value!),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildLabel(
                      'Caracéristiques',
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                    ),
                    const SizedBox(height: 24),

                    // Emplacement et Prix
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'Emplacement',
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _yearController,
                                decoration: InputDecoration(
                                  hintText: 'Localisation',
                                  filled: true,
                                  fillColor: const Color(0xFFF2F2F2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                'Prix',
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _yearController,
                                decoration: InputDecoration(
                                  hintText: 'Saisir le Prix',
                                  filled: true,
                                  fillColor: const Color(0xFFF2F2F2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    _buildLabel(
                      'Description',
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Entrer une description de votre voiture',
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nom de l'entreprise
                    _buildLabel(
                      'Nom de l\'entreprise possédant le BL',
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        hintText: 'Entrer le nom de l\'entreprise',
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
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
                              'Télécharger des images/Vidéo',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fichier téléchargé
                    if (_hasUploadedFile)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _uploadedFileName!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
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
                    // Affichage de l'image uploadée depuis Cloudinary
                    if (_cloudinaryUrl != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          _cloudinaryUrl!,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _buildVerificationButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize:
            isSmallScreen
                ? 14
                : isMediumScreen
                ? 16
                : 18,
      ),
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
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildVerificationButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MastervacPage(isAcheteur: true),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'Vérification',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
    );
  }
}
