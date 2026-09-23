// ignore_for_file: unused_field, unused_element, unused_local_variable

import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:tranoo/data/screens/paymentscreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';
import 'dart:developer';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/data/repositories/une_repository.dart';
import 'package:tranoo/data/screens/une/une_car_info_section.dart';
import 'package:tranoo/data/screens/une/une_featured_flyer.dart';
import 'package:tranoo/data/screens/une/une_labels.dart';
import 'package:tranoo/data/screens/une/une_mode_banner.dart';
import 'package:tranoo/data/screens/une/une_sponsored_media.dart';

class Une extends StatefulWidget {
  final String? articleId; // ID de l'article existant (optionnel)
  final String? articleType; // 'voiture' ou 'piece' (optionnel)
  final bool
      isStandalone; // Nouveau: true pour pub standalone, false pour pub d'article existant

  // ParamÃ¨tres pour prÃ©-remplir les champs quand l'article n'est pas encore crÃ©Ã©
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
    this.isStandalone = false, // Par dÃ©faut, ce n'est pas standalone
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
  final _uneRepo = UneRepository();

  final _formKey = GlobalKey<FormState>();
  String? _selectedVoiture;
  String? _selectedPaiement;
  String? _selectedDuree;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  // ContrÃ´leurs pour les informations de voiture
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
  String? _selectedCarModel; // ModÃ¨le

  // Ajout pour plusieurs images et vidÃ©o (comme create_sell.dart)
  List<File?> _uploadedImages = List.filled(11, null); // mobile
  List<Uint8List?> _uploadedImagesWeb = List.filled(11, null); // web
  List<String?> _cloudinaryImageUrls = List.filled(11, null);
  List<bool> _isUploadingImage = List.filled(11, false);
  File? _uploadedVideo;
  String? _cloudinaryVideoUrl;
  bool _isUploadingVideo = false;
  double _videoUploadProgress = 0.0; // Progression de l'upload vidÃ©o

  final List<String> voitures = [
    UneLabels.pubSponsored,
    UneLabels.pubFeatured,
  ];
  final List<String> moyensPaiement = [UneLabels.bankPayment, 'Mobile Money'];
  final List<String> durees = [
    UneLabels.dureeOneWeek,
    UneLabels.dureeTwoWeeks,
    UneLabels.dureeOneMonth,
    UneLabels.dureeTwoMonths,
    UneLabels.dureeThreeMonths,
  ];

  // Prix par jour pour chaque type (Ã  rÃ©cupÃ©rer du backend)
  double _prixSponsoriseeParJour = 1000.0;
  double _prixALaUneParJour = 2000.0;

  // Listes pour les dropdowns de voiture
  final List<String> _carTypes = [
    UneLabels.conditionNew,
    UneLabels.conditionUsed,
  ];
  final List<String> _carFuelTypes = [
    'Essence',
    'Gazoil',
    'Diesel',
    'Electrique',
    'Hybride',
    UneLabels.noEngine,
  ];
  final List<String> _carModels = [
    'ModÃ¨le1',
    'ModÃ¨le2',
    UneLabels.otherModel,
  ];

  final ImagePicker picker = ImagePicker();

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
  String? _createdArticleId; // ID de l'article crÃ©Ã© pendant la session

  bool get _isAnyUploading =>
      _isUploadingImage.contains(true) || _isUploadingVideo;

