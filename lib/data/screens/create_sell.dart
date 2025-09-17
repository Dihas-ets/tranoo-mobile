import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List
import 'dart:convert'; // Added for jsonDecode

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for kIsWeb
import 'package:image_picker/image_picker.dart';
import '../../utils/cloudinary_upload.dart';
import 'package:http/http.dart' as http; // Ajouté pour l'upload web

import 'cars_info.dart'; // Importer le fichier combiné cars_info

class CreateSellPage extends StatefulWidget {
  const CreateSellPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateSellPageState createState() => _CreateSellPageState();
}

class _CreateSellPageState extends State<CreateSellPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _cylindreController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _siegesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCondition; // Gardé en String pour "Nouveau" et "Occasion"
  String? _selectedModel; // Modèle
  String? _selectedMarques;
  int? _selectedPorte; // Portes
  // int? _selectedVitesse; // Vitesse
  // int? _selectedCarburant; // Carburant
  // int? _selectedClimatiseur; // Climatiseur
  // int? _selectedDistance; // Distance
  // int? _selectedSieges; // Sièges
  String? _selectedBoiteVitesse;
  String? _selectedCarburantDropdown;
  String? _selectedClimatiseurDropdown;
  // File? _uploadedImage;
  String? _uploadedFileName;
  //bool _hasUploadedFile = false;
  final bool _hasUploadedFile = false;
  String? _cloudinaryUrl;

  // Ajout pour plusieurs images et vidéo
  List<File?> _uploadedImages = [null, null, null]; // mobile
  List<Uint8List?> _uploadedImagesWeb = [null, null, null]; // web
  List<String?> _cloudinaryImageUrls = [null, null, null];
  List<bool> _isUploadingImage = [
    false,
    false,
    false,
  ]; // Ajouté pour le chargement
  File? _uploadedVideo;
  String? _cloudinaryVideoUrl;
  bool _isUploadingVideo = false; // Ajouté pour le chargement vidéo

  String? _customModel; // Ajouté pour la saisie personnalisée du modèle
  String? _customMarque; // Ajouté pour la saisie personnalisée de la marque

  final List<String> _conditions = ['Nouveau', 'Occasion']; // Reste en String
  final List<String> _models = [
    'Modèle1',
    'Modèle2',
    'Autre',
  ]; // Ajout de "Autre"
  final List<String> _marques = [
    'BMW',
    'Mercedes',
    'Audi',
    'Ford',
    'Lexus',
    'Autre',
  ]; // Ajout de "Autre"
  final List<String> _boiteVitesses = ['Manuelle', 'Automatique'];
  final List<String> _carburantsList = [
    'Essence',
    'Diesel',
    'Électrique',
    'Hybride',
  ];
  final List<String> _climatiseursList = ['Oui', 'Non'];
  final List<int> _portesList = [
    2,
    3,
    4,
    5,
  ]; // Liste d'options pour le nombre de portes

  // Supprimer la déclaration, l'utilisation et l'affichage du champ 'lieu' (dropdown, TextField, variables _selectedLieu, _customLieu, _lieux, etc.)

  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _uploadedImagesWeb[index] = bytes;
          _isUploadingImage[index] = true;
        });
        final url = await uploadImageToCloudinaryWeb(bytes);
        if (url != null) {
          setState(() {
            _cloudinaryImageUrls[index] = url;
          });
        }
        setState(() {
          _isUploadingImage[index] = false;
        });
      } else {
        setState(() {
          _uploadedImages[index] = File(image.path);
          _isUploadingImage[index] = true;
        });
        final url = await uploadImageToCloudinary(_uploadedImages[index]!);
        if (url != null) {
          setState(() {
            _cloudinaryImageUrls[index] = url;
          });
        }
        setState(() {
          _isUploadingImage[index] = false;
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      // Vérification de la taille (20 Mo max)
      final int maxSizeBytes = 20 * 1024 * 1024; // 20 Mo
      final int videoSize = await video.length();
      if (videoSize > maxSizeBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La vidéo est trop lourde (max 20 Mo). Veuillez choisir une vidéo plus courte.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Idéalement, la vidéo doit faire moins de 1 minute pour une présentation rapide.
      setState(() {
        _uploadedVideo = File(video.path);
        _isUploadingVideo = true;
      });
      final url = await uploadVideoToCloudinary(_uploadedVideo!);
      if (url != null) {
        setState(() {
          _cloudinaryVideoUrl = url;
        });
      }
      setState(() {
        _isUploadingVideo = false;
      });
    }
  }

  bool get _isAnyUploading =>
      _isUploadingImage.contains(true) || _isUploadingVideo;

  // Synchronisation Condition <-> Checkbox
  void _onConditionChanged(String? value) {
    setState(() {
      _selectedCondition = value;
      // Synchronise les checkboxes
      // isNew = value == 'Nouveau';
      // isOccasion = value == 'Occasion';
    });
  }

  // Supprimer les variables isNew, isOccasion, _onCheckboxChanged, et la Row avec les Checkbox
  // Après le Dropdown de la condition, ne pas afficher de checkboxes

  void _onValidate() {
    // Vérifie que 3 images sont sélectionnées (locales ou uploadées)
    if ((kIsWeb && _uploadedImagesWeb.any((img) => img == null)) ||
        (!kIsWeb && _uploadedImages.any((img) => img == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner 3 images.')),
      );
      return;
    }
    if (_isAnyUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez attendre la fin de l\'upload.')),
      );
      return;
    }
    // Vérifie que tous les champs obligatoires sont remplis
    if (_titleController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _selectedCondition == null ||
        _selectedMarques == null ||
        (_selectedMarques == 'Autre' &&
            (_customMarque == null || _customMarque!.isEmpty)) ||
        _selectedModel == null ||
        (_selectedModel == 'Autre' &&
            (_customModel == null || _customModel!.isEmpty)) ||
        _cylindreController.text.isEmpty ||
        _selectedPorte == null ||
        _selectedBoiteVitesse == null ||
        _selectedCarburantDropdown == null ||
        _selectedClimatiseurDropdown == null ||
        _distanceController.text.isEmpty ||
        _siegesController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
        ),
      );
      return;
    }
    // Détermine la marque et le modèle à utiliser
    String? marque =
        _selectedMarques == 'Autre' ? _customMarque : _selectedMarques;
    String? modele = _selectedModel == 'Autre' ? _customModel : _selectedModel;
    // Passe toutes les infos à cars_info.dart
    final imagesList = _cloudinaryImageUrls.whereType<String>().toList();
    print('[CreateSell] images transmises à CarsInfo: $imagesList');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CarsInfo(
              titre: _titleController.text,
              description: _descriptionController.text,
              marque: marque,
              modele: modele,
              annee: _yearController.text,
              prix: _priceController.text,
              condition: _selectedCondition,
              boiteVitesse: _selectedBoiteVitesse,
              carburant: _selectedCarburantDropdown,
              climatiseur: _selectedClimatiseurDropdown,
              distance: _distanceController.text,
              sieges: _siegesController.text,
              portes: _selectedPorte?.toString(),
              cylindre: _cylindreController.text,
              images: imagesList,
              video: _cloudinaryVideoUrl,
              entreprise: _companyController.text,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildLabel('Titre'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Entrer le titre',
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

                    // Condition et Année
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Condition'),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: _selectedCondition,
                                hint: 'Choisissez la condition',
                                items: _conditions,
                                onChanged: _onConditionChanged,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Année'),
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

                    // Marque et Modèle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Marques'),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: _selectedMarques,
                                hint: 'Choisissez la marque',
                                items: _marques,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMarques = value;
                                    if (value != 'Autre') _customMarque = null;
                                  });
                                },
                              ),
                              if (_selectedMarques == 'Autre')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Entrez la marque',
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
                                        _customMarque = val;
                                      });
                                    },
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
                              _buildLabel('Modèle'),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: _selectedModel,
                                hint: 'Choisissez le modèle',
                                items: _models,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedModel = value;
                                    if (value != 'Autre') _customModel = null;
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Cylindre
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Cylindre'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cylindreController,
                          decoration: InputDecoration(
                            hintText: 'Entrer le cylindre',
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
                    const SizedBox(height: 24),

                    // Porte et Boîte à vitesse
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Porte'),
                              const SizedBox(height: 8),
                              _buildDropdown<int>(
                                value: _selectedPorte,
                                hint: 'Choisissez le nombre de portes',
                                items: _portesList,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPorte = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Boîte à vitesse'),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: _selectedBoiteVitesse,
                                hint: 'Choisissez la vitesse',
                                items: _boiteVitesses,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBoiteVitesse = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Carburant et Climatiseur
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Carburant'),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: _selectedCarburantDropdown,
                                hint: 'Choisissez le carburant',
                                items: _carburantsList,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCarburantDropdown = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Climatiseur'),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: _selectedClimatiseurDropdown,
                                hint: 'Choisissez le climatiseur',
                                items: _climatiseursList,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedClimatiseurDropdown = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Distance et Siège
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Distance'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _distanceController,
                                decoration: InputDecoration(
                                  hintText: 'Entrer la distance',
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
                              _buildLabel('Siège'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _siegesController,
                                decoration: InputDecoration(
                                  hintText: 'Entrer le siège',
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

                    // Prix
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Prix'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
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
                    const SizedBox(height: 24),

                    // Description
                    _buildLabel('Description'),
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

                    // Nom de l'entreprise possédant le BL
                    _buildLabel('Nom de l\'entreprise possédant le BL'),
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
                    Row(
                      children: List.generate(
                        3,
                        (index) => Expanded(
                          child: GestureDetector(
                            onTap: () => _pickImage(index),
                            child: Container(
                              height: 80,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (kIsWeb &&
                                      _uploadedImagesWeb[index] != null)
                                    Image.memory(
                                      _uploadedImagesWeb[index]!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  else if (!kIsWeb &&
                                      _uploadedImages[index] != null)
                                    Image.file(
                                      _uploadedImages[index]!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  else
                                    const Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                    ),
                                  if (_isUploadingImage[index])
                                    const Positioned.fill(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  if (_cloudinaryImageUrls[index] != null)
                                    const Positioned(
                                      right: 4,
                                      top: 4,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Upload vidéo (optionnelle)
                    // Pour la vidéo, sur web, afficher une icône ou un message (pas d'aperçu File direct)
                    GestureDetector(
                      onTap: _pickVideo,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_uploadedVideo != null)
                              kIsWeb
                                  ? const Icon(
                                    Icons.videocam,
                                    color: Colors.blue,
                                    size: 40,
                                  )
                                  : const Icon(
                                    Icons.videocam,
                                    color: Colors.blue,
                                    size: 40,
                                  )
                            else
                              const Icon(
                                Icons.add_to_photos,
                                color: Colors.grey,
                              ),
                            if (_isUploadingVideo)
                              const Positioned.fill(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (_cloudinaryVideoUrl != null)
                              const Positioned(
                                right: 4,
                                top: 4,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
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
                            const Icon(Icons.image, size: 24),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          isExpanded: true,
          items:
              items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
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
        onPressed: _isAnyUploading ? null : _onValidate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child:
            _isAnyUploading
                ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Upload en cours...'),
                  ],
                )
                : const Text(
                  'Valider',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _companyController.dispose();
    _cylindreController.dispose();
    _distanceController.dispose();
    _siegesController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

// Fonction d'upload Cloudinary pour Flutter Web
Future<String?> uploadImageToCloudinaryWeb(Uint8List bytes) async {
  // Remplace par ta clé Cloudinary et ton preset
  const String cloudName = 'dy0raj5bh'; // <-- à remplacer par ton cloud name
  const String uploadPreset =
      'unsigned_preset'; // <-- à remplacer par ton preset
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  final request =
      http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: 'upload.jpg'),
        );

  final response = await request.send();
  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final json = jsonDecode(respStr) as Map<String, dynamic>;
    return json['secure_url'] as String?;
  } else {
    return null;
  }
}