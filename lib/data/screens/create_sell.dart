import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List
import 'dart:convert'; // Added for jsonDecode

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for kIsWeb
import 'package:flutter/services.dart'; // Added for input formatters
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
  static const int _maxMediaSlots = 12;
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
  List<File?> _uploadedImages =
      List.filled(_maxMediaSlots, null); // mobile - max images
  List<Uint8List?> _uploadedImagesWeb = List.filled(
    _maxMediaSlots,
    null,
  ); // web - max images
  List<String?> _cloudinaryImageUrls = List.filled(_maxMediaSlots, null);
  List<bool> _isUploadingImage = List.filled(
    _maxMediaSlots,
    false,
  ); // Ajouté pour le chargement
  File? _uploadedVideo;
  String? _cloudinaryVideoUrl;
  bool _isUploadingVideo = false; // Ajouté pour le chargement vidéo
  double _videoUploadProgress = 0.0; // Progression de l'upload vidéo

  String? _customModel; // Ajouté pour la saisie personnalisée du modèle
  String? _customMarque; // Ajouté pour la saisie personnalisée de la marque
  String? _selectedCouleur; // Couleur sélectionnée
  bool? _dedouanement; // Dédouanement (true = Oui, false = Non)

  final List<String> _conditions = ['Nouveau', 'Occasion']; // Reste en String

  // Mapping des marques vers leurs modèles
  final Map<String, List<String>> _marqueModels = {
    'BMW': ['Série 3', 'Série 5', 'X3', 'X5', 'Série 1', 'Autre'],
    'Mercedes': ['Classe C', 'Classe E', 'GLC', 'GLE', 'Classe A', 'Autre'],
    'Audi': ['A3', 'A4', 'A6', 'Q5', 'Q7', 'Autre'],
    'Ford': ['Focus', 'Fiesta', 'Ranger', 'Explorer', 'Mustang', 'Autre'],
    'Lexus': ['IS', 'ES', 'RX', 'NX', 'LS', 'Autre'],
  };

  final List<String> _marques = [
    'BMW',
    'Mercedes',
    'Audi',
    'Ford',
    'Lexus',
    'Autre',
  ]; // Ajout de "Autre"

  // Getter pour obtenir les modèles selon la marque sélectionnée
  List<String> get _availableModels {
    if (_selectedMarques == null || _selectedMarques == 'Autre') {
      return ['Autre']; // Si "Autre" marque ou aucune marque, seulement "Autre"
    }
    return _marqueModels[_selectedMarques] ?? ['Autre'];
  }

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

  // Liste complète des couleurs avec leurs codes
  final Map<String, Color> _couleurs = {
    'Blanc': Colors.white,
    'Noir': Colors.black,
    'Gris': Colors.grey,
    'Argenté': const Color(0xFFC0C0C0),
    'Rouge': Colors.red,
    'Bleu': Colors.blue,
    'Vert': Colors.green,
    'Jaune': Colors.yellow,
    'Orange': Colors.orange,
    'Violet': Colors.purple,
    'Rose': Colors.pink,
    'Marron': Colors.brown,
    'Beige': const Color(0xFFF5F5DC),
    'Bordeaux': const Color(0xFF800020),
    'Bleu marine': const Color(0xFF000080),
    'Vert foncé': const Color(0xFF006400),
    'Gris foncé': const Color(0xFF696969),
    'Gris clair': const Color(0xFFD3D3D3),
    'Rouge foncé': const Color(0xFF8B0000),
    'Bleu clair': const Color(0xFFADD8E6),
    'Vert clair': const Color(0xFF90EE90),
    'Jaune clair': const Color(0xFFFFFFE0),
    'Orange foncé': const Color(0xFFFF8C00),
    'Violet foncé': const Color(0xFF4B0082),
    'Rose foncé': const Color(0xFFC71585),
    'Marron clair': const Color(0xFFD2B48C),
    'Crème': const Color(0xFFFFFDD0),
    'Ivoire': const Color(0xFFFFFFF0),
    'Champagne': const Color(0xFFF7E7CE),
    'Bronze': const Color(0xFFCD7F32),
    'Doré': const Color(0xFFFFD700),
    'Cuivre': const Color(0xFFB87333),
    'Turquoise': const Color(0xFF40E0D0),
    'Cyan': const Color(0xFF00FFFF),
    'Magenta': const Color(0xFFFF00FF),
    'Lime': const Color(0xFF00FF00),
    'Indigo': const Color(0xFF4B0082),
    'Olive': const Color(0xFF808000),
    'Saumon': const Color(0xFFFA8072),
    'Corail': const Color(0xFFFF7F50),
    'Pêche': const Color(0xFFFFDAB9),
    'Lavande': const Color(0xFFE6E6FA),
    'Menthe': const Color(0xFF98FB98),
    'Bleu pétrole': const Color(0xFF008B8B),
    'Vert olive': const Color(0xFF6B8E23),
    'Rouge brique': const Color(0xFFB22222),
    'Bleu acier': const Color(0xFF4682B4),
    'Vert forêt': const Color(0xFF228B22),
    'Prune': const Color(0xFFDDA0DD),
    'Kaki': const Color(0xFFF0E68C),
    'Anthracite': const Color(0xFF36454F),
    'Perle': const Color(0xFFEAE0C8),
  };

  // Supprimer la déclaration, l'utilisation et l'affichage du champ 'lieu' (dropdown, TextField, variables _selectedLieu, _customLieu, _lieux, etc.)

  Future<void> _pickImage(int startIndex) async {
    final ImagePicker picker = ImagePicker();
    // Multi-sélection sur mobile et web
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isEmpty) return;
    int gridIndex = startIndex;
    for (final img in images) {
      if (gridIndex >= _uploadedImages.length) break;
      if (kIsWeb) {
        final bytes = await img.readAsBytes();
        setState(() {
          _uploadedImagesWeb[gridIndex] = bytes;
          _isUploadingImage[gridIndex] = true;
        });
        final url = await uploadImageToCloudinaryWeb(
          bytes,
          folder: CloudinaryFolders.vehicleImages,
        );
        if (url != null) {
          setState(() {
            _cloudinaryImageUrls[gridIndex] = url;
          });
        }
        setState(() {
          _isUploadingImage[gridIndex] = false;
        });
      } else {
        setState(() {
          _uploadedImages[gridIndex] = File(img.path);
          _isUploadingImage[gridIndex] = true;
        });
        final url = await uploadImageToCloudinary(
          _uploadedImages[gridIndex]!,
          folder: CloudinaryFolders.vehicleImages,
        );
        if (url != null) {
          setState(() {
            _cloudinaryImageUrls[gridIndex] = url;
          });
        }
        setState(() {
          _isUploadingImage[gridIndex] = false;
        });
      }
      gridIndex++;
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages[index] = null;
      _cloudinaryImageUrls[index] = null;
      _isUploadingImage[index] = false;
    });
  }

  void _removeVideo() {
    setState(() {
      _uploadedVideo = null;
      _cloudinaryVideoUrl = null;
      _isUploadingVideo = false;
    });
  }

  Future<void> _pickVideo() async {
    print('[CreateSell] Début de la sélection vidéo');
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      print('[CreateSell] Vidéo sélectionnée: ${video.path}');

      // Vérification de la taille (500 Mo max)
      final int maxSizeBytes = 500 * 1024 * 1024; // 500 Mo
      final int videoSize = await video.length();
      final double videoSizeMB = videoSize / (1024 * 1024);
      print(
          '[CreateSell] Taille de la vidéo: ${videoSizeMB.toStringAsFixed(2)} Mo');

      if (videoSize > maxSizeBytes) {
        print(
          '[CreateSell] Vidéo trop lourde: ${videoSizeMB.toStringAsFixed(2)} Mo > 500 Mo',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La vidéo est trop lourde (${videoSizeMB.toStringAsFixed(2)} Mo). Limite: 500 Mo.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _uploadedVideo = File(video.path);
        _isUploadingVideo = true;
        _videoUploadProgress = 0.0;
      });
      print('[CreateSell] État mis à jour: _isUploadingVideo = true');

      try {
        String? url;
        print('[CreateSell] Plateforme: ${kIsWeb ? "Web" : "Mobile"}');

        if (kIsWeb) {
          print('[CreateSell] Lecture des bytes pour Web...');
          final bytes = await video.readAsBytes();
          print('[CreateSell] Bytes lus: ${bytes.length} bytes');
          print('[CreateSell] Appel uploadVideoToCloudinaryWeb...');
          url = await uploadVideoToCloudinaryWeb(
            bytes,
            folder: CloudinaryFolders.vehicleVideos,
          );
        } else {
          print('[CreateSell] Appel uploadVideoToCloudinary pour mobile...');
          print('[CreateSell] Fichier: ${_uploadedVideo!.path}');
          url = await uploadVideoToCloudinary(
            _uploadedVideo!,
            folder: CloudinaryFolders.vehicleVideos,
            onProgress: (progress) {
              setState(() {
                _videoUploadProgress = progress;
              });
            },
          );
        }

        print('[CreateSell] URL retournée: $url');

        if (url != null) {
          setState(() {
            _cloudinaryVideoUrl = url;
          });
          print('[CreateSell] Vidéo uploadée avec succès! URL: $url');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vidéo uploadée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('[CreateSell] ERREUR: URL null retournée par Cloudinary');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors de l\'upload de la vidéo. Veuillez réessayer.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e, stackTrace) {
        print('[CreateSell] EXCEPTION lors de l\'upload: $e');
        print('[CreateSell] Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur détaillée: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } finally {
        setState(() {
          _isUploadingVideo = false;
          _videoUploadProgress = 0.0;
        });
        print('[CreateSell] État final: _isUploadingVideo = false');
      }
    } else {
      print('[CreateSell] Aucune vidéo sélectionnée');
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
    // Debug logs
    print('[CreateSell] _cloudinaryVideoUrl: $_cloudinaryVideoUrl');
    print('[CreateSell] _uploadedVideo: $_uploadedVideo');

    final imagesCount = _cloudinaryImageUrls.whereType<String>().length;
    if (imagesCount > _maxMediaSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vous pouvez sélectionner au maximum $_maxMediaSlots médias.',
          ),
        ),
      );
      return;
    }

    // Vérifier qu'au moins un média (image ou vidéo) est présent
    final hasImages = imagesCount > 0;
    final hasVideo =
        _cloudinaryVideoUrl != null && _cloudinaryVideoUrl!.isNotEmpty;
    if (!hasImages && !hasVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une image ou une vidéo.'),
        ),
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
            ((_customMarque == null || _customMarque!.isEmpty) ||
                (_customModel == null || _customModel!.isEmpty))) ||
        (_selectedMarques != 'Autre' &&
            (_selectedModel == null ||
                (_selectedModel == 'Autre' &&
                    (_customModel == null || _customModel!.isEmpty)))) ||
        _cylindreController.text.isEmpty ||
        _selectedPorte == null ||
        _selectedBoiteVitesse == null ||
        _selectedCarburantDropdown == null ||
        _selectedClimatiseurDropdown == null ||
        _selectedCouleur == null ||
        _dedouanement == null ||
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
    String? modele;
    if (_selectedMarques == 'Autre') {
      // Si marque "Autre", utiliser directement le modèle personnalisé
      modele = _customModel;
    } else {
      // Sinon, utiliser le modèle sélectionné ou personnalisé si "Autre"
      modele = _selectedModel == 'Autre' ? _customModel : _selectedModel;
    }
    // Passe toutes les infos à cars_info.dart
    final imagesList = _cloudinaryImageUrls.whereType<String>().toList();
    print('[CreateSell] images transmises à CarsInfo: $imagesList');
    print('[CreateSell] vidéo transmise à CarsInfo: $_cloudinaryVideoUrl');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarsInfo(
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
          couleur: _selectedCouleur,
          dedouanement: _dedouanement,
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
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Entrer l\'année (ex: 2020)',
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
                                    if (value != 'Autre') {
                                      _customMarque = null;
                                    }
                                    // Réinitialiser le modèle quand la marque change
                                    _selectedModel = null;
                                    _customModel = null;
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
                              // Si marque "Autre", afficher directement le champ texte
                              if (_selectedMarques == 'Autre')
                                TextField(
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
                                )
                              else
                                // Sinon, afficher le dropdown avec les modèles de la marque
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDropdown<String>(
                                      value: _selectedModel,
                                      hint: 'Choisissez le modèle',
                                      items: _availableModels,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedModel = value;
                                          if (value != 'Autre')
                                            _customModel = null;
                                        });
                                      },
                                    ),
                                    if (_selectedModel == 'Autre')
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Entrez le modèle personnalisé',
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
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Entrer le cylindre (ex: 1600)',
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

                    // Couleur
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Couleur'),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _couleurs.length,
                            itemBuilder: (context, index) {
                              final couleurNom = _couleurs.keys.elementAt(
                                index,
                              );
                              final couleurValeur = _couleurs.values.elementAt(
                                index,
                              );
                              final isSelected = _selectedCouleur == couleurNom;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCouleur = couleurNom;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: couleurValeur,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.grey,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(
                                                0.5,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: couleurValeur == Colors.white
                                      ? Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        if (_selectedCouleur != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Couleur sélectionnée: $_selectedCouleur',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dédouanement
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Dédouanement'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('Oui'),
                                  value: true,
                                  groupValue: _dedouanement,
                                  onChanged: (value) {
                                    setState(() {
                                      _dedouanement = value;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('Non'),
                                  value: false,
                                  groupValue: _dedouanement,
                                  onChanged: (value) {
                                    setState(() {
                                      _dedouanement = value;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                            ],
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
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(7),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Entrer la distance (km)',
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
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Entrer le nombre de sièges',
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

                    // Télécharger des images optionnelles
                    _buildLabel('Images (optionnel, max 12)',
                        isRequired: false),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _maxMediaSlots,
                      itemBuilder: (context, index) {
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
                                if (kIsWeb && _uploadedImagesWeb[index] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _uploadedImagesWeb[index]!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                else if (!kIsWeb &&
                                    _uploadedImages[index] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _uploadedImages[index]!,
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
                                if (_cloudinaryImageUrls[index] != null)
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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
                    const SizedBox(height: 24),
                    // Upload vidéo (optionnelle)
                    _buildLabel('Vidéo (optionnelle, max 500 Mo)',
                        isRequired: false),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _cloudinaryVideoUrl == null ? _pickVideo : null,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _cloudinaryVideoUrl == null
                                ? Colors.blue
                                : Colors.green,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            else if (_uploadedVideo != null)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.videocam,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Vidéo sélectionnée',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
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
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            if (_isUploadingVideo)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            value: _videoUploadProgress > 0
                                                ? _videoUploadProgress
                                                : null,
                                            color: Colors.blue,
                                            backgroundColor: Colors.white24,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _videoUploadProgress < 0.85
                                              ? 'Envoi...'
                                              : 'Traitement...',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(_videoUploadProgress * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Barre de progression linéaire
                                        Container(
                                          width: 150,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: _videoUploadProgress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(2),
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

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Text(
      isRequired ? '$text *' : text,
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
          items: items.map((T item) {
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
Future<String?> uploadImageToCloudinaryWeb(
  Uint8List bytes, {
  String folder = CloudinaryFolders.vehicleImages,
}) async {
  // Remplace par ta clé Cloudinary et ton preset
  const String cloudName = 'dy0raj5bh'; // <-- à remplacer par ton cloud name
  const String uploadPreset =
      'unsigned_preset'; // <-- à remplacer par ton preset
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..fields['folder'] = folder
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

// Fonction locale supprimée - utiliser celle importée depuis cloudinary_upload.dart
