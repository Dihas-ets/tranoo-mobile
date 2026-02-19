import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tranoo/data/screens/cars_info.dart';
import 'package:tranoo/data/screens/voitures.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/mastervacpage.dart';
import 'package:tranoo/utils/role_redirect.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/data/screens/tarif.dart';
import 'package:tranoo/data/screens/transit.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';
import 'package:tranoo/data/screens/movie.dart';
import 'package:lottie/lottie.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/data/screens/tricycle/tricycle_home.dart';

class Article {
  final String id;
  final String title;
  final String year;
  final String description;
  final String company;
  final String location;
  final String price;
  final List<String> images;
  final String? fuelType;
  final String? model;
  final String? pieceType;
  final String? video;
  final String? condition;
  final String? statut;

  Article({
    required this.id,
    required this.title,
    required this.year,
    required this.description,
    required this.company,
    required this.location,
    required this.price,
    required this.images,
    this.fuelType,
    this.model,
    this.pieceType,
    this.video,
    this.condition,
    this.statut,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id'] ?? '',
      title: json['titre'] ?? '',
      year: json['annee'] ?? '',
      description: json['description'] ?? '',
      company: json['entreprise'] ?? '',
      location: json['localisation'] ?? '',
      price: json['prix']?.toString() ?? '',
      images:
          (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      fuelType: json['typeMoteur'],
      model: json['modele']?.toString(),
      pieceType: json['pieceType'],
      video: json['video'],
      condition: json['condition'],
      statut: json['statut'],
    );
  }
}

class ArticleVoiture {
  final String id;
  final String titre;
  final String description;
  final String marque;
  final String modele;
  final String annee;
  final String prix;
  final String? condition;
  final String? boiteVitesse;
  final String? carburant;
  final String? climatiseur;
  final String? distance;
  final String? sieges;
  final String? portes;
  final String? cylindre;
  final List<String> images;
  final String? video;
  final String? entreprise;
  final String? statut;

  ArticleVoiture({
    required this.id,
    required this.titre,
    required this.description,
    required this.marque,
    required this.modele,
    required this.annee,
    required this.prix,
    this.condition,
    this.boiteVitesse,
    this.carburant,
    this.climatiseur,
    this.distance,
    this.sieges,
    this.portes,
    this.cylindre,
    required this.images,
    this.video,
    this.entreprise,
    this.statut,
  });

  factory ArticleVoiture.fromJson(Map<String, dynamic> json) {
    return ArticleVoiture(
      id: json['_id'] ?? '',
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      marque: json['marque'] ?? '',
      modele: json['modele']?.toString() ?? '',
      annee: json['annee'] ?? '',
      prix: json['prix']?.toString() ?? '',
      condition: json['condition'],
      boiteVitesse: json['boiteVitesse'],
      carburant: json['carburant'],
      climatiseur: json['climatiseur'],
      distance: json['distance'],
      sieges: json['sieges'],
      portes: json['portes'],
      cylindre: json['cylindre'],
      images:
          (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      video: json['video'],
      entreprise: json['entreprise'],
      statut: json['statut'],
    );
  }
}

List<ArticleVoiture> voituresRecommandees = [];
bool isLoadingVoitures = true;
String? errorVoitures;

// Ajout : modèle Pub pour la récupération des publicités
class Pub {
  final String id;
  final String description;
  final String typePub;
  final String statut;
  final String duree;
  final DateTime dateDemande;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final List<String> media;
  final String? lien;

  Pub({
    required this.id,
    required this.description,
    required this.typePub,
    required this.statut,
    required this.duree,
    required this.dateDemande,
    this.dateDebut,
    this.dateFin,
    required this.media,
    this.lien,
  });

  factory Pub.fromJson(Map<String, dynamic> json) {
    return Pub(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      typePub: json['typePub'] ?? '',
      statut: json['statut'] ?? '',
      duree: json['duree'] ?? '',
      dateDemande:
          DateTime.tryParse(json['dateDemande'] ?? '') ?? DateTime.now(),
      dateDebut: DateTime.tryParse(json['dateDebut'] ?? ''),
      dateFin: DateTime.tryParse(json['dateFin'] ?? ''),
      media: (json['media'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lien: json['lien'],
    );
  }
}

class Marque extends StatefulWidget {
  const Marque({super.key});

  @override
  State<Marque> createState() => _MarqueState();
}

class _MarqueState extends State<Marque> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late PageController _pageController;
  late TabController _tabController;
  Timer? _carouselTimer;
  final UserService _userService = UserService();
  late int _marqueTabIndex;
  late int _modeleTabIndex;
  late int _statistiquesTabIndex;
  late int _localisationTabIndex;
  late int _budgetTabIndex;
  List<Article> articlesPieces = [];
  bool isLoadingPieces = true;
  String? errorPieces;
  List<Pub> pubsSponsorisees = [];
  List<Pub> pubsALaUne = [];
  bool isLoadingPubs = true;
  String? errorPubs;

  // Ajout d'un contrôleur et d'une variable pour la recherche
  final TextEditingController _searchPieceController = TextEditingController();
  String _searchPieceText = '';
  // Recherche globale (barre en haut)
  final TextEditingController _searchGlobalController = TextEditingController();
  String _searchGlobalText = '';

  final _logger = Logger('MarquePage');

  // Vérifie si une publicité est encore valide selon sa durée
  bool _isPubValid(Pub pub) {
    _logger.info('[DEBUG] 🔍 Vérification pub ${pub.id}: statut=${pub.statut}');

    if (pub.statut != 'valide') {
      _logger.info('[DEBUG] 🔍 Pub ${pub.id} rejetée: statut=${pub.statut}');
      return false;
    }

    final now = DateTime.now();

    // Utiliser dateFin si disponible, sinon calculer à partir de dateDebut ou dateDemande
    if (pub.dateFin != null) {
      final isValid = now.isBefore(pub.dateFin!);
      _logger.info(
        '[DEBUG] 🔍 Pub ${pub.id} avec dateFin: ${pub.dateFin}, maintenant: $now, valide: $isValid',
      );
      return isValid;
    }

    final dateDebut = pub.dateDebut ?? pub.dateDemande;
    _logger.info(
      '[DEBUG] 🔍 Pub ${pub.id} sans dateFin, utilise dateDebut: $dateDebut',
    );

    // Conversion de la durée en jours
    int dureeJours;
    switch (pub.duree.toLowerCase()) {
      case '1 semaine':
        dureeJours = 7;
        break;
      case '2 semaines':
        dureeJours = 14;
        break;
      case '1 mois':
        dureeJours = 30;
        break;
      case '2 mois':
        dureeJours = 60;
        break;
      case '3 mois':
        dureeJours = 90;
        break;
      default:
        dureeJours = 7; // Par défaut 1 semaine
    }

    final dateFin = dateDebut.add(Duration(days: dureeJours));
    final isValid = now.isBefore(dateFin);
    _logger.info(
      '[DEBUG] 🔍 Pub ${pub.id} calculée: dateDebut=$dateDebut, durée=${pub.duree} ($dureeJours jours), dateFin=$dateFin, valide=$isValid',
    );
    return isValid;
  }

  // Filtres
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedLocation;
  double? _budgetMin;
  double? _budgetMax;

  // Comptage des vues locales par article
  Map<String, int> _vehicleClickCounts = {};

  @override
  void initState() {
    super.initState();

    // Initialisation des indices des onglets
    // On ne garde que le rôle acheteur
    _marqueTabIndex = 0;
    _modeleTabIndex = 1;
    _localisationTabIndex = 2;
    _budgetTabIndex = 3;
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      setState(() {});
    });

