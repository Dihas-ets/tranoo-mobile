// ignore_for_file: unused_field, unused_element, unused_local_variable

import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:tranoo/data/screens/paymentscreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tranoo/utils/cloudinary_upload.dart';
import 'dart:developer';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class Une extends StatefulWidget {
  final String? articleId; // ID de l'article existant (optionnel)
  final String? articleType; // 'voiture' ou 'piece' (optionnel)
  final bool
      isStandalone; // Nouveau: true pour pub standalone, false pour pub d'article existant

  // Paramètres pour pré-remplir les champs quand l'article n'est pas encore créé
  final String? articleTitle;
  final String? articleYear;
  final String? articleLocation;
  final String? articlePrice;
  final String? articleDescription;
  final String? articleCompany;
  final String? articleModel;
  final String? articleFuelType;
  final String? articlePieceType;
  final List<String>? articleImages;
  final String? articleVideo;

  const Une({
    super.key,
    this.articleId,
    this.articleType,
    this.isStandalone = false, // Par défaut, ce n'est pas standalone
    this.articleTitle,
    this.articleYear,
    this.articleLocation,
    this.articlePrice,
    this.articleDescription,
    this.articleCompany,
    this.articleModel,
    this.articleFuelType,
    this.articlePieceType,
    this.articleImages,
    this.articleVideo,
  });

  @override
  State<Une> createState() => _UneState();
}