  @override
  void initState() {
    super.initState();
    _loadPrixConfig(); // Charger les prix depuis le backend
    if (widget.isStandalone) {
      _selectedVoiture = UneLabels.pubFeatured;
    }
    // Si on a un articleId, charger ses infos
    if (widget.articleId != null) {
      _loadArticleInfo();
    } else {
      // PrÃ©-remplir les champs avec les paramÃ¨tres passÃ©s ou des valeurs par dÃ©faut
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
          : 'ModÃ¨le1';
      _selectedCarFuelType = _carFuelTypes.contains(widget.articleFuelType)
          ? widget.articleFuelType
          : 'Essence';
      _selectedCarType = _carTypes.contains(widget.articlePieceType)
          ? widget.articlePieceType
          : UneLabels.conditionNew;

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

  // MÃ©thode pour crÃ©er un article et rÃ©cupÃ©rer son ID
  Future<String?> _createArticle() async {
    try {
      Map<String, dynamic> articleData;

      if (widget.articleType == 'piece') {
        // CrÃ©er un article piÃ¨ce
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
        log('[DEBUG] CrÃ©ation de l\'article piÃ¨ce: $articleData');
      } else {
        // CrÃ©er un article voiture
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
        log('[DEBUG] CrÃ©ation de l\'article voiture: $articleData');
      }

      final articleId = await _uneRepo.createArticle(articleData);
      log('[DEBUG] Article crÃ©Ã© avec ID: $articleId');
      return articleId;
    } on UneApiException catch (e) {
      log('[DEBUG] Erreur crÃ©ation article: $e');
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.isNetwork
                ? l10n.articleCreateNetworkError(e.toString())
                : l10n.articleCreateError,
          ),
        ),
      );
      return null;
    } catch (e) {
      log('[DEBUG] Exception crÃ©ation article: $e');
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
      final articleData = await _uneRepo.fetchArticle(widget.articleId!);
      log('[DEBUG] Article chargÃ©: $articleData');

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
            : 'ModÃ¨le1';
        _selectedCarFuelType =
            _carFuelTypes.contains(articleData['carburant'])
                ? articleData['carburant']
                : 'Essence';
        _selectedCarType = _carTypes.contains(articleData['condition'])
            ? articleData['condition']
            : UneLabels.conditionNew;

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
            : 'ModÃ¨le1';
        _selectedCarFuelType =
            _carFuelTypes.contains(articleData['typeMoteur'])
                ? articleData['typeMoteur']
                : 'Essence';
        _selectedCarType = _carTypes.contains(articleData['pieceType'])
            ? articleData['pieceType']
            : UneLabels.conditionNew;

        // Charger les images existantes
        if (articleData['photos'] != null) {
          _cloudinaryImageUrls = List<String>.from(articleData['photos']);
        }
      }

      // PrÃ©-remplir la description de la pub
      final l10n = AppLocalizations.of(context)!;
      _descriptionController.text =
          l10n.pubForTitle(articleData['titre']?.toString() ?? '');

