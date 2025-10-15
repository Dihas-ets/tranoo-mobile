// ignore_for_file: unused_field, unused_element, unused_local_variable

import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:tranoo/data/screens/paymentscreen.dart';

import 'mobilemoneypaymentscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tranoo/utils/cloudinary_upload.dart';
import 'dart:developer';
import 'package:tranoo/services/user_service.dart';

class Une extends StatefulWidget {
  final String? articleId; // ID de l'article existant (optionnel)
  final String? articleType; // 'voiture' ou 'piece' (optionnel)

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
  final _formKey = GlobalKey<FormState>();
  String? _selectedVoiture;
  String? _selectedPaiement;
  String? _selectedDuree;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

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

  final List<String> voitures = ['Sponsorisée', 'À la une'];
  final List<String> moyensPaiement = ['Paiement bancaire', 'Mobile Money'];
  final List<String> durees = [
    '1 semaine',
    '2 semaines', 
    '1 mois',
    '2 mois',
    '3 mois',
  ];
  
  // Prix par jour pour chaque type (à récupérer du backend)
  double _prixSponsoriseeParJour = 1000.0;
  double _prixALaUneParJour = 2000.0;

  // Listes pour les dropdowns de voiture
  final List<String> _carTypes = ['Nouveau', 'Occasion'];
  final List<String> _carFuelTypes = [
    'Essence',
    'Gazoil',
    'Diesel',
    'Electrique',
    'Hybride',
    'Aucun',
  ];
  final List<String> _carModels = ['Modèle1', 'Modèle2', 'Autre'];