    _pageController = PageController(initialPage: 0);
    _searchGlobalController.addListener(() {
      setState(() {
        _searchGlobalText = _searchGlobalController.text.trim();
      });
    });

    // Configuration du carrousel automatique
    _startCarouselTimer();
    fetchArticlesPieces();
    fetchVoituresRecommandees();
    fetchPubs();
    fetchPubsSponsorisees();
    _loadVehicleClickStats();
  }

  void _reloadAll() {
    // Réinitialiser la recherche
    _searchGlobalController.clear();
    _searchGlobalText = '';

    // Réinitialiser les filtres
    _selectedBrand = null;
    _selectedModel = null;
    _selectedLocation = null;
    _budgetMin = null;
    _budgetMax = null;

    // Recharger les données
    fetchArticlesPieces();
    fetchVoituresRecommandees();
    fetchPubs();
    fetchPubsSponsorisees();
    setState(() {});
  }

  Future<void> fetchArticlesPieces() async {
    setState(() {
      isLoadingPieces = true;
      errorPieces = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url =
          getBaseUrl() + '/public/articles?type=piece&statut=en_ligne&vendu=false';
      _logger.info('[DEBUG] URL pièces: $url');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final body = response.body;
        try {
          final List<dynamic> data = json.decode(body);
          if (!mounted) return;
          final allPieces = data.map((e) => Article.fromJson(e)).toList();
          final piecesFiltered = allPieces
              .where((p) => (p.statut ?? 'en_ligne') != 'vendu')
              .toList();

          _logger.info('[DEBUG] Total pièces reçues: ${allPieces.length}');
          _logger.info(
            '[DEBUG] Pièces après filtrage vendu: ${piecesFiltered.length}',
          );

          // Log des statuts pour déboguer
          for (var p in allPieces) {
            if ((p.statut ?? 'en_ligne') == 'vendu') {
              _logger.info(
                '[DEBUG] Pièce vendue trouvée: ${p.title} - Statut: ${p.statut}',
              );
            }
          }

          setState(() {
            articlesPieces = piecesFiltered;
            isLoadingPieces = false;
          });
        } catch (e) {
          _logger.info('[DEBUG] Erreur de décodage JSON: $e');
          if (!mounted) return;
          setState(() {
            errorPieces = 'Erreur de format de données';
            isLoadingPieces = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          errorPieces = 'Erreur lors du chargement des pièces';
          isLoadingPieces = false;
        });
      }
    } catch (e) {
      _logger.info('[DEBUG] Exception fetchArticlesPieces: $e');
      if (!mounted) return;
      setState(() {
        errorPieces = 'Erreur réseau';
        isLoadingPieces = false;
      });
    }
  }

  Future<void> _loadVehicleClickStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('vehicle_click_counts');
      if (raw == null) return;
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _vehicleClickCounts = parsed.map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        );
      });
    } catch (e) {
      _logger.warning('[STATS] Impossible de charger les clics locaux: $e');
    }
  }

  Future<void> _saveVehicleClickStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'vehicle_click_counts',
        jsonEncode(_vehicleClickCounts),
      );
    } catch (e) {
      _logger.warning('[STATS] Impossible de sauvegarder les clics: $e');
    }
  }

  void _recordVehicleInteraction(String articleId) {
    if (articleId.isEmpty) return;
    setState(() {
      _vehicleClickCounts[articleId] =
          (_vehicleClickCounts[articleId] ?? 0) + 1;
    });
    _saveVehicleClickStats();
  }

  Widget _buildViewBadge(String articleId) {
    final views = _vehicleClickCounts[articleId] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            views.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  List<ArticleVoiture> _applyFilters(List<ArticleVoiture> source) {
    return source.where((v) {
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        if (!v.marque.toLowerCase().contains(_selectedBrand!.toLowerCase())) {
          return false;
        }
      }
      if (_selectedModel != null && _selectedModel!.isNotEmpty) {
        if (!v.modele.toLowerCase().contains(_selectedModel!.toLowerCase())) {
          return false;
        }
      }
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        final loc =
            ((v.entreprise ?? '') + ' ' + (v.description)).toLowerCase();
        if (!loc.contains(_selectedLocation!.toLowerCase()) &&
            !(v.titre.toLowerCase().contains(
                  _selectedLocation!.toLowerCase(),
                ))) {
          // fallback: try titre
          return false;
        }
      }
      if (_budgetMin != null || _budgetMax != null) {
        final price =
            double.tryParse(v.prix.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (_budgetMin != null && price < _budgetMin!) return false;
        if (_budgetMax != null && price > _budgetMax!) return false;
      }
      return true;
    }).toList();
  }

  Future<void> fetchVoituresRecommandees() async {
    setState(() {
      isLoadingVoitures = true;
      errorVoitures = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url =
          getBaseUrl() + '/public/articles?type=voiture&statut=en_ligne&vendu=false';
      _logger.info('[DEBUG] URL voitures: $url');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (!mounted) return;
        final allVoitures =
            data.map((e) => ArticleVoiture.fromJson(e)).toList();
        final voituresFiltered = allVoitures
            .where((v) => (v.statut ?? 'en_ligne') != 'vendu')
            .toList();

        _logger.info('[DEBUG] Total voitures reçues: ${allVoitures.length}');
        _logger.info(
          '[DEBUG] Voitures après filtrage vendu: ${voituresFiltered.length}',
        );

        // Log des statuts pour déboguer
        for (var v in allVoitures) {
          if ((v.statut ?? 'en_ligne') == 'vendu') {
            _logger.info(
              '[DEBUG] Voiture vendue trouvée: ${v.titre} - Statut: ${v.statut}',
            );
          }
        }

        setState(() {
          voituresRecommandees = voituresFiltered;
          isLoadingVoitures = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorVoitures = 'Erreur lors du chargement des voitures';
          isLoadingVoitures = false;
        });
      }
    } catch (e) {
      _logger.info('[DEBUG] Exception fetchVoituresRecommandees: $e');
      if (!mounted) return;
      setState(() {
        errorVoitures = 'Erreur réseau';
        isLoadingVoitures = false;
      });
    }
  }

  Future<void> fetchPubs() async {
    setState(() {
      isLoadingPubs = true;
      errorPubs = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url = getBaseUrl() + '/public/publicites?statut=valide';
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final pubs = data.map((e) => Pub.fromJson(e)).toList();
        if (!mounted) return;
        setState(() {
          pubsALaUne = pubs
              .where((p) => p.typePub == 'À la une' && _isPubValid(p))
              .toList();
          _logger.info('[DEBUG] 📺 Total pubs reçues: ${pubs.length}');
          _logger.info(
            '[DEBUG] 📺 Publicités À la une: ${pubsALaUne.length} valides sur ${pubs.where((p) => p.typePub == 'À la une').length} totales',
          );
          for (var pub in pubs.where((p) => p.typePub == 'À la une')) {
            final isValid = _isPubValid(pub);
            _logger.info(
              '[DEBUG] 📺 Pub ${pub.id}: statut=${pub.statut}, dateDebut=${pub.dateDebut}, dateFin=${pub.dateFin}, valide=$isValid',
            );
            if (!isValid && pub.statut == 'valide') {
              _logger.info(
                '[DEBUG] 📺 Pub ${pub.id} rejetée pour expiration - maintenant: ${DateTime.now()}, dateFin: ${pub.dateFin}',
              );
            }
          }
          isLoadingPubs = false;
          // Redémarrer le timer si nécessaire
          if (pubsALaUne.isNotEmpty) {
            _startCarouselTimer();
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorPubs = 'Erreur lors du chargement des publicités';
          isLoadingPubs = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorPubs = 'Erreur réseau';
        isLoadingPubs = false;
      });
    }
  }

  Future<void> fetchPubsSponsorisees() async {
    setState(() {
      isLoadingPubs = true;
      errorPubs = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url =
          getBaseUrl() + '/public/publicites?typePub=Sponsorisée&statut=valide';
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final pubs = data.map((e) => Pub.fromJson(e)).toList();
        if (!mounted) return;
        setState(() {
          pubsSponsorisees = pubs.where((p) => _isPubValid(p)).toList();
          _logger.info(
            '[DEBUG] ⭐ Total pubs sponsorisées reçues: ${pubs.length}',
          );
          _logger.info(
            '[DEBUG] ⭐ Publicités Sponsorisées: ${pubsSponsorisees.length} valides sur ${pubs.length} totales',
          );
          for (var pub in pubs) {
            final isValid = _isPubValid(pub);
            _logger.info(
              '[DEBUG] ⭐ Pub ${pub.id}: statut=${pub.statut}, dateDebut=${pub.dateDebut}, dateFin=${pub.dateFin}, valide=$isValid',
            );
            if (!isValid && pub.statut == 'valide') {
              _logger.info(
                '[DEBUG] ⭐ Pub ${pub.id} rejetée pour expiration - maintenant: ${DateTime.now()}, dateFin: ${pub.dateFin}',
              );
            }
          }
          isLoadingPubs = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorPubs = 'Erreur lors du chargement des publicités';
          isLoadingPubs = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorPubs = 'Erreur réseau';
        isLoadingPubs = false;
      });
    }
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted || pubsALaUne.isEmpty) return;
      if (_currentPage < pubsALaUne.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _openPubLink(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    final normalized =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
            ? trimmed
            : 'https://$trimmed';

    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      _logger.warning('[DEBUG] Lien publicité invalide: $normalized');
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _logger.warning('[DEBUG] Impossible d\'ouvrir le lien: $normalized');
    }
  }

  void _openFlyerPreview(String imageUrl) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTabButton(String title, int index, {bool isWide = false}) {
    bool isSelected = _tabController.index == index;
    const selectedColor = Color(0xFFF8BF13); // Jaune unifié plus doux
    const unselectedBorderColor = Color(0xFF000000);
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = index;
        });
      },
      child: Container(
        width: isWide ? 100 : 70,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? selectedColor : unselectedBorderColor,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // Section Recommandé :
  Widget buildVoituresRecommandeesGrid() {
    if (isLoadingVoitures) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorVoitures != null) {
      return Center(child: Text(errorVoitures!));
    }
    // Filtrer les voitures avec statut 'en_ligne' et non vendues
    const bool isVendeur = false;
    final voituresEnLigne = voituresRecommandees
        .where(
          (v) =>
              (v.statut ?? 'en_ligne') == 'en_ligne' &&
              (v.statut ?? '') != 'vendu',
        )
        .toList();
    if (voituresEnLigne.isEmpty) {
      return Center(
        child: Text(
          isVendeur
              ? "Vous n'avez aucune voiture en ligne"
              : "Aucune voiture disponible pour le moment.",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }
    // Appliquer filtres + recherche globale
    final filtered = _applyFilters(voituresEnLigne).where((v) {
      if (_searchGlobalText.isEmpty) return true;
      final hay = (v.marque +
              ' ' +
              v.modele +
              ' ' +
              v.titre +
              ' ' +
              (v.entreprise ?? ''))
          .toLowerCase();
      return hay.contains(_searchGlobalText.toLowerCase());
    }).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final cardAspectRatio = screenWidth < 360
        ? 0.68
        : screenWidth < 420
            ? 0.6
            : 0.55;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: cardAspectRatio,
        ),
        itemCount: filtered.length > 8 ? 8 : filtered.length,
        itemBuilder: (context, index) {
          final voiture = filtered[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _recordVehicleInteraction(voiture.id.toString());
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarsInfo(
                    id: voiture.id.toString(),
                    titre: voiture.titre,
                    description: voiture.description,
                    marque: voiture.marque,
                    modele: voiture.modele,
                    annee: voiture.annee,
                    prix: voiture.prix,
                    condition: voiture.condition,
                    boiteVitesse: voiture.boiteVitesse,
                    carburant: voiture.carburant,
                    climatiseur: voiture.climatiseur,
                    distance: voiture.distance,
                    sieges: voiture.sieges,
                    portes: voiture.portes,
                    cylindre: voiture.cylindre,
                    images: voiture.images,
                    video: voiture.video,
                    entreprise: voiture.entreprise,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image avec overlay pour le prix
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: voiture.images.isNotEmpty
                              ? Image.network(
                                  voiture.images.first,
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : (voiture.video?.isNotEmpty ?? false)
                                  ? VideoPreviewPlaceholder(
                                      videoUrl: voiture.video,
                                      enablePreviewFrame: false,
                                    )
                                  : Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                        ),
                        // Badge de vues
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildViewBadge(voiture.id),
                        ),
                        // Badge condition (nouveau/occasion)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (voiture.condition?.toLowerCase() ==
                                          'nouveau' ||
                                      voiture.condition?.toLowerCase() ==
                                          'neuf')
                                  ? Colors.purple
                                  : const Color(0xFFF8BF13),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              (voiture.condition?.toLowerCase() == 'nouveau' ||
                                      voiture.condition?.toLowerCase() ==
                                          'neuf')
                                  ? 'Nouveau'
                                  : 'Occasion',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Informations de la voiture
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Marque et modèle
                          Text(
                            voiture.marque,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            voiture.modele,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Prix en gras avec devise
                          Text(
                            '${voiture.prix} FCFA',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Caractéristiques en deux colonnes
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Ligne 1: Boite vitesse + Année
                                  if ((voiture.boiteVitesse?.isNotEmpty ??
                                          false) ||
                                      voiture.annee.trim().isNotEmpty)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildCaracteristic(
                                            Icons.settings,
                                            voiture.boiteVitesse ??
                                                'Automatique',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildCaracteristic(
                                            Icons.calendar_today,
                                            voiture.annee,
                                          ),
                                        ),
                                      ],
                                    ),
                                  // Ligne 2: Carburant + Cylindre
                                  if (voiture.carburant != null ||
                                      voiture.cylindre != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildCaracteristic(
                                              Icons.local_gas_station,
                                              voiture.carburant ?? '',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildCaracteristic(
                                              Icons.speed,
                                              voiture.cylindre ?? '',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Ligne 3: Distance + Portes
                                  if (voiture.distance != null ||
                                      voiture.portes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildCaracteristic(
                                              Icons.speed,
                                              '${voiture.distance ?? ''} KM',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildCaracteristic(
                                              Icons.door_front_door,
                                              '${voiture.portes ?? ''} portes',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Ligne 4: Sièges
                                  if (voiture.sieges != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildCaracteristic(
                                              Icons.person,
                                              '${voiture.sieges}',
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaracteristic(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.amber[700]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget buildPiecesGrid() {
    if (isLoadingPieces) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorPieces != null) {
      return Center(child: Text(errorPieces!));
    }
    const bool isVendeur = false;
    final piecesEnLigne = articlesPieces
        .where(
          (p) =>
              (p.statut ?? 'en_ligne') == 'en_ligne' &&
              (p.statut ?? '') != 'vendu',
        )
        .toList();
    // Filtrage recherche
    final filteredPieces = piecesEnLigne.where((p) {
      final q1 = _searchPieceText.trim().toLowerCase();
      final q2 = _searchGlobalText.trim().toLowerCase();
      final hay =
          (p.title + ' ' + p.description + ' ' + p.company + ' ' + p.location)
              .toLowerCase();
      final ok1 = q1.isEmpty || hay.contains(q1);
      final ok2 = q2.isEmpty || hay.contains(q2);
      return ok1 && ok2;
    }).toList();
    if (filteredPieces.isEmpty) {
      return Center(
        child: Text(
          isVendeur
              ? "Vous n'avez aucune pièce en ligne actuellement"
              : "Aucune pièce en ligne actuellement",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _searchPieceController,
            decoration: const InputDecoration(
              hintText: 'Rechercher une pièce...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              _searchPieceText = val;
              // Rafraîchir l'affichage
              (this as dynamic).setState(() {});
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: filteredPieces.length > 8 ? 8 : filteredPieces.length,
            itemBuilder: (context, index) {
              final piece = filteredPieces[index];
              return GestureDetector(
                onTap: () {
                  _recordVehicleInteraction(piece.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MastervacPage(
                        id: piece.id,
                        isAcheteur: true,
                        title: piece.title,
                        year: piece.year,
                        description: piece.description,
                        company: piece.company,
                        location: piece.location,
                        price: piece.price,
                        images: piece.images,
                        fuelType: piece.fuelType,
                        model: piece.model,
                        pieceType: piece.pieceType,
                        video: piece.video,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          piece.images.isNotEmpty
                              ? Image.network(
                                  piece.images.first,
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                )
                              : (piece.video?.isNotEmpty ?? false)
                                  ? VideoPreviewPlaceholder(
                                      videoUrl: piece.video, iconSize: 28)
                                  : Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.grey[300],
                                      child:
                                          const Icon(Icons.image_not_supported),
                                    ),
                          // Badge condition (aligné au style voitures) pour les pièces
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Builder(
                              builder: (context) {
                                final rawCond =
                                    (piece.condition ?? piece.pieceType ?? '')
                                        .toString()
                                        .toLowerCase();
                                final isNew = rawCond == 'nouveau' ||
                                    rawCond == 'neuf' ||
                                    rawCond == 'new';
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isNew
                                        ? Colors.purple
                                        : const Color(0xFFF8BF13),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    isNew ? 'Nouveau' : 'Occasion',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Favorite toggle
                          Positioned(
                            top: 2,
                            right: 2,
                            child: _buildViewBadge(piece.id),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      piece.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildVoituresRecommandeesSection() {
    const bool isVendeur = false;
    final voituresEnLigne = voituresRecommandees
        .where(
          (v) =>
              (v.statut ?? 'en_ligne') == 'en_ligne' &&
              (v.statut ?? '') != 'vendu',
        )
        .toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final sectionCardAspectRatio = screenWidth < 360
        ? 0.64
        : screenWidth < 420
            ? 0.6
            : 0.58;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recommandé",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF040415),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoituresPage(),
                    ),
                  );
                },
                child: const Text(
                  "Voir tout",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        if (isLoadingVoitures) const Center(child: CircularProgressIndicator()),
        if (errorVoitures != null) Center(child: Text(errorVoitures!)),
        if (!isLoadingVoitures && errorVoitures == null)
          _applyFilters(voituresEnLigne).isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      isVendeur
                          ? "Vous n'avez aucune voiture en ligne"
                          : "Aucune voiture disponible pour le moment.",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: sectionCardAspectRatio,
                    ),
                    itemCount: _applyFilters(voituresEnLigne).length > 8
                        ? 8
                        : _applyFilters(voituresEnLigne).length,
                    itemBuilder: (context, index) {
                      final list = _applyFilters(voituresEnLigne);
                      final voiture = list[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _recordVehicleInteraction(voiture.id.toString());
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarsInfo(
                                id: voiture.id.toString(),
                                titre: voiture.titre,
                                description: voiture.description,
                                marque: voiture.marque,
                                modele: voiture.modele,
                                annee: voiture.annee,
                                prix: voiture.prix,
                                condition: voiture.condition,
                                boiteVitesse: voiture.boiteVitesse,
                                carburant: voiture.carburant,
                                climatiseur: voiture.climatiseur,
                                distance: voiture.distance,
                                sieges: voiture.sieges,
                                portes: voiture.portes,
                                cylindre: voiture.cylindre,
                                images: voiture.images,
                                video: voiture.video,
                                entreprise: voiture.entreprise,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image avec overlay pour le prix
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: voiture.images.isNotEmpty
                                          ? Image.network(
                                              voiture.images.first,
                                              height: double.infinity,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : (voiture.video?.isNotEmpty ?? false)
                                              ? VideoPreviewPlaceholder(
                                                  videoUrl: voiture.video)
                                              : Container(
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                ),
                                    ),
                                    // Badge de vues
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: _buildViewBadge(voiture.id),
                                    ),
                                    // Badge condition (nouveau/occasion)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (voiture.condition
                                                          ?.toLowerCase() ==
                                                      'nouveau' ||
                                                  voiture.condition
                                                          ?.toLowerCase() ==
                                                      'neuf')
                                              ? Colors.purple
                                              : const Color(0xFFF8BF13),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Text(
                                          (voiture.condition?.toLowerCase() ==
                                                      'nouveau' ||
                                                  voiture.condition
                                                          ?.toLowerCase() ==
                                                      'neuf')
                                              ? 'Nouveau'
                                              : 'Occasion',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Informations de la voiture - PARTIE MODIFIÉE
                              Expanded(
                                flex: 2, // RÉDUIT de 3 à 2 pour moins d'espace
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    8,
                                  ), // RÉDUIT de 12 à 8
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // LIGNE 1: Nom + Prix sur la même ligne
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  voiture.marque,
                                                  style: TextStyle(
                                                    // RETIRÉ le gras, mis en gris
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  voiture.modele,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[500],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${voiture.prix} FCFA',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 6,
                                      ), // RÉDUIT l'espace
                                      // CARACTÉRISTIQUES - Espaces réduits
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceAround, // RÉDUIT l'espacement
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Rangée 1: Boite vitesse + Année
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildCaracteristic(
                                                    Icons.settings,
                                                    voiture.boiteVitesse ??
                                                        'Automatique',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ), // RÉDUIT
                                                Expanded(
                                                  child: _buildCaracteristic(
                                                    Icons.calendar_today,
                                                    voiture.annee,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Rangée 2: Carburant + Cylindre
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildCaracteristic(
                                                    Icons.local_gas_station,
                                                    voiture.carburant ?? '',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ), // RÉDUIT
                                                Expanded(
                                                  child: _buildCaracteristic(
                                                    Icons.speed,
                                                    voiture.cylindre ?? '',
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Rangée 3: Distance + Portes
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildCaracteristic(
                                                    Icons.speed,
                                                    '${voiture.distance ?? ''} KM',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ), // RÉDUIT
                                                Expanded(
                                                  child: _buildCaracteristic(
                                                    Icons.door_front_door,
                                                    '${voiture.portes ?? ''} portes',
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ],
    );
  }

  Widget buildPiecesSection() {
    const bool isVendeur = false;
    final piecesEnLigne = articlesPieces
        .where(
          (p) =>
              (p.statut ?? 'en_ligne') == 'en_ligne' &&
              (p.statut ?? '') != 'vendu',
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pièces détachées",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF040415),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Piece()),
                  );
                },
                child: const Text(
                  "Voir plus",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        if (isLoadingPieces) const Center(child: CircularProgressIndicator()),
        if (errorPieces != null) Center(child: Text(errorPieces!)),
        if (!isLoadingPieces && errorPieces == null)
          piecesEnLigne.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      isVendeur
                          ? "Vous n'avez aucune pièce en ligne actuellement"
                          : "Aucune pièce en ligne actuellement",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: piecesEnLigne.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final piece = piecesEnLigne[index];
                      return GestureDetector(
                        onTap: () {
                          _recordVehicleInteraction(piece.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MastervacPage(
                                id: piece.id,
                                isAcheteur: true,
                                title: piece.title,
                                year: piece.year,
                                description: piece.description,
                                company: piece.company,
                                location: piece.location,
                                price: piece.price,
                                images: piece.images,
                                fuelType: piece.fuelType,
                                model: piece.model,
                                pieceType: piece.pieceType,
                                video: piece.video,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: piece.images.isNotEmpty
                                            ? Image.network(
                                                piece.images.first,
                                                fit: BoxFit.cover,
                                              )
                                            : (piece.video?.isNotEmpty ?? false)
                                                ? VideoPreviewPlaceholder(
                                                    videoUrl: piece.video,
                                                    iconSize: 32,
                                                  )
                                                : Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 30,
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (piece.pieceType ?? '')
                                                      .toLowerCase() ==
                                                  'nouveau'
                                              ? Colors.purple
                                              : const Color(0xFFF8BF13),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          (piece.pieceType ?? '')
                                                      .toLowerCase() ==
                                                  'nouveau'
                                              ? 'Nouveau'
                                              : 'Occasion',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                piece.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                piece.company,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5E5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  piece.price.isNotEmpty
                                      ? "${piece.price} FCFA"
                                      : 'Prix non communiqué',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFB45309),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ],
    );
  }

  // SECTION SPONSORISÉE
  Widget buildPubsSponsoriseesSection() {
    final pubsValides = pubsSponsorisees.where(_isPubValid).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.star, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                "Sponsorisé",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        if (isLoadingPubs)
          const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (errorPubs != null)
          SizedBox(height: 100, child: Center(child: Text(errorPubs!)))
        else if (pubsValides.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                "Aucune voiture sponsorisée.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          Container(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pubsValides.length,
              itemBuilder: (context, index) {
                final pub = pubsValides[index];
                return GestureDetector(
                  onTap: () async {
                    if (pub.id.isEmpty) return;
                    // Afficher un indicateur de chargement
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      // Récupérer la pub complète pour avoir l'articleId
                      final user = FirebaseAuth.instance.currentUser;
                      final idToken = await user?.getIdToken();
                      final pubResponse = await http.get(
                        Uri.parse(getBaseUrl() + '/publicites/${pub.id}'),
                        headers: {
                          'Content-Type': 'application/json',
                          if (idToken != null)
                            'Authorization': 'Bearer $idToken',
                        },
                      );
                      if (pubResponse.statusCode == 200) {
                        final pubData = jsonDecode(pubResponse.body);
                        final articleId = pubData['articleId'];
                        if (articleId != null &&
                            articleId.toString().isNotEmpty) {
                          // Récupérer l'article
                          final articleResponse = await http.get(
                            Uri.parse(getBaseUrl() + '/articles/$articleId'),
                            headers: {
                              'Content-Type': 'application/json',
                              if (idToken != null)
                                'Authorization': 'Bearer $idToken',
                            },
                          );
                          if (articleResponse.statusCode == 200) {
                            final article = jsonDecode(articleResponse.body);
                            Navigator.pop(context); // Fermer le loader
                            if (article['type'] == 'voiture') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarsInfo(
                                    titre: article['titre'] ?? '',
                                    description: article['description'] ?? '',
                                    marque: article['marque'] ?? '',
                                    modele: article['modele'] ?? '',
                                    annee: article['annee'] ?? '',
                                    prix: article['prix']?.toString() ?? '',
                                    condition: article['condition'] ?? '',
                                    boiteVitesse: article['boiteVitesse'] ?? '',
                                    carburant: article['carburant'] ?? '',
                                    climatiseur: article['climatiseur'] ?? '',
                                    distance: article['distance'] ?? '',
                                    sieges: article['sieges'] ?? '',
                                    portes: article['portes'] ?? '',
                                    cylindre: article['cylindre'] ?? '',
                                    lieu: article['lieu'] ?? '',
                                    images: (article['photos'] as List?)
                                            ?.map((e) => e.toString())
                                            .toList() ??
                                        [],
                                    video: article['video'],
                                    entreprise: article['entreprise'],
                                    fromPub: true,
                                  ),
                                ),
                              );
                            } else if (article['type'] == 'piece') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MastervacPage(
                                    isAcheteur: true,
                                    title: article['titre'] ?? '',
                                    year: article['annee'] ?? '',
                                    description: article['description'] ?? '',
                                    company: article['entreprise'] ?? '',
                                    location: article['localisation'] ?? '',
                                    price: article['prix']?.toString() ?? '',
                                    images: (article['photos'] as List?)
                                            ?.map((e) => e.toString())
                                            .toList() ??
                                        [],
                                    fuelType: article['typeMoteur'],
                                    model: article['modele']?.toString(),
                                    pieceType: article['pieceType'],
                                    video: article['video'],
                                    fromPub: true,
                                  ),
                                ),
                              );
                            } else {
                              // Type inconnu
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Type d\'article inconnu.'),
                                ),
                              );
                            }
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Erreur lors du chargement de l\'article.',
                                ),
                              ),
                            );
                          }
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Aucun article lié à cette pub.'),
                            ),
                          );
                        }
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Erreur lors du chargement de la pub.',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur réseau : $e')),
                      );
                    }
                  },
                  child: SizedBox(
                    width: 340,
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: Container(
                                  height: 170,
                                  width: 340,
                                  color: Colors.grey[300],
                                  child: pub.media.isNotEmpty
                                      ? Image.network(
                                          pub.media[0],
                                          width: 340,
                                          height: 170,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              Icons.image_not_supported,
                                              size: 80,
                                              color: Colors.grey[600],
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.image_not_supported,
                                          size: 80,
                                          color: Colors.grey[600],
                                        ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                bottom: 12,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pub.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.verified,
                                            color: Color(0xFFF8BF13),
                                            size: 18,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "Vérifiée",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFFF8BF13),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Badge (simplified)
                              Positioned(
                                left: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8BF13),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Text(
                                    'Sponsorisé',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // SECTION À LA UNE (carrousel)
  Widget buildPubsALaUneCarousel() {
    if (isLoadingPubs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorPubs != null) {
      return Center(child: Text(errorPubs!));
    }
    if (pubsALaUne.isEmpty) {
      return const SizedBox.shrink();
    }
    // Affiche le carrousel et l'indicateur uniquement si la liste n'est pas vide
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pubsALaUne.length,
            itemBuilder: (context, index) {
              final pub = pubsALaUne[index];
              final hasLink = (pub.lien ?? '').trim().isNotEmpty;
              final card = Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pub.media.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              height: 260,
                              color: Colors.black,
                              child: Image.network(
                                pub.media[0],
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                      color: Colors.black54,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              height: 260,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 120),
                            ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pub.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (hasLink)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link, size: 16, color: Colors.black87),
                              SizedBox(width: 4),
                              Text(
                                'Voir plus',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );

              if (hasLink) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openPubLink(pub.lien!.trim()),
                  child: card,
                );
              }
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () =>
                    _openFlyerPreview(pub.media.isNotEmpty ? pub.media[0] : ''),
                child: card,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (pubsALaUne.length > 1)
          SmoothPageIndicator(
            controller: _pageController,
            count: pubsALaUne.length,
            effect: JumpingDotEffect(
              activeDotColor: Color(0xFFF8BF13),
              dotColor: Colors.grey.shade300,
              dotHeight: 10,
              dotWidth: 10,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    const bool isTransitaire = false;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildPubsALaUneCarousel(),
            _buildServicesSummarySection(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              isPortrait: isPortrait,
            ),
            // Section sponsorisée: toujours affichée
            buildPubsSponsoriseesSection(),
            buildVoituresRecommandeesSection(),
            buildPiecesSection(),
            // Add the new sections here
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSummarySection({
    required double screenWidth,
    required double screenHeight,
    required bool isPortrait,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final titleSize = screenWidth * (isPortrait ? 0.045 : 0.03);
    final iconSize = screenWidth * (isPortrait ? 0.12 : 0.08);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.services,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A1F44),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Rafraîchir',
                onPressed: _reloadAll,
                icon: const Icon(Icons.refresh, color: Color(0xFF0A1F44)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildServiceIcon(
                label: l10n.service_sales_cars,
                icon: Icons.directions_car,
                iconSize: iconSize,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VoituresPage()),
                  );
                },
              ),
              _buildServiceIcon(
                label: l10n.service_delivery_parts,
                icon: Icons.local_shipping,
                iconSize: iconSize,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Piece()),
                  );
                },
              ),
              _buildServiceIcon(
                label: l10n.service_tricycle,
                icon: Icons.pedal_bike,
                iconSize: iconSize,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TricycleHomePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon({
    required String label,
    required IconData icon,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize * 1.6,
            height: iconSize * 1.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/service_pulse.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
                Icon(
                  icon,
                  size: iconSize,
                  color: const Color(0xFF0A1F44),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: iconSize * 1.8,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1F44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers inline supprimés (non utilisés)

  Widget _buildActivitesSection() {
    List<Map<String, dynamic>> activites = [
      {
        "name": "Souscrire",
        "icon": "assets/images/souscrire.png",
        "route": Tarif(),
      },
      {
        "name": "Soumettre",
        "icon": "assets/images/soumis.png",
        "route": Tarif(),
      },
      {
        "name": "En Transit",
        "icon": "assets/images/transit.png",
        "route": Transit(),
      },
      {
        "name": "En Consommation",
        "icon": "assets/images/en_consommation.png",
        "route": Transit(),
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              itemCount: activites.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => activites[index]["route"],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          activites[index]["icon"],
                          height: 50,
                          width: 50,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          activites[index]["name"],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF000000),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarqueSection() {
    // Liste élargie; on gère les images manquantes avec errorBuilder
    final List<Map<String, String>> marques = [
      {"name": "Toyota", "image": "assets/images/Toyota.png"},
      {"name": "Nissan", "image": "assets/images/nissan.png"},
      {"name": "Ford", "image": "assets/images/ford.png"},
      {"name": "Hyundai", "image": "assets/images/hunydai.png"},
      {"name": "Honda", "image": "assets/images/honda.png"},
      {"name": "Kia", "image": "assets/images/kia.png"},
      {"name": "BMW", "image": "assets/images/bmw.png"},
      {"name": "Mercedes", "image": "assets/images/mercedes.png"},
      {"name": "Audi", "image": "assets/images/Audi.png"},
      {"name": "Volkswagen", "image": "assets/images/vw.png"},
      {"name": "Lexus", "image": "assets/images/lexus.png"},
      {"name": "Mazda", "image": "assets/images/mazda.webp"},
      {"name": "Chevrolet", "image": "assets/images/chevrolet.png"},
      {"name": "Jeep", "image": "assets/images/jeep.png"},
      {"name": "Peugeot", "image": "assets/images/peugeot.png"},
      {"name": "Renault", "image": "assets/images/renault.png"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 100 + 16,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 100,
          ),
          itemCount: marques.length,
          itemBuilder: (context, index) {
            final item = marques[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedBrand = item["name"];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Image.asset(
                        item["image"] ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) {
                          return CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              (item["name"] ?? '??').substring(0, 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["name"] ?? '',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeleSection() {
    final List<String> modeles = [
      'Land Cruiser',
      'Patrol',
      'Altima',
      'RAV4',
      'Hilux',
      'Wrangler',
      'Civic',
      'Corolla',
      'Camry',
      'Accord',
      'Tucson',
      'Sportage',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 90 + 16,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 120,
          ),
          itemCount: modeles.length,
          itemBuilder: (context, index) {
            final name = modeles[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedModel = name;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatistiquesSection() {
    final currentVehicleIds = voituresRecommandees.map((v) => v.id).toSet();
    final totalClicks =
        _vehicleClickCounts.values.fold<int>(0, (sum, value) => sum + value);

    final statsCards = [
      {
        "label": "Véhicules en ligne",
        "value": currentVehicleIds.length,
        "icon": Icons.directions_car_filled,
        "color": const Color(0xFFF8BF13),
        "background": const Color(0xFFFFF3CD),
        "description": "Annonce(s) visibles"
      },
      {
        "label": "Vues enregistrées",
        "value": totalClicks,
        "icon": Icons.remove_red_eye,
        "color": const Color(0xFF536DFE),
        "background": const Color(0xFFE8EAFE),
        "description": "Consultations sur vos annonces"
      },
    ];

    final topVehicles = voituresRecommandees
        .where((v) => (_vehicleClickCounts[v.id] ?? 0) > 0)
        .toList()
      ..sort((a, b) {
        final countA = _vehicleClickCounts[a.id] ?? 0;
        final countB = _vehicleClickCounts[b.id] ?? 0;
        return countB.compareTo(countA);
      });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vos statistiques",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statsCards.map((card) {
                return Container(
                  width: 190,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (card["color"] as Color).withOpacity(0.15),
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (card["color"] as Color).withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (card["color"] as Color).withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        card["icon"] as IconData,
                        color: card["color"] as Color,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        card["label"] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: (card["color"] as Color).withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${card["value"]}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card["description"] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (topVehicles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Top véhicules cliqués",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...topVehicles.take(3).map((vehicle) {
                  final clicks = _vehicleClickCounts[vehicle.id] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: vehicle.images.isNotEmpty
                              ? NetworkImage(vehicle.images.first)
                              : null,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.titre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${vehicle.marque} | ${vehicle.modele}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$clicks clic(s)",
                            style: const TextStyle(
                              color: Color(0xFF536DFE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            )
          else
            const Text(
              "Vos clics apparaîtront ici dès que vos véhicules seront consultés.",
              style: TextStyle(fontSize: 12, color: Color(0xFF795548)),
            ),
        ],
      ),
    );
  }

  // Section Localisation (visible pour rôles non-vendeurs)
  Widget _buildLocalisationSection() {
    final List<Map<String, dynamic>> zones = [
      {"name": "Bénin", "image": "assets/images/benin.png"},
      {"name": "Mali", "image": "assets/images/mali.png"},
      {"name": "Niger", "image": "assets/images/niger.png"},
      {"name": "Burkina-Faso", "image": "assets/images/burkina.png"},
      {"name": "Côte d'Ivoire", "image": "assets/images/ci.webp"},
      {"name": "Sénégal", "image": "assets/images/senegal.png"},
      {"name": "Togo", "image": "assets/images/togo.webp"},
      {"name": "Ghana", "image": "assets/images/ghana.png"},
      {"name": "Nigéria", "image": "assets/images/nigeria.png"},
      {"name": "Maroc", "image": "assets/images/maroc.png"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 106,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 120,
          ),
          itemCount: zones.length,
          itemBuilder: (context, index) {
            final item = zones[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLocation = item["name"];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 24,
                      child: Image.asset(item["image"], fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["name"],
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Section Budget (visible pour rôles non-vendeurs)
  Widget _buildBudgetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF8BF13), // Jaune unifié plus doux
            foregroundColor: const Color(0xFF000000),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _openBudgetSheet,
          child: const Text('Filtrer par budget'),
        ),
      ),
    );
  }

  void _openBudgetSheet() {
    // Construire la liste des prix à partir des voitures en ligne
    final List<double> prixList = voituresRecommandees
        .where((v) => (v.statut ?? 'en_ligne') == 'en_ligne')
        .map((v) => double.tryParse(v.prix.replaceAll(RegExp(r'[^0-9.]'), '')))
        .whereType<double>()
        .toList()
      ..sort();

    final double minPrice = prixList.isNotEmpty ? prixList.first : 0;
    final double maxPrice = prixList.isNotEmpty ? prixList.last : 200000;
    double currentMin = _budgetMin ?? minPrice;
    double currentMax = _budgetMax ?? maxPrice;

    final minCtl = TextEditingController(text: currentMin.toStringAsFixed(0));
    final maxCtl = TextEditingController(text: currentMax.toStringAsFixed(0));

    int compterDansIntervalle(double a, double b) {
      return voituresRecommandees.where((v) {
        final p = double.tryParse(v.prix.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (p == null) return false;
        final enLigne = (v.statut ?? 'en_ligne') == 'en_ligne';
        return enLigne && p >= a && p <= b;
      }).length;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final disponibles = compterDansIntervalle(currentMin, currentMax);
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Prix (FCFA)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Min.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) {
                            final v = double.tryParse(val) ?? currentMin;
                            setModalState(() {
                              currentMin = v.clamp(minPrice, currentMax);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxCtl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) {
                            final v = double.tryParse(val) ?? currentMax;
                            setModalState(() {
                              currentMax = v.clamp(currentMin, maxPrice);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(currentMin, currentMax),
                    min: minPrice,
                    max: maxPrice,
                    onChanged: (values) {
                      setModalState(() {
                        currentMin = values.start;
                        currentMax = values.end;
                        minCtl.text = currentMin.toStringAsFixed(0);
                        maxCtl.text = currentMax.toStringAsFixed(0);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              currentMin = minPrice;
                              currentMax = maxPrice;
                              minCtl.text = currentMin.toStringAsFixed(0);
                              maxCtl.text = currentMax.toStringAsFixed(0);
                            });
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _budgetMin = currentMin;
                              _budgetMax = currentMax;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFFF8BF13), // Jaune unifié plus doux
                            foregroundColor: const Color(0xFF000000),
                          ),
                          child: Text('Afficher $disponibles véhicule(s)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
