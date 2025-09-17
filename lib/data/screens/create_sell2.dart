import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'mastervacpage.dart'; // Importez la page MastervacPage
import '../../utils/cloudinary_upload.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';
import 'dart:developer';

class CreateSellPage2 extends StatefulWidget {
  const CreateSellPage2({super.key});

  @override
  CreateSellPage2State createState() => CreateSellPage2State();
}

class CreateSellPage2State extends State<CreateSellPage2> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _anneeController = TextEditingController();
  final TextEditingController _localisationController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String? _selectedPieceType; // Nouveau/Occasion
  String? _selectedFuelType; // Essence/Gazoil/Diezel/Electrique/Hybride
  String? _selectedModel; // Modèle (String, pas int)
  String? _uploadedFileName;
  bool _hasUploadedFile = false;
  List<File?> _uploadedImages = [null, null];
  List<String?> _cloudinaryUrls = [null, null];

  String? _cloudinaryVideoUrl;
  bool _isUploadingVideo = false;

  final List<String> _pieceTypes = ['Nouveau', 'Occasion'];
  final List<String> _fuelTypes = [
    'Essence',
    'Gazoil',
    'Diezel',
    'Electrique',
    'Hybride',
    'Aucun',
  ];
  final List<String> _models = ['Modèle1', 'Modèle2', 'Autre'];
  String? _customFuelType;
  String? _customModel;

  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _uploadedImages[index] = File(image.path);
        _uploadedFileName = image.name;
        _hasUploadedFile = true;
      });
      // Upload vers Cloudinary via utilitaire
      final url = await uploadImageToCloudinary(_uploadedImages[index]!);
      if (url != null) {
        setState(() {
          _cloudinaryUrls[index] = url;
        });
      }
    }
  }

  // Future<void> _pickVideo() async { // supprimé car inutilisé
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

  //   if (video != null) {
  //     setState(() {
  //       _isUploadingVideo = true;
  //       _uploadedVideo = File(video.path);
  //       _uploadedFileName = video.name;
  //       _hasUploadedFile = true;
  //     });
  //     // Upload vers Cloudinary via utilitaire
  //     final url = await uploadImageToCloudinary(_uploadedVideo!);
  //     if (url != null) {
  //       setState(() {
  //         _cloudinaryVideoUrl = url;
  //       });
  //     }
  //     setState(() {
  //       _isUploadingVideo = false;
  //     });
  //   }
  // }

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
                                          _pieceTypes.map((type) {
                                            return Row(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min, // Réduit la taille au minimum nécessaire
                                              children: [
                                                Radio<String>(
                                                  value: type,
                                                  groupValue:
                                                      _selectedPieceType,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedPieceType =
                                                          value;
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
                                          _pieceTypes.map((type) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 16,
                                              ), // Espacement entre les radio buttons
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Radio<String>(
                                                    value: type,
                                                    groupValue:
                                                        _selectedPieceType,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedPieceType =
                                                            value;
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
                                controller: _anneeController,
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
                                value: _selectedFuelType,
                                hint: 'Type de moteur',
                                items: _fuelTypes,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFuelType = value;
                                    if (value != 'Aucun')
                                      _customFuelType = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_selectedFuelType == 'Aucun')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Entrez le type de moteur',
                                filled: true,
                                fillColor: Color(0xFFF2F2F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _customFuelType = val;
                                });
                              },
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
                                value: _selectedModel,
                                hint: 'Modèle',
                                items: _models,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedModel = value;
                                    _customModel = value == 'Autre' ? '' : null;
                                  });
                                },
                              ),
                              if (_selectedModel == 'Autre')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Entrez le modèle',
                                      filled: true,
                                      fillColor: Color(0xFFF2F2F2),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _customModel = val;
                                      });
                                    },
                                  ),
                                ),
                              if (_selectedModel != null &&
                                  _selectedModel != 'Autre')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Modèle sélectionné : $_selectedModel',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              if (_selectedModel == 'Autre' &&
                                  _customModel != null &&
                                  _customModel!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Modèle personnalisé : $_customModel',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
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
                                controller: _localisationController,
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
                                controller: _prixController,
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
                        onTap: () {
                          _pickImage(0);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Télécharger une image',
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
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _pickImage(1);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Télécharger une image (optionnel)',
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
                    if (_cloudinaryUrls[0] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          _cloudinaryUrls[0]!,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (_cloudinaryUrls[1] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          _cloudinaryUrls[1]!,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (_isUploadingVideo)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (!_isUploadingVideo && _cloudinaryVideoUrl != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          _cloudinaryVideoUrl!,
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
          _onValidate();
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

  void _onValidate() {
    // Vérification des champs obligatoires
    final title = _titleController.text.trim();
    final annee = _anneeController.text.trim();
    final localisation = _localisationController.text.trim();
    final prix = _prixController.text.trim();
    final description = _descriptionController.text.trim();
    final company = _companyController.text.trim();
    final pieceType = _selectedPieceType;
    final fuelType =
        _selectedFuelType == 'Aucun' ? _customFuelType : _selectedFuelType;
    final model = (_selectedModel == 'Autre') ? _customModel : _selectedModel;
    final imageUrl = _cloudinaryUrls[0];

    log('[DEBUG] title: "$title" (empty: ${title.isEmpty})');
    log('[DEBUG] pieceType: "$pieceType" (null: ${pieceType == null})');
    log('[DEBUG] annee: "$annee" (empty: ${annee.isEmpty})');
    log(
      '[DEBUG] fuelType: "$fuelType" (null/empty:  ${fuelType == null || fuelType.isEmpty})',
    );
    log(
      '[DEBUG] model: "$model" (null/empty: ${model == null || model.isEmpty})',
    );
    log(
      '[DEBUG] localisation: "$localisation" (empty: ${localisation.isEmpty})',
    );
    log('[DEBUG] prix: "$prix" (empty: ${prix.isEmpty})');
    log('[DEBUG] description: "$description" (empty: ${description.isEmpty})');
    log('[DEBUG] company: "$company" (empty: ${company.isEmpty})');
    log(
      '[DEBUG] imageUrl: "$imageUrl" (null/empty: ${imageUrl == null || imageUrl.isEmpty})',
    );

    if (title.isEmpty ||
        pieceType == null ||
        annee.isEmpty ||
        (fuelType == null || fuelType.isEmpty) ||
        (model == null || model.isEmpty) ||
        localisation.isEmpty ||
        prix.isEmpty ||
        description.isEmpty ||
        company.isEmpty ||
        imageUrl == null ||
        imageUrl.isEmpty) {
      log('[DEBUG] Validation échouée, un ou plusieurs champs sont invalides.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs obligatoires et au moins une image.',
          ),
        ),
      );
      return;
    }
    log('[DEBUG] Validation OK, navigation vers MastervacPage.');
    final userService = UserService();
    final isAcheteur =
        userService.currentRole == UserRole.acheteur ||
        userService.currentRole == UserRole.chauffeur;
    final images =
        _cloudinaryUrls
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MastervacPage(
              isAcheteur: isAcheteur,
              title: title,
              year: annee,
              description: description,
              company: company,
              location: localisation,
              price: prix,
              fuelType: fuelType,
              model: model,
              pieceType: pieceType,
              images: images,
              video: _cloudinaryVideoUrl,
            ),
      ),
    );
  }
}