  final ImagePicker picker = ImagePicker();

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
    // Si on a un articleId, charger ses infos
    if (widget.articleId != null) {
      _loadArticleInfo();
    } else {
      // Pré-remplir les champs avec les paramètres passés ou des valeurs par défaut
      _carNameController.text = widget.articleTitle ?? 'Nom de la voiture';
      _carYearController.text =
          widget.articleYear ?? DateTime.now().year.toString();
      _carLocationController.text = widget.articleLocation ?? 'Localisation';
      _carPriceController.text = widget.articlePrice ?? 'Prix';
      _carDescriptionController.text =
          widget.articleDescription ?? 'Description de la voiture';
      _carCompanyController.text =
          widget.articleCompany ?? 'Nom de l\'entreprise';
      _carModelController.text = widget.articleModel ?? 'Marque';
      _selectedCarModel = _carModels.contains(widget.articleModel) ? widget.articleModel : 'Modèle1';
      _selectedCarFuelType = _carFuelTypes.contains(widget.articleFuelType) ? widget.articleFuelType : 'Essence';
      _selectedCarType = _carTypes.contains(widget.articlePieceType) ? widget.articlePieceType : 'Nouveau';

      // Charger les images si fournies
      if (widget.articleImages != null && widget.articleImages!.isNotEmpty) {
        _cloudinaryImageUrls = List<String>.from(widget.articleImages!);
      }
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création de l\'article.')),
        );
        return null;
      }
    } catch (e) {
      log('[DEBUG] Exception création article: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur réseau lors de la création de l\'article: $e'),
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
          _selectedCarModel = _carModels.contains(articleData['modele']) ? articleData['modele'] : 'Modèle1';
          _selectedCarFuelType = _carFuelTypes.contains(articleData['carburant']) ? articleData['carburant'] : 'Essence';
          _selectedCarType = _carTypes.contains(articleData['condition']) ? articleData['condition'] : 'Nouveau';

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
          _selectedCarModel = _carModels.contains(articleData['modele']) ? articleData['modele'] : 'Modèle1';
          _selectedCarFuelType = _carFuelTypes.contains(articleData['typeMoteur']) ? articleData['typeMoteur'] : 'Essence';
          _selectedCarType = _carTypes.contains(articleData['pieceType']) ? articleData['pieceType'] : 'Nouveau';

          // Charger les images existantes
          if (articleData['photos'] != null) {
            _cloudinaryImageUrls = List<String>.from(articleData['photos']);
          }
        }

        // Pré-remplir la description de la pub
        _descriptionController.text = 'Publicité pour ${articleData['titre']}';

        log('[DEBUG] Champs remplis avec les infos de l\'article');
      } else {
        log('[DEBUG] Erreur chargement article: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement de l\'article')),
        );
      }
    } catch (e) {
      log('[DEBUG] Exception chargement article: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur réseau lors du chargement de l\'article'),
        ),
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

  Future<void> _uploadMediaToCloudinary() async {
    setState(() {
      _isUploadingImage = List.generate(
        _uploadedImages.length,
        (index) => true,
      );
      _isUploadingVideo = true;
    });

    try {
      _cloudinaryImageUrls.clear();
      for (int i = 0; i < _uploadedImages.length; i++) {
        if (_uploadedImages[i] != null) {
          final url = await uploadImageToCloudinary(_uploadedImages[i]!);
          if (url != null) {
            _cloudinaryImageUrls[i] = url;
          }
        }
      }
      if (_uploadedVideo != null) {
        final url = await uploadImageToCloudinary(_uploadedVideo!);
        if (url != null) {
          _cloudinaryVideoUrl = url;
        }
      }
      log(
        '[DEBUG] Media uploadé vers Cloudinary: $_cloudinaryImageUrls, $_cloudinaryVideoUrl',
      );
    } catch (e) {
      log('[DEBUG] Erreur upload media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload des médias: $e')),
      );
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
      // Utiliser la même logique que uploadImageToCloudinary mais pour les bytes
      final url = await uploadImageToCloudinary(
        File('temp.jpg'),
      ); // Placeholder
      return url;
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
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      log('[DEBUG] Réponse prix: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prixSponsoriseeParJour = (data['prixSponsoriseeParJour'] ?? 1000.0).toDouble();
          _prixALaUneParJour = (data['prixALaUneParJour'] ?? 2000.0).toDouble();
        });
        log('[DEBUG] Prix chargés: Sponsorisée $_prixSponsoriseeParJour, À la une $_prixALaUneParJour FCFA/jour');
      } else {
        log('[DEBUG] Erreur HTTP: ${response.statusCode}');
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
      case '1 semaine': return 7;
      case '2 semaines': return 14;
      case '1 mois': return 30;
      case '2 mois': return 60;
      case '3 mois': return 90;
      default: return 0;
    }
  }
  
  // Récupérer le prix par jour selon le type de pub
  double _getPrixParJour(String? typePub) {
    if (typePub == null) return 0.0;
    switch (typePub) {
      case 'Sponsorisée': return _prixSponsoriseeParJour;
      case 'À la une': return _prixALaUneParJour;
      default: return 0.0;
    }
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
        
        log('[DEBUG] Calcul prix: $jours jours x $prixParJour FCFA = $prixTotal FCFA');
      } else {
        // Afficher juste le prix par jour quand seul le type est sélectionné
        setState(() {
          _prixController.text = '${prixParJour.round()}/jour';
        });
        
        log('[DEBUG] Prix par jour: $prixParJour FCFA');
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
    debugPrint('🚀 [DEBUG] Début _onPayer - articleId: ${widget.articleId}');
    log('🚀 [DEBUG] Début _onPayer - articleId: ${widget.articleId}');
    
    if (!_formKey.currentState!.validate() ||
        _selectedVoiture == null ||
        _selectedDuree == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    // Vérification stricte : au moins une image doit être présente
    final pubImages = _cloudinaryImageUrls.whereType<String>().toList();
    if (pubImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une image.'),
        ),
      );
      return;
    }

    // Validation spécifique pour les annonces sponsorisées
    if (_selectedVoiture == 'Sponsorisée') {
      if (_isAnyUploading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez attendre la fin de l\'upload.'),
          ),
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
          const SnackBar(
            content: Text('Veuillez remplir tous les champs de la voiture.'),
          ),
        );
        return;
      }
    }
    
    // Validation pour "À la une" - image principale obligatoire
    if (_selectedVoiture == 'À la une') {
      if (_cloudinaryImageUrls[0] == null || _cloudinaryImageUrls[0]!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez ajouter une image principale pour "À la une".'),
          ),
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
          log('❌ [DEBUG] Article non trouvé - Status: ${checkResponse.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cet article n\'existe pas, veuillez le créer et après validation par l\'admin vous pourrez le mettre en avant.',
              ),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
          log('⚠️ [DEBUG] Aucun articleId fourni - widget.articleId est null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cet article n\'existe pas, veuillez le créer et après validation par l\'admin vous pourrez le mettre en avant.',
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Préparation des données de publicité
      final pubData = {
        'description': _descriptionController.text.trim(),
        'typePub': _selectedVoiture,
        'duree': _selectedDuree,
        'prix': int.tryParse(_prixController.text) ?? 0,
        'moyenPaiement': 'Paiement bancaire',
        'media': pubImages, // Envoyer toutes les images uploadées
        'statut': 'en_attente',
        'vendeur': user?.uid,
        'articleId': articleIdToUse, // Utiliser l'article existant ou créé
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
          SnackBar(content: Text('Erreur lors de la création de la demande.')),
        );
      }
    } catch (e) {
      log('[DEBUG] Exception lors de la création de la pub: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau ou serveur: $e')));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Paiement réussi, en attente de validation admin. Vous recevrez une notification dès validation.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour du statut.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau ou serveur.')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Demande de pub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Indicateur de chargement de l'article
                    if (_isLoadingArticle) ...[
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
                                'Chargement des informations de l\'article...',
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

                    // Message si article chargé
                    if (widget.articleId != null && !_isLoadingArticle) ...[
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
                                'Article chargé avec succès ! Vous pouvez maintenant faire une publicité pour cet article.',
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
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un type';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedVoiture = value;
                          _updatePrix(); // Calculer le prix dynamiquement
                          // Met à jour le prix selon le type de pub
                          if (value == 'Sponsorisée') {
                            // Pré-remplir les champs si pas d'article existant
                            if (widget.articleId == null) {
                              // Utiliser les paramètres passés ou des valeurs par défaut
                              _carNameController.text =
                                  widget.articleTitle ?? 'Nom de la voiture';
                              _carYearController.text =
                                  widget.articleYear ??
                                  DateTime.now().year.toString();
                              _carLocationController.text =
                                  widget.articleLocation ?? 'Localisation';
                              _carPriceController.text =
                                  widget.articlePrice ?? 'Prix';
                              _carDescriptionController.text =
                                  widget.articleDescription ??
                                  'Description de la voiture';
                              _carCompanyController.text =
                                  widget.articleCompany ??
                                  'Nom de l\'entreprise';
                              _carModelController.text =
                                  widget.articleModel ?? 'Marque';
                              _selectedCarModel =
                                  widget.articleModel ?? 'Modèle1';
                              _selectedCarFuelType =
                                  widget.articleFuelType ?? 'Essence';
                              _selectedCarType =
                                  widget.articlePieceType ?? 'Nouveau';

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

                    // Durée de la pub
                    DropdownButtonFormField<String>(
                      value: _selectedDuree,
                      items:
                          durees
                              .map(
                                (duree) => DropdownMenuItem(
                                  value: duree,
                                  child: Text(duree),
                                ),
                              )
                              .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Durée de la publicité',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une durée';
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
                      decoration: const InputDecoration(
                        labelText: 'Prix (FCFA)',
                        border: OutlineInputBorder(),
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
                    if (_selectedVoiture == 'Sponsorisée') ...[
                      const Divider(height: 40, thickness: 2),
                      const Text(
                        'Informations concernant la voiture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nom de la pièce/voiture
                      TextFormField(
                        controller: _carNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom de la pièce/voiture',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer le nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Année
                      TextFormField(
                        controller: _carYearController,
                        decoration: const InputDecoration(
                          labelText: 'Année',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer l\'année';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Localisation
                      TextFormField(
                        controller: _carLocationController,
                        decoration: const InputDecoration(
                          labelText: 'Localisation',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer la localisation';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Prix
                      TextFormField(
                        controller: _carPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Prix',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer le prix';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description
                      TextFormField(
                        controller: _carDescriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description de la voiture',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer une description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Entreprise
                      TextFormField(
                        controller: _carCompanyController,
                        decoration: const InputDecoration(
                          labelText: 'Nom de l\'entreprise',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer le nom de l\'entreprise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Type moteur
                      DropdownButtonFormField<String>(
                        value: _selectedCarFuelType,
                        items:
                            _carFuelTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Type de moteur',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner le type de moteur';
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
                        items:
                            _carModels
                                .map(
                                  (model) => DropdownMenuItem(
                                    value: model,
                                    child: Text(model),
                                  ),
                                )
                                .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Modèle',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner le modèle';
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
                        items:
                            _carTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner le type';
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
                    if (_selectedVoiture == 'À la une') ...[
                      const Text(
                        'Image principale (flyer)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      
                      // Upload d'une seule image pour "À la une"
                      GestureDetector(
                        onTap: () => _pickImage(0),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_cloudinaryImageUrls[0] != null &&
                                  _cloudinaryImageUrls[0]!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _cloudinaryImageUrls[0]!,
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
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Ajouter image principale',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              if (_isUploadingImage[0])
                                const Positioned.fill(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (_cloudinaryImageUrls[0] != null &&
                                  _cloudinaryImageUrls[0]!.isNotEmpty)
                                const Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Images supplémentaires (optionnel)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Sélection des images pour "Sponsorisée" (optionnel)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      const SizedBox(height: 16),

                      // Upload vidéo (optionnelle)
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
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                                : const Text(
                                  'Payer',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