class _UneState extends State<Une> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  static const String _pubSponsored = 'Sponsorisée';
  static const String _pubFeatured = 'À la une';
  static const String _bankPayment = 'Paiement bancaire';
  static const String _dureeOneWeek = '1 semaine';
  static const String _dureeTwoWeeks = '2 semaines';
  static const String _dureeOneMonth = '1 mois';
  static const String _dureeTwoMonths = '2 mois';
  static const String _dureeThreeMonths = '3 mois';
  static const String _conditionNew = 'Nouveau';
  static const String _conditionUsed = 'Occasion';
  static const String _noEngine = 'Aucun';
  static const String _otherModel = 'Autre';

  final _formKey = GlobalKey<FormState>();
  String? _selectedVoiture;
  String? _selectedPaiement;
  String? _selectedDuree;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  // Contrôleurs pour les informations de voiture
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _carYearController = TextEditingController();
  final TextEditingController _carLocationController = TextEditingController();
  final TextEditingController _carPriceController = TextEditingController();
  final TextEditingController _carDescriptionController =
      TextEditingController();
  final TextEditingController _carCompanyController = TextEditingController();
  final TextEditingController _carFuelTypeController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  String? _selectedCarType; // Nouveau/Occasion
  String? _selectedCarFuelType; // Essence/Gazoil/Diezel/Electrique/Hybride
  String? _selectedCarModel; // Modèle

  // Ajout pour plusieurs images et vidéo (comme create_sell.dart)
  List<File?> _uploadedImages = List.filled(11, null); // mobile
  List<Uint8List?> _uploadedImagesWeb = List.filled(11, null); // web
  List<String?> _cloudinaryImageUrls = List.filled(11, null);
  List<bool> _isUploadingImage = List.filled(11, false);
  File? _uploadedVideo;
  String? _cloudinaryVideoUrl;
  bool _isUploadingVideo = false;
  double _videoUploadProgress = 0.0; // Progression de l'upload vidéo

  final List<String> voitures = [_pubSponsored, _pubFeatured];
  final List<String> moyensPaiement = [_bankPayment, 'Mobile Money'];
  final List<String> durees = [
    _dureeOneWeek,
    _dureeTwoWeeks,
    _dureeOneMonth,
    _dureeTwoMonths,
    _dureeThreeMonths,
  ];

  // Prix par jour pour chaque type (à récupérer du backend)
  double _prixSponsoriseeParJour = 1000.0;
  double _prixALaUneParJour = 2000.0;

  // Listes pour les dropdowns de voiture
  final List<String> _carTypes = [_conditionNew, _conditionUsed];
  final List<String> _carFuelTypes = [
    'Essence',
    'Gazoil',
    'Diesel',
    'Electrique',
    'Hybride',
    _noEngine,
  ];
  final List<String> _carModels = ['Modèle1', 'Modèle2', _otherModel];

  final ImagePicker picker = ImagePicker();

  String _pubTypeLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case _pubSponsored:
        return l10n.sponsoredType;
      case _pubFeatured:
        return l10n.featuredType;
      default:
        return type;
    }
  }

  String _durationLabel(AppLocalizations l10n, String duree) {
    switch (duree) {
      case _dureeOneWeek:
        return l10n.oneWeek;
      case _dureeTwoWeeks:
        return l10n.twoWeeks;
      case _dureeOneMonth:
        return l10n.oneMonth;
      case _dureeTwoMonths:
        return l10n.twoMonths;
      case _dureeThreeMonths:
        return l10n.threeMonths;
      default:
        return duree;
    }
  }

  String _conditionLabel(AppLocalizations l10n, String? value) {
    if (value == _conditionNew) return l10n.newCondition;
    if (value == _conditionUsed) return l10n.usedCondition;
    return value ?? '';
  }

  String _fuelLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'Essence':
        return l10n.petrol;
      case 'Gazoil':
        return l10n.gazoil;
      case 'Diesel':
      case 'Diezel':
        return l10n.diesel;
      case 'Electrique':
        return l10n.electric;
      case 'Hybride':
        return l10n.hybrid;
      case _noEngine:
        return l10n.noEngine;
      default:
        return value;
    }
  }

  void _applyDefaultPlaceholders(AppLocalizations l10n) {
    if (widget.articleId != null) return;
    if (_carNameController.text == 'Nom de la voiture' ||
        _carNameController.text.isEmpty) {
      _carNameController.text = l10n.defaultCarName;
    }
    if (_carLocationController.text == 'Localisation' ||
        _carLocationController.text.isEmpty) {
      _carLocationController.text = l10n.defaultLocation;
    }
    if (_carPriceController.text == 'Prix' || _carPriceController.text.isEmpty) {
      _carPriceController.text = l10n.defaultPrice;
    }
    if (_carDescriptionController.text == 'Description de la voiture' ||
        _carDescriptionController.text.isEmpty) {
      _carDescriptionController.text = l10n.defaultCarDescription;
    }
    if (_carCompanyController.text == "Nom de l'entreprise" ||
        _carCompanyController.text.isEmpty) {
      _carCompanyController.text = l10n.defaultCompanyName;
    }
    if (_carModelController.text == 'Marque' ||
        _carModelController.text.isEmpty) {
      _carModelController.text = l10n.defaultBrand;
    }
  }

  bool get _isPieceArticle =>
      (widget.articleType ?? '').toLowerCase() == 'piece';
  String get _imageFolder => _isPieceArticle
      ? CloudinaryFolders.pieceImages
      : CloudinaryFolders.vehicleImages;
  String get _videoFolder => _isPieceArticle
      ? CloudinaryFolders.pieceVideos
      : CloudinaryFolders.vehicleVideos;

  bool _isLoading = false;
  String? _createdPubId;
  bool _isLoadingArticle = false;
  String? _createdArticleId; // ID de l'article créé pendant la session

  bool get _isAnyUploading =>
      _isUploadingImage.contains(true) || _isUploadingVideo;

  @override
  void initState() {
    super.initState();
    _loadPrixConfig(); // Charger les prix depuis le backend
    if (widget.isStandalone) {
      _selectedVoiture = _pubFeatured;
    }
    // Si on a un articleId, charger ses infos
    if (widget.articleId != null) {
      _loadArticleInfo();
    } else {
      // Pré-remplir les champs avec les paramètres passés ou des valeurs par défaut
      _carNameController.text = widget.articleTitle ?? '';
      _carYearController.text =
          widget.articleYear ?? DateTime.now().year.toString();
      _carLocationController.text = widget.articleLocation ?? '';
      _carPriceController.text = widget.articlePrice ?? '';
      _carDescriptionController.text = widget.articleDescription ?? '';
      _carCompanyController.text = widget.articleCompany ?? '';
      _carModelController.text = widget.articleModel ?? '';
      _selectedCarModel = _carModels.contains(widget.articleModel)
          ? widget.articleModel
          : 'Modèle1';
      _selectedCarFuelType = _carFuelTypes.contains(widget.articleFuelType)
          ? widget.articleFuelType
          : 'Essence';
      _selectedCarType = _carTypes.contains(widget.articlePieceType)
          ? widget.articlePieceType
          : _conditionNew;

      // Charger les images si fournies
      if (widget.articleImages != null && widget.articleImages!.isNotEmpty) {
        _cloudinaryImageUrls = List<String>.from(widget.articleImages!);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (widget.isStandalone && _descriptionController.text.isEmpty) {
      _descriptionController.text = l10n.standaloneFeaturedDescriptionDefault;
    }
    _applyDefaultPlaceholders(l10n);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _prixController.dispose();
    _carNameController.dispose();
    _carYearController.dispose();
    _carLocationController.dispose();
    _carPriceController.dispose();
    _carDescriptionController.dispose();
    _carCompanyController.dispose();
    _carFuelTypeController.dispose();
    _carModelController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // Méthode pour créer un article et récupérer son ID
  Future<String?> _createArticle() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      Map<String, dynamic> articleData;

      if (widget.articleType == 'piece') {
        // Créer un article pièce
        articleData = {
          'type': 'piece',
          'titre': _carNameController.text.trim(),
          'annee': _carYearController.text.trim(),
          'description': _carDescriptionController.text.trim(),
          'entreprise': _carCompanyController.text.trim(),
          'localisation': _carLocationController.text.trim(),
          'prix': _carPriceController.text.trim(),
          'typeMoteur': _selectedCarFuelType,
          'modele': _selectedCarModel,
          'pieceType': _selectedCarType,
          'photos': _cloudinaryImageUrls.whereType<String>().toList(),
          'video': _cloudinaryVideoUrl,
          'statut': 'en_attente', // En attente de validation admin
        };
        log('[DEBUG] Création de l\'article pièce: $articleData');
      } else {
        // Créer un article voiture
        articleData = {
          'type': 'voiture',
          'titre': _carNameController.text.trim(),
          'annee': _carYearController.text.trim(),
          'description': _carDescriptionController.text.trim(),
          'entreprise': _carCompanyController.text.trim(),
          'localisation': _carLocationController.text.trim(),
          'prix': _carPriceController.text.trim(),
          'marque': _carModelController.text.trim(),
          'modele': _selectedCarModel,
          'carburant': _selectedCarFuelType,
          'condition': _selectedCarType,
          'photos': _cloudinaryImageUrls.whereType<String>().toList(),
          'video': _cloudinaryVideoUrl,
          'statut': 'en_attente', // En attente de validation admin
        };
        log('[DEBUG] Création de l\'article voiture: $articleData');
      }

      // Créer l'article
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/articles/'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(articleData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dataResponse = jsonDecode(response.body);
        final articleId = dataResponse['article']['_id'];
        log('[DEBUG] Article créé avec ID: $articleId');
        return articleId;
      } else {
        log(
          '[DEBUG] Erreur création article: ${response.statusCode} - ${response.body}',
        );
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.articleCreateError)),
        );
        return null;
      }
    } catch (e) {
      log('[DEBUG] Exception création article: $e');
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.articleCreateNetworkError(e.toString())),
        ),
      );
      return null;
    }
  }

  Future<void> _loadArticleInfo() async {
    if (widget.articleId == null) return;

    setState(() {
      _isLoadingArticle = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/articles/${widget.articleId}'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final articleData = jsonDecode(response.body);
        log('[DEBUG] Article chargé: $articleData');

        // Remplir les champs avec les infos de l'article
        if (articleData['type'] == 'voiture') {
          _carNameController.text = articleData['titre'] ?? '';
          _carYearController.text = articleData['annee'] ?? '';
          _carLocationController.text = articleData['localisation'] ?? '';
          _carPriceController.text = articleData['prix']?.toString() ?? '';
          _carDescriptionController.text = articleData['description'] ?? '';
          _carCompanyController.text = articleData['entreprise'] ?? '';
          _carModelController.text = articleData['marque'] ?? '';
          _selectedCarModel = _carModels.contains(articleData['modele'])
              ? articleData['modele']
              : 'Modèle1';
          _selectedCarFuelType =
              _carFuelTypes.contains(articleData['carburant'])
                  ? articleData['carburant']
                  : 'Essence';
          _selectedCarType = _carTypes.contains(articleData['condition'])
              ? articleData['condition']
              : _conditionNew;

          // Charger les images existantes
          if (articleData['photos'] != null) {
            _cloudinaryImageUrls = List<String>.from(articleData['photos']);
          }
        } else if (articleData['type'] == 'piece') {
          _carNameController.text = articleData['titre'] ?? '';
          _carYearController.text = articleData['annee'] ?? '';
          _carLocationController.text = articleData['localisation'] ?? '';
          _carPriceController.text = articleData['prix']?.toString() ?? '';
          _carDescriptionController.text = articleData['description'] ?? '';
          _carCompanyController.text = articleData['entreprise'] ?? '';
          _selectedCarModel = _carModels.contains(articleData['modele'])
              ? articleData['modele']
              : 'Modèle1';
          _selectedCarFuelType =
              _carFuelTypes.contains(articleData['typeMoteur'])
                  ? articleData['typeMoteur']
                  : 'Essence';
          _selectedCarType = _carTypes.contains(articleData['pieceType'])
              ? articleData['pieceType']
              : _conditionNew;

          // Charger les images existantes
          if (articleData['photos'] != null) {
            _cloudinaryImageUrls = List<String>.from(articleData['photos']);
          }
        }

        // Pré-remplir la description de la pub
        final l10n = AppLocalizations.of(context)!;
        _descriptionController.text =
            l10n.pubForTitle(articleData['titre']?.toString() ?? '');

        log('[DEBUG] Champs remplis avec les infos de l\'article');
      } else {
        log('[DEBUG] Erreur chargement article: ${response.statusCode}');
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.articleLoadError)),
        );
      }
    } catch (e) {
      log('[DEBUG] Exception chargement article: $e');
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.articleLoadNetworkError)),
      );
    } finally {
      setState(() {
        _isLoadingArticle = false;
      });
    }
  }

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
            _uploadedImagesWeb[index] = null;
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
        final currentFile = _uploadedImages[index];
        final url = currentFile != null
            ? await uploadImageToCloudinary(
                currentFile,
                folder: _imageFolder,
              )
            : null;
        if (url != null) {
          setState(() {
            _cloudinaryImageUrls[index] = url;
            _uploadedImages[index] = null;
          });
        }
        setState(() {
          _isUploadingImage[index] = false;
        });
      }
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
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      // Vérification de la taille (500 Mo max)
      final int maxSizeBytes = 500 * 1024 * 1024; // 500 Mo
      final int videoSize = await video.length();
      final double videoSizeMB = videoSize / (1024 * 1024);
      if (videoSize > maxSizeBytes) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.videoTooHeavy(videoSizeMB.toStringAsFixed(2))),
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
      final currentVideo = _uploadedVideo;
      final url = currentVideo != null
          ? await uploadVideoToCloudinary(
              currentVideo,
              folder: _videoFolder,
              onProgress: (progress) {
                setState(() {
                  _videoUploadProgress = progress;
                });
              },
            )
          : null;
      if (url != null) {
        setState(() {
          _cloudinaryVideoUrl = url;
          _uploadedVideo = null;
        });
      }
      setState(() {
        _isUploadingVideo = false;
        _videoUploadProgress = 0.0;
      });
    }
  }

  Future<void> _uploadMediaToCloudinary() async {
    setState(() {
      _isUploadingImage = List.generate(
        _uploadedImages.length,
        (index) => true,
      );
      _isUploadingVideo = true;
      _videoUploadProgress = 0.0;
    });

    try {
      _cloudinaryImageUrls.clear();
      for (int i = 0; i < _uploadedImages.length; i++) {
        if (_uploadedImages[i] != null) {
          final url = await uploadImageToCloudinary(
            _uploadedImages[i]!,
            folder: _imageFolder,
          );
          if (url != null) {
            _cloudinaryImageUrls[i] = url;
          }
        }
      }
      if (_uploadedVideo != null) {
        final url = await uploadVideoToCloudinary(
          _uploadedVideo!,
          folder: _videoFolder,
          onProgress: (progress) {
            setState(() {
              _videoUploadProgress = progress;
            });
          },
        );
        if (url != null) {
          _cloudinaryVideoUrl = url;
        }
      }
      log(
        '[DEBUG] Media uploadé vers Cloudinary: $_cloudinaryImageUrls, $_cloudinaryVideoUrl',
      );
    } catch (e) {
      log('[DEBUG] Erreur upload media: $e');
      // Ne pas afficher d'erreur si c'est juste un problème de format non supporté ou de timeout
      if (!e.toString().contains('unsupported') &&
          !e.toString().contains('format') &&
          !e.toString().contains('timeout') &&
          !e.toString().contains('network')) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mediaUploadError(e.toString()))),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = List.generate(
          _uploadedImages.length,
          (index) => false,
        );
        _isUploadingVideo = false;
      });
    }
  }

  // Méthode pour upload web (comme dans create_sell.dart)
  Future<String?> uploadImageToCloudinaryWeb(Uint8List bytes) async {
    try {
      return await uploadImageToCloudinary(
        bytes,
        folder: _imageFolder,
      );
    } catch (e) {
      log('[DEBUG] Erreur upload web: $e');
      return null;
    }
  }

  // Charger la configuration des prix depuis le backend
  Future<void> _loadPrixConfig() async {
    try {
      // Appeler directement le backend au lieu de passer par Next.js
      final url = '${getBaseUrl()}/admin/pub-pricing';
      log('[DEBUG] Chargement prix depuis: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      log('[DEBUG] Réponse prix: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prixSponsorisee =
            (data['prixSponsoriseeParJour'] ?? 1000.0).toDouble();
        final prixALaUne = (data['prixALaUneParJour'] ?? 2000.0).toDouble();

        log('[DEBUG] Données brutes reçues: ${data.toString()}');
        log('[DEBUG] prixSponsoriseeParJour brut: ${data['prixSponsoriseeParJour']}');
        log('[DEBUG] prixALaUneParJour brut: ${data['prixALaUneParJour']}');

        setState(() {
          _prixSponsoriseeParJour = prixSponsorisee;
          _prixALaUneParJour = prixALaUne;
        });
        log(
          '[DEBUG] Prix chargés: Sponsorisée $_prixSponsoriseeParJour, À la une $_prixALaUneParJour FCFA/jour',
        );
      } else {
        log('[DEBUG] Erreur HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('[DEBUG] Erreur chargement prix: $e');
      // Garder le prix par défaut
    }
  }

  // Calculer le nombre de jours selon la durée
  int _getNombreJours(String? duree) {
    if (duree == null) return 0;
    switch (duree) {
      case _dureeOneWeek:
        return 7;
      case _dureeTwoWeeks:
        return 14;
      case _dureeOneMonth:
        return 30;
      case _dureeTwoMonths:
        return 60;
      case _dureeThreeMonths:
        return 90;
      default:
        return 0;
    }
  }

  double _getPrixParJour(String? typePub) {
    if (typePub == null) return 0.0;
    double prix = 0.0;
    switch (typePub) {
      case _pubSponsored:
        prix = _prixSponsoriseeParJour;
        break;
      case _pubFeatured:
        prix = _prixALaUneParJour;
        break;
      default:
        prix = 0.0;
    }
    log('[DEBUG] _getPrixParJour: type=$typePub, prix=$prix, _prixSponsoriseeParJour=$_prixSponsoriseeParJour, _prixALaUneParJour=$_prixALaUneParJour');
    return prix;
  }

  // Mettre à jour le prix selon la durée et le type
  void _updatePrix() {
    if (_selectedVoiture != null) {
      final prixParJour = _getPrixParJour(_selectedVoiture);

      if (_selectedDuree != null) {
        final jours = _getNombreJours(_selectedDuree);
        final prixTotal = (prixParJour * jours).round();

        setState(() {
          _prixController.text = prixTotal.toString();
        });

        log(
          '[DEBUG] Calcul prix: $jours jours x $prixParJour FCFA = $prixTotal FCFA',
        );
      } else {
        // Afficher juste le prix par jour quand seul le type est sélectionné
        final prixFormate = prixParJour.round();
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _prixController.text = l10n.pricePerDayLabel('$prixFormate');
        });

        log('[DEBUG] Prix par jour: $prixParJour FCFA (formaté: $prixFormate)');
      }
    } else {
      setState(() {
        _prixController.text = '';
      });
    }
  }

  String get prixEnLettres {
    final prix = int.tryParse(_prixController.text) ?? 0;
    if (prix > 0) {
      return '${_formatPrixEnLettres(prix)} FCFA';
    }
    return '';
  }

  String _formatPrixEnLettres(int prix) {
    if (prix >= 1000000) {
      final millions = prix ~/ 1000000;
      final reste = prix % 1000000;
      if (reste == 0) {
        return '$millions ${millions == 1 ? "million" : "millions"}';
      } else {
        final milliers = reste ~/ 1000;
        return '$millions ${millions == 1 ? "million" : "millions"} ${milliers > 0 ? "$milliers mille" : ""}';
      }
    } else if (prix >= 1000) {
      final milliers = prix ~/ 1000;
      return '$milliers ${milliers == 1 ? "mille" : "mille"}';
    }
    return prix.toString();
  }

  Future<void> _onPayer() async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('🚀 [DEBUG] Début _onPayer - articleId: ${widget.articleId}');
    log('🚀 [DEBUG] Début _onPayer - articleId: ${widget.articleId}');

    final currentType =
        _selectedVoiture ?? (widget.isStandalone ? _pubFeatured : null);
    if (!_formKey.currentState!.validate() ||
        currentType == null ||
        _selectedDuree == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllFieldsShort)),
      );
      return;
    }

    _selectedVoiture = currentType;

    // Vérification stricte : au moins une image doit être présente
    final pubImages = _cloudinaryImageUrls.whereType<String>().toList();
    final lienValue = _linkController.text.trim();
    final lien = lienValue.isEmpty ? null : lienValue;
    if (pubImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAtLeastOneImage)),
      );
      return;
    }

    final bool isSponsorisee = currentType == _pubSponsored;
    final bool isALaUne = currentType == _pubFeatured;

    if (isSponsorisee) {
      if (_isAnyUploading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.waitUploadFinish)),
        );
        return;
      }
      if (_carNameController.text.trim().isEmpty ||
          _carYearController.text.trim().isEmpty ||
          _carLocationController.text.trim().isEmpty ||
          _carPriceController.text.trim().isEmpty ||
          _carDescriptionController.text.trim().isEmpty ||
          _carCompanyController.text.trim().isEmpty ||
          (_selectedCarFuelType == null || _selectedCarFuelType!.isEmpty) ||
          (_selectedCarModel == null || _selectedCarModel!.isEmpty) ||
          _selectedCarType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fillCarFields)),
        );
        return;
      }
    }

    if (isALaUne) {
      if (_cloudinaryImageUrls[0] == null || _cloudinaryImageUrls[0]!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.addMainImageForFeatured)),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload des médias vers Cloudinary
      if (_uploadedImages.any((file) => file != null) ||
          _uploadedVideo != null) {
        await _uploadMediaToCloudinary();
      }

      // Pour les pubs standalone, créer directement la pub et rediriger vers le paiement standard
      if (widget.isStandalone) {
        final user = FirebaseAuth.instance.currentUser;
        final idToken = await user?.getIdToken();

        // Préparation des données de publicité pour standalone
        final pubData = {
          'description': _descriptionController.text.trim().isEmpty
              ? l10n.noDescriptionAd
              : _descriptionController.text.trim(),
          'typePub': currentType,
          'duree': _selectedDuree,
          'prix': int.tryParse(_prixController.text) ?? 0,
          'moyenPaiement': _bankPayment,
          'media': pubImages, // Envoyer toutes les images uploadées
          'statut': 'en_attente',
          'vendeur': user?.uid,
          'articleId': null, // Pas d'article associé pour standalone
          'isStandalone': true, // Marquer comme standalone
          // Ajouter les données de l'offre standalone
          'titre': _carNameController.text.trim(),
          'annee': _carYearController.text.trim(),
          'descriptionOffre': _carDescriptionController.text.trim(),
          'entreprise': _carCompanyController.text.trim(),
          'localisation': _carLocationController.text.trim(),
          'prixOffre': _carPriceController.text.trim(),
          'typeMoteur': _selectedCarFuelType,
          'modele': _selectedCarModel,
          'pieceType': _selectedCarType,
          'video': _cloudinaryVideoUrl,
          'type': widget.articleType ?? 'voiture',
          'lien': lien,
        };

        // Créer la publicité standalone
        final response = await http.post(
          Uri.parse('${getBaseUrl()}/publicites/'),
          headers: {
            'Content-Type': 'application/json',
            if (idToken != null) 'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode(pubData),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _createdPubId = data['publicite']['_id'];

          // Redirection vers la page de paiement standard
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(pubId: _createdPubId!),
            ),
          );
        } else {
          log(
            '[DEBUG] Erreur création publicité standalone: ${response.statusCode} - ${response.body}',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pubRequestCreateError)),
          );
        }
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      // Utiliser uniquement un article existant (pas de création automatique ici)
      String? articleIdToUse;

      if (widget.articleId != null) {
        // Vérifier que l'article existe toujours
        final checkUrl = '${getBaseUrl()}/articles/${widget.articleId}';
        log('🔍 [DEBUG] Vérification article URL: $checkUrl');
        log('🔍 [DEBUG] Article ID: ${widget.articleId}');
        log('🔍 [DEBUG] Token: ${idToken != null ? "Présent" : "Absent"}');

        final checkResponse = await http.get(
          Uri.parse(checkUrl),
          headers: {
            'Content-Type': 'application/json',
            if (idToken != null) 'Authorization': 'Bearer $idToken',
          },
        );

        log('📡 [DEBUG] Réponse vérification: ${checkResponse.statusCode}');
        log('📡 [DEBUG] Corps réponse: ${checkResponse.body}');

        if (checkResponse.statusCode == 200) {
          articleIdToUse = widget.articleId;
          log('✅ [DEBUG] Utilisation de l\'article existant: $articleIdToUse');
        } else {
          log(
            '❌ [DEBUG] Article non trouvé - Status: ${checkResponse.statusCode}',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.articleNotExistCreateFirst)),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
        // Pour les pubs "Sponsorisée", créer automatiquement l'article
        if (_selectedVoiture == _pubSponsored) {
          log('📝 [DEBUG] Création automatique d\'article pour pub Sponsorisée');
          articleIdToUse = await _createArticle();

          if (articleIdToUse == null) {
            log('❌ [DEBUG] Échec de la création de l\'article');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.articleCreateRetryError)),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          log('✅ [DEBUG] Article créé avec succès: $articleIdToUse');
        } else {
          // Pour les autres types de pub, nécessiter un article existant
          log('⚠️ [DEBUG] Aucun articleId fourni et type de pub non-Sponsorisée');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.articleNotExistFeaturedFirst)),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Préparation des données de publicité
      final pubData = {
        'description': _descriptionController.text.trim().isEmpty
            ? l10n.noDescriptionAd
            : _descriptionController.text.trim(),
        'typePub': currentType,
        'duree': _selectedDuree,
        'prix': int.tryParse(_prixController.text) ?? 0,
        'moyenPaiement': _bankPayment,
        'media': pubImages, // Envoyer toutes les images uploadées
        'statut': 'en_attente',
        'vendeur': user?.uid,
        'articleId': articleIdToUse, // Utiliser l'article existant ou créé
        'lien': lien,
      };

      // Créer la publicité
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/publicites/'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(pubData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _createdPubId = data['publicite']['_id'];

        // Redirection vers la page de paiement par défaut (bancaire)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(pubId: _createdPubId!),
          ),
        );
      } else {
        log(
          '[DEBUG] Erreur création publicité: ${response.statusCode} - ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pubRequestCreateError)),
        );
      }
    } catch (e) {
      log('[DEBUG] Exception lors de la création de la pub: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorNetwork(e.toString()))),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePubStatutPayee() async {
    if (_createdPubId == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final response = await http.patch(
        Uri.parse('${getBaseUrl()}/publicites/$_createdPubId'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'statut': 'payee'}),
      );
      if (response.statusCode == 200) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paymentSuccessPendingValidation)),
        );
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.statusUpdateError)),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.networkOrServerError)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // LOGS DEBUG pour les listes d'images
    log(
      '[UNE][build] _cloudinaryImageUrls.length = ${_cloudinaryImageUrls.length}',
    );
    log('[UNE][build] _isUploadingImage.length = ${_isUploadingImage.length}');
    // Correction : toujours 11 éléments dans les listes
    while (_cloudinaryImageUrls.length < 11) {
      _cloudinaryImageUrls.add('');
    }
    while (_isUploadingImage.length < 11) {
      _isUploadingImage.add(false);
    }

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
                    color: Color.fromRGBO(
                      Colors.black.r.toInt(),
                      Colors.black.g.toInt(),
                      Colors.black.b.toInt(),
                      0.1,
                    ),
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
                    Text(
                      widget.isStandalone ? l10n.createAd : l10n.adRequest,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message explicatif selon le type de pub
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.isStandalone
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.isStandalone
                              ? Colors.orange.shade200
                              : Colors.blue.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.isStandalone
                                    ? Icons.campaign
                                    : Icons.article,
                                color: widget.isStandalone
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isStandalone
                                    ? l10n.standaloneAd
                                    : l10n.existingArticleAd,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: widget.isStandalone
                                      ? Colors.orange.shade700
                                      : Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.isStandalone
                                ? l10n.standaloneAdDesc
                                : widget.articleId == null
                                    ? l10n.nonExistingPubDesc
                                    : l10n.existingArticlePubDesc,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.isStandalone
                                  ? Colors.orange.shade600
                                  : widget.articleId == null
                                      ? Colors.orange.shade600
                                      : Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Indicateur de chargement de l'article (seulement si pas standalone)
                    if (!widget.isStandalone && _isLoadingArticle) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.loadingArticleInfo,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Message si article chargé (seulement si pas standalone)
                    if (!widget.isStandalone &&
                        widget.articleId != null &&
                        !_isLoadingArticle) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.articleLoadedSuccess,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Champ description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        border: const OutlineInputBorder(),
                      ),
                      // Optionnel
                    ),
                    const SizedBox(height: 20),

                    if (widget.isStandalone ||
                        (_selectedVoiture == _pubFeatured)) ...[
                      TextFormField(
                        controller: _linkController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: l10n.clickableLinkOptional,
                          hintText: l10n.linkExampleHint,
                          helperText: l10n.linkHelperText,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else
                      const SizedBox(height: 10),

                    // Type de publicité
                    if (!widget.isStandalone) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedVoiture,
                        items: voitures
                            .map(
                              (voiture) => DropdownMenuItem(
                                value: voiture,
                                child: Text(_pubTypeLabel(l10n, voiture)),
                              ),
                            )
                            .toList(),
                        decoration: InputDecoration(
                          labelText: l10n.adType,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return l10n.selectAdType;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedVoiture = value;
                            _updatePrix();
                            if (value == _pubSponsored) {
                              // Pré-remplir les champs si pas d'article existant
                              if (widget.articleId == null) {
                                // Utiliser les paramètres passés ou des valeurs par défaut
                                _carNameController.text =
                                    widget.articleTitle ?? l10n.defaultCarName;
                                _carYearController.text = widget.articleYear ??
                                    DateTime.now().year.toString();
                                _carLocationController.text =
                                    widget.articleLocation ?? l10n.defaultLocation;
                                _carPriceController.text =
                                    widget.articlePrice ?? l10n.defaultPrice;
                                _carDescriptionController.text =
                                    widget.articleDescription ??
                                        l10n.defaultCarDescription;
                                _carCompanyController.text =
                                    widget.articleCompany ??
                                        l10n.defaultCompanyName;
                                _carModelController.text =
                                    widget.articleModel ?? l10n.defaultBrand;
                                _selectedCarModel =
                                    widget.articleModel ?? 'Modèle1';
                                _selectedCarFuelType =
                                    widget.articleFuelType ?? 'Essence';
                                _selectedCarType =
                                    widget.articlePieceType ?? _conditionNew;

                                // Charger les images si fournies
                                if (widget.articleImages != null &&
                                    widget.articleImages!.isNotEmpty) {
                                  _cloudinaryImageUrls = List<String>.from(
                                    widget.articleImages!,
                                  );
                                }
                              }
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.standaloneFeaturedTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.standaloneFeaturedDesc,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Durée de la pub
                    DropdownButtonFormField<String>(
                      value: _selectedDuree,
                      items: durees
                          .map(
                            (duree) => DropdownMenuItem(
                              value: duree,
                              child: Text(_durationLabel(l10n, duree)),
                            ),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: l10n.adDuration,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return l10n.selectDuration;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedDuree = value;
                          _updatePrix(); // Recalculer le prix
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                    // Prix (non éditable)
                    TextFormField(
                      controller: _prixController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: l10n.priceFcfa,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (prixEnLettres.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          prixEnLettres,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),

                    // SECTION DYNAMIQUE : Informations concernant la voiture
                    if (_selectedVoiture == _pubSponsored) ...[
                      const Divider(height: 40, thickness: 2),
                      Text(
                        l10n.carInfoSection,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nom de la pièce/voiture
                      TextFormField(
                        controller: _carNameController,
                        decoration: InputDecoration(
                          labelText: l10n.partOrCarName,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _carYearController,
                        decoration: InputDecoration(
                          labelText: l10n.year,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterYearValidator;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _carLocationController,
                        decoration: InputDecoration(
                          labelText: l10n.defaultLocation,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterLocationValidator;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _carPriceController,
                        decoration: InputDecoration(
                          labelText: l10n.price,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterPriceValidator;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _carDescriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.carDescription,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterDescriptionValidator;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _carCompanyController,
                        decoration: InputDecoration(
                          labelText: l10n.defaultCompanyName,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterCompanyValidator;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Type moteur
                      DropdownButtonFormField<String>(
                        value: _selectedCarFuelType,
                        items: _carFuelTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(_fuelLabel(l10n, type)),
                              ),
                            )
                            .toList(),
                        decoration: InputDecoration(
                          labelText: l10n.engineType,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.selectEngineTypeValidator;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedCarFuelType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Modèle
                      DropdownButtonFormField<String>(
                        value: _selectedCarModel,
                        items: _carModels
                            .map(
                              (model) => DropdownMenuItem(
                                value: model,
                                child: Text(model),
                              ),
                            )
                            .toList(),
                        decoration: InputDecoration(
                          labelText: l10n.model,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.selectModelValidator;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedCarModel = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Type (Nouveau/Occasion)
                      DropdownButtonFormField<String>(
                        value: _selectedCarType,
                        items: _carTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(_conditionLabel(l10n, type)),
                              ),
                            )
                            .toList(),
                        decoration: InputDecoration(
                          labelText: l10n.typeLabel,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return l10n.selectTypeValidator;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedCarType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Section conditionnelle selon le type de pub
                    if (_selectedVoiture == _pubFeatured) ...[
                      Text(
                        l10n.mainFlyerImage,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.recommendedDimensions,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Upload d'une seule image pour "À la une"
                      GestureDetector(
                        onTap: () => _pickImage(0),
                        child: Container(
                          height: 260,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_cloudinaryImageUrls[0] != null &&
                                  _cloudinaryImageUrls[0]!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    color: Colors.black,
                                    child: Image.network(
                                      _cloudinaryImageUrls[0]!,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      filterQuality: FilterQuality.high,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.addMainImage,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    l10n.dimensions1080x1350,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              if (_isUploadingImage[0])
                                const Positioned.fill(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (_cloudinaryImageUrls[0] != null &&
                                  _cloudinaryImageUrls[0]!.isNotEmpty)
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _removeImage(0),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        l10n.additionalImagesOptional,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Sélection des images pour "Sponsorisée" (optionnel)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: 6, // Réduire à 6 images max
                        itemBuilder: (context, index) => GestureDetector(
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
                                if (_cloudinaryImageUrls[index] != null &&
                                    _cloudinaryImageUrls[index]!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _cloudinaryImageUrls[index]!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
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
                                if (_cloudinaryImageUrls[index] != null &&
                                    _cloudinaryImageUrls[index]!.isNotEmpty)
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
                                            padding: const EdgeInsets.all(
                                              2,
                                            ),
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
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Upload vidéo (optionnelle)
                      GestureDetector(
                        onTap: _pickVideo,
                        child: Container(
                          height: 80,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.hardEdge,
                            children: [
                              if (_uploadedVideo != null)
                                const Icon(
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
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black54,
                                  child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 35,
                                            height: 35,
                                            child: CircularProgressIndicator(
                                              value: _videoUploadProgress > 0 ? _videoUploadProgress : null,
                                              color: Colors.blue,
                                              backgroundColor: Colors.white24,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _videoUploadProgress < 0.85
                                                ? l10n.sending
                                                : l10n.processing,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${(_videoUploadProgress * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 9,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          // Barre de progression linéaire
                                          Container(
                                            width: 140,
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
                                        onTap: _removeVideo,
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
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Bouton Payer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onPayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                l10n.pay,
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
