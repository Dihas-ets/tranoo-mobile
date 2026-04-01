import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'mastervacpage.dart'; // Importez la page MastervacPage
import '../../utils/cloudinary_upload.dart';
import 'package:tranoo/services/user_service.dart';
import 'dart:developer';

class CreateSellPage2 extends StatefulWidget {
  const CreateSellPage2({super.key});

  @override
  CreateSellPage2State createState() => CreateSellPage2State();
}

class CreateSellPage2State extends State<CreateSellPage2> {
  static const int _maxMediaSlots = 12;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _anneeController = TextEditingController();
  final TextEditingController _localisationController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String? _selectedPieceType; // Nouveau/Occasion
  String? _selectedFuelType; // Essence/Gazoil/Diezel/Electrique/Hybride
  String? _selectedModel; // Modèle (String, pas int)
  // Variables pour l'upload d'images
  List<File?> _uploadedImages =
      List<File?>.filled(_maxMediaSlots, null, growable: false);
  List<String?> _cloudinaryUrls =
      List<String?>.filled(_maxMediaSlots, null, growable: false);
  List<bool> _isUploadingImage =
      List<bool>.filled(_maxMediaSlots, false, growable: false);

  // Variables pour l'upload de vidéo
  String? _cloudinaryVideoUrl;
  bool _isUploadingVideo = false;
  double _videoUploadProgress = 0.0; // Progression de l'upload vidéo

  bool get _isAnyUploading =>
      _isUploadingImage.contains(true) || _isUploadingVideo;

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
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final file = File(image.path);
      setState(() {
      _uploadedImages[index] = file;
      _isUploadingImage[index] = true;
      });

    try {
      final url = await uploadImageToCloudinary(
        file,
        folder: CloudinaryFolders.pieceImages,
      );
      if (!mounted) return;
      if (url != null) {
        setState(() {
          _cloudinaryUrls[index] = url;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Erreur lors de l\'upload de l\'image. Veuillez réessayer.'),
          ),
        );
        setState(() {
          _uploadedImages[index] = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload échoué: $e')),
      );
      setState(() {
        _uploadedImages[index] = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploadingImage[index] = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages[index] = null;
      _cloudinaryUrls[index] = null;
      _isUploadingImage[index] = false;
    });
  }

  void _removeVideo() {
    setState(() {
      _cloudinaryVideoUrl = null;
      _isUploadingVideo = false;
    });
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video =
        await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

      setState(() {
        _isUploadingVideo = true;
        _videoUploadProgress = 0.0;
      });

    try {
      final url = await uploadVideoToCloudinary(
        File(video.path),
        folder: CloudinaryFolders.pieceVideos,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _videoUploadProgress = progress;
          });
        },
      );
      if (!mounted) return;
      if (url != null) {
        setState(() {
          _cloudinaryVideoUrl = url;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Erreur lors de l\'upload de la vidéo. Veuillez réessayer.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload vidéo échoué: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploadingVideo = false;
        _videoUploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 800;
    final isLargeScreen = screenWidth >= 800;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
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
                        hintText: 'Entrer une description de votre pièce',
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

                    _buildLabel(
                      'Images (optionnel, max 12)',
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                      isRequired: false,
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 2 : 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _maxMediaSlots,
                      itemBuilder: (context, index) {
                        final file = _uploadedImages[index];
                        final uploadedUrl = _cloudinaryUrls[index];
                        final hasMedia = file != null || uploadedUrl != null;
                        return GestureDetector(
                          onTap: () => _pickImage(index),
                          child: Container(
                        decoration: BoxDecoration(
                              color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber),
                                  ),
                        child: Stack(
                              alignment: Alignment.center,
                          children: [
                                if (uploadedUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      uploadedUrl,
                              fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                else if (file != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                else
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                        size: 30,
                                  ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                                if (_isUploadingImage[index])
                                  const Positioned.fill(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                                if (hasMedia)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                        if (uploadedUrl != null)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                          onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
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
                    const SizedBox(height: 16),
                    // Upload vidéo avec aperçu
                    _buildVideoUploadSection(
                      isSmallScreen: isSmallScreen,
                      isMediumScreen: isMediumScreen,
                      isLargeScreen: isLargeScreen,
                    ),
              const SizedBox(height: 20),
              _buildVerificationButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen, {
    bool isRequired = true,
  }) {
    return Text(
      isRequired ? '$text *' : text,
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

  Widget _buildVideoUploadSection({
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isLargeScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          'Vidéo (optionnelle)',
          isSmallScreen,
          isMediumScreen,
          isLargeScreen,
          isRequired: false,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _cloudinaryVideoUrl == null ? _pickVideo : null,
          child: Container(
            height: 120,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _cloudinaryVideoUrl == null ? Colors.blue : Colors.green,
                width: 2,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (_cloudinaryVideoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black87,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Vidéo uploadée',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.video_call,
                          color: Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ajouter une vidéo',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (_isUploadingVideo)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: _videoUploadProgress > 0 ? _videoUploadProgress : null,
                                color: Colors.blue,
                                backgroundColor: Colors.white24,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _videoUploadProgress < 0.85
                                  ? 'Envoi...'
                                  : 'Traitement...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${(_videoUploadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Barre de progression linéaire
                            Container(
                              width: 160,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _videoUploadProgress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_cloudinaryVideoUrl != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: _removeVideo,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAnyUploading ? null : _onValidate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _isAnyUploading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Upload en cours...',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ],
              )
            : const Text(
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

    if (title.isEmpty ||
        pieceType == null ||
        annee.isEmpty ||
        (fuelType == null || fuelType.isEmpty) ||
        (model == null || model.isEmpty) ||
        localisation.isEmpty ||
        prix.isEmpty ||
        description.isEmpty ||
        company.isEmpty) {
      log('[DEBUG] Validation échouée, un ou plusieurs champs sont invalides.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir tous les champs obligatoires.',
          ),
        ),
      );
      return;
    }
    
    // Vérifier qu'au moins un média (image ou vidéo) est présent
    final imagesCount = _cloudinaryUrls.whereType<String>().where((url) => url.isNotEmpty).length;
    final hasImages = imagesCount > 0;
    final hasVideo = _cloudinaryVideoUrl != null && _cloudinaryVideoUrl!.isNotEmpty;
    if (!hasImages && !hasVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une image ou une vidéo.'),
        ),
      );
      return;
    }
    
    log('[DEBUG] Validation OK, navigation vers MastervacPage.');
    final userService = UserService();
    final isAcheteur = userService.isAcheteur;
    final images = _cloudinaryUrls
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