      log('[DEBUG] Champs remplis avec les infos de l\'article');
    } on UneApiException catch (e) {
      log('[DEBUG] Erreur chargement article: $e');
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.isNetwork ? l10n.articleLoadNetworkError : l10n.articleLoadError,
          ),
        ),
      );
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
      // VÃ©rification de la taille (500 Mo max)
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
        '[DEBUG] Media uploadÃ© vers Cloudinary: $_cloudinaryImageUrls, $_cloudinaryVideoUrl',
      );
    } catch (e) {
      log('[DEBUG] Erreur upload media: $e');
      // Ne pas afficher d'erreur si c'est juste un problÃ¨me de format non supportÃ© ou de timeout
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

  // MÃ©thode pour upload web (comme dans create_sell.dart)
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
      log('[DEBUG] Chargement prix depuis UneRepository');
      final pricing = await _uneRepo.fetchPubPricing();
      if (pricing == null) {
        log('[DEBUG] Prix config non disponible â€” defaults UI');
        return;
      }
      setState(() {
        _prixSponsoriseeParJour = pricing.prixSponsoriseeParJour;
        _prixALaUneParJour = pricing.prixALaUneParJour;
      });
      log(
        '[DEBUG] Prix chargÃ©s: SponsorisÃ©e $_prixSponsoriseeParJour, Ã€ la une $_prixALaUneParJour FCFA/jour',
      );
    } catch (e) {
      log('[DEBUG] Erreur chargement prix: $e');
      // Garder le prix par dÃ©faut
    }
  }

  // Calculer le nombre de jours selon la durÃ©e
  int _getNombreJours(String? duree) {
    if (duree == null) return 0;
    switch (duree) {
      case UneLabels.dureeOneWeek:
        return 7;
      case UneLabels.dureeTwoWeeks:
        return 14;
      case UneLabels.dureeOneMonth:
        return 30;
      case UneLabels.dureeTwoMonths:
        return 60;
      case UneLabels.dureeThreeMonths:
        return 90;
      default:
        return 0;
    }
  }

  double _getPrixParJour(String? typePub) {
    if (typePub == null) return 0.0;
    double prix = 0.0;
    switch (typePub) {
      case UneLabels.pubSponsored:
        prix = _prixSponsoriseeParJour;
        break;
      case UneLabels.pubFeatured:
        prix = _prixALaUneParJour;
        break;
      default:
        prix = 0.0;
    }
    log('[DEBUG] _getPrixParJour: type=$typePub, prix=$prix, _prixSponsoriseeParJour=$_prixSponsoriseeParJour, _prixALaUneParJour=$_prixALaUneParJour');
    return prix;
  }

  // Mettre Ã  jour le prix selon la durÃ©e et le type
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
        // Afficher juste le prix par jour quand seul le type est sÃ©lectionnÃ©
        final prixFormate = prixParJour.round();
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _prixController.text = l10n.pricePerDayLabel('$prixFormate');
        });

        log('[DEBUG] Prix par jour: $prixParJour FCFA (formatÃ©: $prixFormate)');
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
    debugPrint('ðŸš€ [DEBUG] DÃ©but _onPayer - articleId: ${widget.articleId}');
    log('ðŸš€ [DEBUG] DÃ©but _onPayer - articleId: ${widget.articleId}');

    final currentType =
        _selectedVoiture ?? (widget.isStandalone ? UneLabels.pubFeatured : null);
    if (!_formKey.currentState!.validate() ||
        currentType == null ||
        _selectedDuree == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllFieldsShort)),
      );
      return;
    }

    _selectedVoiture = currentType;

    // VÃ©rification stricte : au moins une image doit Ãªtre prÃ©sente
    final pubImages = _cloudinaryImageUrls.whereType<String>().toList();
    final lienValue = _linkController.text.trim();
    final lien = lienValue.isEmpty ? null : lienValue;
    if (pubImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAtLeastOneImage)),
      );
      return;
    }

    final bool isSponsorisee = currentType == UneLabels.pubSponsored;
    final bool isALaUne = currentType == UneLabels.pubFeatured;

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
      // Upload des mÃ©dias vers Cloudinary
      if (_uploadedImages.any((file) => file != null) ||
          _uploadedVideo != null) {
        await _uploadMediaToCloudinary();
      }

      // Pour les pubs standalone, crÃ©er directement la pub et rediriger vers le paiement standard
      if (widget.isStandalone) {
        final user = FirebaseAuth.instance.currentUser;

        // PrÃ©paration des donnÃ©es de publicitÃ© pour standalone
        final pubData = {
          'description': _descriptionController.text.trim().isEmpty
              ? l10n.noDescriptionAd
              : _descriptionController.text.trim(),
          'typePub': currentType,
          'duree': _selectedDuree,
          'prix': int.tryParse(_prixController.text) ?? 0,
          'moyenPaiement': UneLabels.bankPayment,
          'media': pubImages, // Envoyer toutes les images uploadÃ©es
          'statut': 'en_attente',
          'vendeur': user?.uid,
          'articleId': null, // Pas d'article associÃ© pour standalone
          'isStandalone': true, // Marquer comme standalone
          // Ajouter les donnÃ©es de l'offre standalone
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

        // CrÃ©er la publicitÃ© standalone
        try {
          _createdPubId = await _uneRepo.createPublicite(pubData);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(pubId: _createdPubId!),
            ),
          );
        } on UneApiException catch (e) {
          log('[DEBUG] Erreur crÃ©ation publicitÃ© standalone: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pubRequestCreateError)),
          );
        }
        return;
      }

      final user = FirebaseAuth.instance.currentUser;

      // Utiliser uniquement un article existant (pas de crÃ©ation automatique ici)
      String? articleIdToUse;

      if (widget.articleId != null) {
        // VÃ©rifier que l'article existe toujours
        log('ðŸ” [DEBUG] VÃ©rification article ID: ${widget.articleId}');

        final exists = await _uneRepo.articleExists(widget.articleId!);
        if (exists) {
          articleIdToUse = widget.articleId;
          log('âœ… [DEBUG] Utilisation de l\'article existant: $articleIdToUse');
        } else {
          log('âŒ [DEBUG] Article non trouvÃ©');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.articleNotExistCreateFirst)),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
        // Pour les pubs "SponsorisÃ©e", crÃ©er automatiquement l'article
        if (_selectedVoiture == UneLabels.pubSponsored) {
          log('ðŸ“ [DEBUG] CrÃ©ation automatique d\'article pour pub SponsorisÃ©e');
          articleIdToUse = await _createArticle();

          if (articleIdToUse == null) {
            log('âŒ [DEBUG] Ã‰chec de la crÃ©ation de l\'article');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.articleCreateRetryError)),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          log('âœ… [DEBUG] Article crÃ©Ã© avec succÃ¨s: $articleIdToUse');
        } else {
          // Pour les autres types de pub, nÃ©cessiter un article existant
          log('âš ï¸ [DEBUG] Aucun articleId fourni et type de pub non-SponsorisÃ©e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.articleNotExistFeaturedFirst)),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // PrÃ©paration des donnÃ©es de publicitÃ©
      final pubData = {
        'description': _descriptionController.text.trim().isEmpty
            ? l10n.noDescriptionAd
            : _descriptionController.text.trim(),
        'typePub': currentType,
        'duree': _selectedDuree,
        'prix': int.tryParse(_prixController.text) ?? 0,
        'moyenPaiement': UneLabels.bankPayment,
        'media': pubImages, // Envoyer toutes les images uploadÃ©es
        'statut': 'en_attente',
        'vendeur': user?.uid,
        'articleId': articleIdToUse, // Utiliser l'article existant ou crÃ©Ã©
        'lien': lien,
      };

      // CrÃ©er la publicitÃ©
      try {
        _createdPubId = await _uneRepo.createPublicite(pubData);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(pubId: _createdPubId!),
          ),
        );
      } on UneApiException catch (e) {
        log('[DEBUG] Erreur crÃ©ation publicitÃ©: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pubRequestCreateError)),
        );
      }
    } catch (e) {
      log('[DEBUG] Exception lors de la crÃ©ation de la pub: $e');
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
      final ok = await _uneRepo.updatePubliciteStatut(
        _createdPubId!,
        statut: 'payee',
      );
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? l10n.paymentSuccessPendingValidation
                : l10n.statusUpdateError,
          ),
        ),
      );
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
    // Correction : toujours 11 Ã©lÃ©ments dans les listes
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

                    UneModeBanner(
                      isStandalone: widget.isStandalone,
                      hasArticleId: widget.articleId != null,
                      isLoadingArticle: _isLoadingArticle,
                    ),
                    const SizedBox(height: 20),

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
                        (_selectedVoiture == UneLabels.pubFeatured)) ...[
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

                    // Type de publicitÃ©
                    if (!widget.isStandalone) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedVoiture,
                        items: voitures
                            .map(
                              (voiture) => DropdownMenuItem(
                                value: voiture,
                                child: Text(UneLabels.pubType(l10n, voiture)),
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
                            if (value == UneLabels.pubSponsored) {
                              // PrÃ©-remplir les champs si pas d'article existant
                              if (widget.articleId == null) {
                                // Utiliser les paramÃ¨tres passÃ©s ou des valeurs par dÃ©faut
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
                                    widget.articleModel ?? 'ModÃ¨le1';
                                _selectedCarFuelType =
                                    widget.articleFuelType ?? 'Essence';
                                _selectedCarType =
                                    widget.articlePieceType ?? UneLabels.conditionNew;

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

                    // DurÃ©e de la pub
                    DropdownButtonFormField<String>(
                      value: _selectedDuree,
                      items: durees
                          .map(
                            (duree) => DropdownMenuItem(
                              value: duree,
                              child: Text(UneLabels.duration(l10n, duree)),
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

                    // Prix (non Ã©ditable)
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

                    if (_selectedVoiture == UneLabels.pubSponsored)
                      UneCarInfoSection(
                        nameController: _carNameController,
                        yearController: _carYearController,
                        locationController: _carLocationController,
                        priceController: _carPriceController,
                        descriptionController: _carDescriptionController,
                        companyController: _carCompanyController,
                        fuelTypes: _carFuelTypes,
                        models: _carModels,
                        types: _carTypes,
                        selectedFuelType: _selectedCarFuelType,
                        selectedModel: _selectedCarModel,
                        selectedType: _selectedCarType,
                        onFuelChanged: (value) {
                          setState(() => _selectedCarFuelType = value);
                        },
                        onModelChanged: (value) {
                          setState(() => _selectedCarModel = value);
                        },
                        onTypeChanged: (value) {
                          setState(() => _selectedCarType = value);
                        },
                      ),

                    if (_selectedVoiture == UneLabels.pubFeatured)
                      UneFeaturedFlyer(
                        imageUrl: _cloudinaryImageUrls[0],
                        isUploading: _isUploadingImage[0],
                        onPick: () => _pickImage(0),
                        onRemove: () => _removeImage(0),
                      )
                    else
                      UneSponsoredMedia(
                        imageUrls: _cloudinaryImageUrls,
                        isUploadingImage: _isUploadingImage,
                        onPickImage: _pickImage,
                        onRemoveImage: _removeImage,
                        uploadedVideo: _uploadedVideo,
                        cloudinaryVideoUrl: _cloudinaryVideoUrl,
                        isUploadingVideo: _isUploadingVideo,
                        videoUploadProgress: _videoUploadProgress,
                        onPickVideo: _pickVideo,
                        onRemoveVideo: _removeVideo,
                      ),

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
