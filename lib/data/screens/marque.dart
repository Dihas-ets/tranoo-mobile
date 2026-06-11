import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tranoo/data/screens/cars_info.dart';
import 'package:tranoo/data/screens/voitures.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/mastervacpage.dart';
import 'package:tranoo/utils/role_redirect.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/services/views_service.dart';
import 'package:tranoo/data/screens/tarif.dart';
import 'package:tranoo/data/screens/transit.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';
import 'package:tranoo/utils/page_refresh_registry.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/utils/catalog_display.dart';
import 'package:tranoo/data/screens/movie.dart';
import 'package:lottie/lottie.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/catalog_filter_options.dart';
import 'package:tranoo/widgets/catalog_filter_sections.dart';
import 'package:tranoo/widgets/transitaire_carousel_section.dart';
import 'package:tranoo/data/screens/orders_page.dart';
import 'package:tranoo/data/screens/mes_commandes.dart';
import 'package:tranoo/data/screens/tricycle/tricycle_home.dart';

// Fonction utilitaire pour formater les prix avec des séparateurs de milliers
String formatPrice(dynamic price) {
  if (price == null) return '0';
  try {
    final priceNum = double.tryParse(price.toString()) ?? 0;
    final priceStr = priceNum.toStringAsFixed(0);
    final reversed = priceStr.split('').reversed.join('');
    final withDots = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (Match m) => '${m[0]}.',
    );
    return withDots.split('').reversed.join('');
  } catch (e) {
    return price.toString();
  }
}

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
  final int views;

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
    this.views = 0,
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
      views: (json['views'] as num?)?.toInt() ?? 0,
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
  final String? lieu;
  final String? localisation;
  final String? statut;
  final int views;

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
    this.lieu,
    this.localisation,
    this.statut,
    this.views = 0,
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
      lieu: json['lieu']?.toString(),
      localisation: json['localisation']?.toString(),
      statut: json['statut'],
      views: (json['views'] as num?)?.toInt() ?? 0,
    );
  }
}

List<ArticleVoiture> voituresRecommandees = [];
bool isLoadingVoitures = true;
String? errorVoitures;

// Ajout : modèle Pub pour la récupération des publicités
class Pub {
  final String id;
  final String? articleId;
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
    this.articleId,
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
    final dynamic rawArticleId = json['articleId'];
    final String? parsedArticleId = rawArticleId is Map<String, dynamic>
        ? rawArticleId['_id']?.toString()
        : rawArticleId?.toString();
    return Pub(
      id: json['_id'] ?? '',
      articleId: parsedArticleId,
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

class _MarqueState extends State<Marque>
    with SingleTickerProviderStateMixin, RegisterPageRefresh {
  @override
  Future<void> onPagePullRefresh() async {
    setState(() => _pullRefreshing = true);
    try {
      await Future.wait<void>([
        fetchArticlesPieces(silent: true),
        fetchVoituresRecommandees(silent: true),
        fetchPubs(silent: true),
        fetchPubsSponsorisees(silent: true),
      ]);
    } finally {
      if (mounted) setState(() => _pullRefreshing = false);
    }
  }
  int _currentPage = 0;
  late PageController _pageController;
  late TabController _tabController;
  Timer? _carouselTimer;
  /// Rafraîchissement périodique des données (comme la liste tricycle), sans bloquer l’UI.
  Timer? _marqueAutoRefreshTimer;
  bool _initialDataLoaded = false;
  bool _pullRefreshing = false;
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
  String _searchText = "";
  bool _hasTypedSearch = false;

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

  // Vues par article (backend uniquement) — total clicks de tous les users
  Map<String, int> _backendViews = {};
  final ViewsService _viewsService = ViewsService();

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

   _pageController = PageController(
  initialPage: 0,
  viewportFraction: 0.85,  // Permet de voir les cards adjacentes
);
    _searchGlobalController.addListener(() {
      setState(() {
        _searchText = _searchGlobalController.text.trim();
        _hasTypedSearch = _searchGlobalController.text.trim().isNotEmpty;
        _logger.info('[DEBUG] 🔍 Recherche tapée: "${_searchGlobalController.text}"');
      });
    });

    // Configuration du carrousel automatique
    _startCarouselTimer();
    fetchArticlesPieces();
    fetchVoituresRecommandees();
    fetchPubs();
    fetchPubsSponsorisees().then((_) {
      if (mounted) _initialDataLoaded = true;
    });
    _marqueAutoRefreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted) return;
      await _refreshMarqueDataSilent();
    });
  }

  /// Recharge listes / pubs sans réinitialiser filtres ni afficher les spinners de chargement.
  Future<void> _refreshMarqueDataSilent() async {
    await Future.wait<void>([
      fetchArticlesPieces(silent: true),
      fetchVoituresRecommandees(silent: true),
      fetchPubs(silent: true),
      fetchPubsSponsorisees(silent: true),
    ]);
  }

  Future<void> _reloadAll() async {
    // Réinitialiser la recherche
    _searchGlobalController.clear();
    _searchText = '';

    // Réinitialiser les filtres
    _selectedBrand = null;
    _selectedModel = null;
    _selectedLocation = null;
    _budgetMin = null;
    _budgetMax = null;

    setState(() {});
    final silent = _initialDataLoaded;
    await Future.wait<void>([
      fetchArticlesPieces(silent: silent),
      fetchVoituresRecommandees(silent: silent),
      fetchPubs(silent: silent),
      fetchPubsSponsorisees(silent: silent),
    ]);
    _initialDataLoaded = true;
  }

  Future<void> fetchArticlesPieces({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoadingPieces = true;
        errorPieces = null;
      });
    }
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
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = response.body;
        try {
          final List<dynamic> data = json.decode(body);
          if (!mounted) return;
          final allPieces = <Article>[];
          for (final raw in data) {
            if (raw is! Map<String, dynamic>) continue;
            try {
              allPieces.add(Article.fromJson(raw));
            } catch (parseErr) {
              _logger.info('[DEBUG] Pièce ignorée (parse): $parseErr');
            }
          }
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
            for (final p in piecesFiltered) {
              _backendViews[p.id] = p.views;
            }
            isLoadingPieces = false;
          });
          _loadBackendViews();
        } catch (e) {
          _logger.info('[DEBUG] Erreur de décodage JSON: $e');
          if (!mounted) return;
          setState(() {
            errorPieces = AppLocalizations.of(context)!.dataFormatError;
            isLoadingPieces = false;
          });
        }
      } else {
        _logger.info(
          '[DEBUG] HTTP pièces ${response.statusCode}: ${response.body}',
        );
        if (!mounted) return;
        setState(() {
          errorPieces = AppLocalizations.of(context)!.piecesLoadError;
          isLoadingPieces = false;
        });
      }
    } catch (e) {
      _logger.info('[DEBUG] Exception fetchArticlesPieces: $e');
      if (!mounted) return;
      setState(() {
        errorPieces = AppLocalizations.of(context)!.networkError;
        isLoadingPieces = false;
      });
    }
  }

  void _recordVehicleInteraction(String articleId) async {
    if (articleId.isEmpty) return;

    // Optimistic UI: incrémenter localement le compteur backend (puis sync)
    setState(() {
      _backendViews[articleId] = (_backendViews[articleId] ?? 0) + 1;
    });

    // Enregistrer la vue sur le backend (compteur global)
    try {
      await _viewsService.recordView(articleId);
      _logger.info('[VIEWS] Vue enregistrée pour l\'article: $articleId');
      final viewsData = await _viewsService.getArticleViews(articleId);
      if (viewsData != null && viewsData['success'] == true && mounted) {
        setState(() {
          _backendViews[articleId] = (viewsData['views'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {
      _logger.warning('[VIEWS] Erreur enregistrement vue backend: $e');
    }
  }

  // Charger les vues depuis le backend pour les véhicules recommandés
  Future<void> _loadBackendViews() async {
    try {
      final ids = <String>{
        ...voituresRecommandees.map((e) => e.id).where((e) => e.isNotEmpty),
        ...articlesPieces.map((e) => e.id).where((e) => e.isNotEmpty),
      }.toList();
      if (ids.isEmpty) return;

      final nextViews = Map<String, int>.from(_backendViews);
      for (final id in ids) {
        final viewsData = await _viewsService.getArticleViews(id);
        if (viewsData != null && viewsData['success'] == true) {
          nextViews[id] = (viewsData['views'] as num?)?.toInt() ?? (nextViews[id] ?? 0);
        }
      }
      if (!mounted) return;
      setState(() {
        _backendViews = nextViews;
      });
    } catch (e) {
      _logger.warning('[VIEWS] Erreur chargement vues backend: $e');
    }
  }

  Widget _buildViewBadge(String articleId) {
    final totalViews = _backendViews[articleId] ?? 0;
    
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
            totalViews.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  double _computeCardAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 0.58;
    if (screenWidth < 420) return 0.59;
    if (screenWidth < 520) return 0.7;
    return 0.78;
  }

  List<Map<String, dynamic>> _catalogMapsForFilters() {
    final maps = <Map<String, dynamic>>[];
    for (final v in voituresRecommandees) {
      maps.add({
        'marque': v.marque,
        'modele': v.modele,
        'prix': v.prix,
        'titre': v.titre,
        'description': v.description,
        'entreprise': v.entreprise,
        'lieu': v.lieu,
        'localisation': v.localisation,
      });
    }
    for (final p in articlesPieces) {
      maps.add({
        'marque': p.model,
        'modele': p.model,
        'pieceType': p.pieceType,
        'localisation': p.location,
        'lieu': p.location,
        'titre': p.title,
        'entreprise': p.company,
        'prix': p.price,
      });
    }
    return maps;
  }

  List<ArticleVoiture> _applyFilters(List<ArticleVoiture> source) {
    return source.where((v) {
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        if (!catalogValueMatches(_selectedBrand, v.marque)) return false;
      }
      if (_selectedModel != null && _selectedModel!.isNotEmpty) {
        if (!catalogValueMatches(_selectedModel, v.modele)) return false;
      }
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        final loc = [
          v.lieu,
          v.localisation,
          v.entreprise,
          v.description,
          v.titre,
        ].map((e) => e?.toString() ?? '').join(' ');
        if (!catalogValueMatches(_selectedLocation, loc)) return false;
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

  Future<void> fetchVoituresRecommandees({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoadingVoitures = true;
        errorVoitures = null;
      });
    }
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
          for (final v in voituresFiltered) {
            _backendViews[v.id] = v.views;
          }
          isLoadingVoitures = false;
        });
        
        // Charger les vues depuis le backend après avoir récupéré les véhicules
        _loadBackendViews();
      } else {
        if (!mounted) return;
        setState(() {
          errorVoitures = AppLocalizations.of(context)!.carsLoadError;
          isLoadingVoitures = false;
        });
      }
    } catch (e) {
      _logger.info('[DEBUG] Exception fetchVoituresRecommandees: $e');
      if (!mounted) return;
      setState(() {
        errorVoitures = AppLocalizations.of(context)!.networkError;
        isLoadingVoitures = false;
      });
    }
  }

  Future<void> fetchPubs({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoadingPubs = true;
        errorPubs = null;
      });
    }
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
          errorPubs = AppLocalizations.of(context)!.adsLoadError;
          isLoadingPubs = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorPubs = AppLocalizations.of(context)!.networkError;
        isLoadingPubs = false;
      });
    }
  }

  Future<void> fetchPubsSponsorisees({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoadingPubs = true;
        errorPubs = null;
      });
    }
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
          errorPubs = AppLocalizations.of(context)!.adsLoadError;
          isLoadingPubs = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorPubs = AppLocalizations.of(context)!.networkError;
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
    _marqueAutoRefreshTimer?.cancel();
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
  String _conditionLabel(AppLocalizations l10n, String? condition) {
    final c = (condition ?? '').toLowerCase();
    if (c == 'nouveau' || c == 'neuf') return l10n.conditionNew;
    return l10n.usedCondition;
  }

  Widget buildVoituresRecommandeesGrid() {
    final l10n = AppLocalizations.of(context)!;
    if (isLoadingVoitures && voituresRecommandees.isEmpty) {
      return SkeletonPresets.articleGrid(count: 2);
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
      if (_searchText.isEmpty) return true;
      final hay = (v.marque +
              ' ' +
              v.modele +
              ' ' +
              v.titre +
              ' ' +
              (v.entreprise ?? ''))
          .toLowerCase();
      return hay.contains(_searchText.toLowerCase());
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
                              _conditionLabel(l10n, voiture.condition),
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
                          catalogVehicleInfoFooter(
                            title: vehicleTitleFromMap({
                              'titre': voiture.titre,
                              'marque': voiture.marque,
                              'modele': voiture.modele,
                            }),
                            prix: voiture.prix,
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
                                                l10n.automaticTransmission,
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
    final l10n = AppLocalizations.of(context)!;
    if (isLoadingPieces && articlesPieces.isEmpty) {
      return SkeletonPresets.articleGrid(count: 2);
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
      final q2 = _searchText.trim().toLowerCase();
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
            decoration: InputDecoration(
              hintText: l10n.searchPartHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
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
                                    isNew
                                        ? l10n.conditionNew
                                        : l10n.usedCondition,
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
    final l10n = AppLocalizations.of(context)!;
    const bool isVendeur = false;
    final voituresEnLigne = voituresRecommandees
        .where(
          (v) =>
              (v.statut ?? 'en_ligne') == 'en_ligne' &&
              (v.statut ?? '') != 'vendu',
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
              Text(
                l10n.recommendedLabel,
                style: const TextStyle(
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
                child: Text(
                  l10n.seeAll,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        if (isLoadingVoitures && voituresRecommandees.isEmpty)
          SkeletonPresets.articleGrid(count: 2),
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
                  child: _buildRecommendedGridWithTransitaires(
                    _applyFilters(voituresEnLigne).take(4).toList(),
                    l10n,
                  ),
                ),
      ],
    );
  }

  Widget _buildRecommendedGridWithTransitaires(
    List<ArticleVoiture> list,
    AppLocalizations l10n,
  ) {
    final aspect = _computeCardAspectRatio(context);

    Widget tile(ArticleVoiture voiture) {
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
                                          _conditionLabel(
                                              l10n, voiture.condition),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: _buildViewBadge(voiture.id),
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      catalogVehicleInfoFooter(
                                        title: vehicleTitleFromMap({
                                          'titre': voiture.titre,
                                          'marque': voiture.marque,
                                          'modele': voiture.modele,
                                        }),
                                        prix: voiture.prix,
                                      ),
                                      const SizedBox(height: 6),
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
                                                        l10n.automaticTransmission,
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
    }

    Widget rowPair(int a, int b) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: a < list.length
                ? AspectRatio(aspectRatio: aspect, child: tile(list[a]))
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: b < list.length
                ? AspectRatio(aspectRatio: aspect, child: tile(list[b]))
                : const SizedBox.shrink(),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (list.isNotEmpty) rowPair(0, 1),
        if (list.isNotEmpty) ...[
          const SizedBox(height: 12),
          const TransitaireCarouselSection(
            showTitle: false,
            showSeeMoreButton: true,
          ),
        ],
        if (list.length > 2) ...[
          const SizedBox(height: 12),
          rowPair(2, 3),
        ],
      ],
    );
  }

  Widget buildPiecesSection() {
    final l10n = AppLocalizations.of(context)!;
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
                    MaterialPageRoute(builder: (context) => PiecePage()),
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
        if (isLoadingPieces && articlesPieces.isEmpty)
          SkeletonPresets.articleGrid(count: 2),
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
                  height: 220,
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
                                          _conditionLabel(
                                              l10n, piece.pieceType),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: _buildViewBadge(piece.id),
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
                              catalogPiecePricePill(piece.price),
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
    final l10n = AppLocalizations.of(context)!;
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
                l10n.sponsoredLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        if (isLoadingPubs)
          SkeletonPresets.pubBanner(height: 100)
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
            height: 190,
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
                          SkeletonPresets.articleGrid(count: 2),
                    );
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      final idToken = await user?.getIdToken();
                      final articleId = pub.articleId;
                      if (articleId == null || articleId.isEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.linkedArticleNotFound),
                          ),
                        );
                        return;
                      }

                      // Récupérer l'article directement (évite l'appel privé /publicites/:id)
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
                                SnackBar(
                                  content: Text(l10n.unknownArticleType),
                                ),
                              );
                            }
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.errorLoadingArticle),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${AppLocalizations.of(context)!.networkError}: $e')),
                      );
                    }
                  },
                  child: SizedBox(
                    width: 255,
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
                                  width: 255,
                                  color: Colors.grey[300],
                                  child: pub.media.isNotEmpty
                                      ? Image.network(
                                          pub.media[0],
                                          width: 255,
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
                                  child: Text(
                                    l10n.sponsoredLabel,
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
      return SkeletonPresets.articleGrid(count: 2);
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
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: PageView.builder(
            controller: _pageController,
            padEnds: true,
            itemCount: pubsALaUne.length,
            itemBuilder: (context, index) {
              final pub = pubsALaUne[index];
              final hasLink = (pub.lien ?? '').trim().isNotEmpty;
              final card = Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.black,
                    child: pub.media.isNotEmpty
                        ? Image.network(
                            pub.media[0],
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.black54,
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 80),
                          ),
                  ),
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
        const SizedBox(height: 6),
        if (pubsALaUne.length > 1)
          SmoothPageIndicator(
            controller: _pageController,
            count: pubsALaUne.length,
            effect: JumpingDotEffect(
              activeDotColor: Color(0xFFF8BF13),
              dotColor: Colors.grey.shade300,
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
      ],
    );
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;
    _logger.info('[DEBUG] 🔧 Ouverture du dialogue de filtre');
    _logger.info('[DEBUG] 🔧 Context disponible: ${context != null}');
    _logger.info('[DEBUG] 🔧 Monted: $mounted');
    
    try {
      showDialog(
        context: context,
        builder: (ctx) {
          _logger.info('[DEBUG] 🔧 Builder context créé: ${ctx != null}');
          return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.tune, color: Color(0xFFB45309)),
            const SizedBox(width: 8),
            Text(l10n.searchTypeTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.whatDoYouWantToSearch),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _logger.info('[DEBUG] 🚗 Clic sur Véhicules - recherche: "${_searchGlobalController.text}"');
                  try {
                    Navigator.of(ctx).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VoituresPage(),
                        settings: RouteSettings(
                          arguments: {
                            'searchQuery': _searchGlobalController.text,
                          },
                        ),
                      ),
                    );
                    _logger.info('[DEBUG] 🚗 Navigation vers VoituresPage réussie');
                  } catch (e, stackTrace) {
                    _logger.severe('[ERROR] 💥 Erreur navigation Véhicules: $e');
                    _logger.severe('[ERROR] 💥 Stack trace: $stackTrace');
                  }
                },
                icon: const Icon(Icons.directions_car),
                label: Text(l10n.vehicles),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB45309),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _logger.info('[DEBUG] 🔧 Clic sur Pièces - recherche: "${_searchGlobalController.text}"');
                  try {
                    Navigator.of(ctx).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PiecePage(),
                        settings: RouteSettings(
                          arguments: {
                            'searchQuery': _searchGlobalController.text,
                          },
                        ),
                      ),
                    );
                    _logger.info('[DEBUG] 🔧 Navigation vers PiecePage réussie');
                  } catch (e, stackTrace) {
                    _logger.severe('[ERROR] 💥 Erreur navigation Pièces: $e');
                    _logger.severe('[ERROR] 💥 Stack trace: $stackTrace');
                  }
                },
                icon: const Icon(Icons.build),
                label: Text(l10n.pieces),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      );
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('[ERROR] 💥 Erreur lors de l\'ouverture du dialogue: $e');
      _logger.severe('[ERROR] 💥 Stack trace: $stackTrace');
      
      // Afficher un message à l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneric('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterHint() {
    final l10n = AppLocalizations.of(context)!;
    _logger.info('[DEBUG] 💡 Affichage du hint pour le filtre');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.lightbulb, color: Color(0xFFB45309)),
            const SizedBox(width: 8),
            Text(l10n.chooseTypeTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.youTyped(_searchGlobalController.text)),
            const SizedBox(height: 12),
            Text(l10n.whatArticleTypeSearch),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoituresPage(),
                          settings: RouteSettings(
                            arguments: {
                              'searchQuery': _searchGlobalController.text,
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_car),
                    label: Text(l10n.vehicleSingular),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB45309),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PiecePage(),
                          settings: RouteSettings(
                            arguments: {
                              'searchQuery': _searchGlobalController.text,
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.build),
                    label: Text(l10n.partSingular),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    const bool isTransitaire = false;

    return Scaffold(
      body: Column(
        children: [
          // Barre de recherche fixe avec icone filtre
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: TextField(
              controller: _searchGlobalController,
              decoration: InputDecoration(
                hintText: l10n.searchVehiclesPartsHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: AnimatedBuilder(
                  animation: _searchGlobalController,
                  builder: (context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _hasTypedSearch
                              ? Container(
                                  key: const Key('filter_active'),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.filter_list,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              : const Icon(
                                  Icons.filter_list,
                                  color: Colors.grey,
                                  key: Key('filter_inactive'),
                                ),
                        ),
                        onPressed: () {
                          _logger.info('[DEBUG] 🔧 Clic sur le filtre - recherche: "${_searchGlobalController.text}"');
                          if (_hasTypedSearch && _searchGlobalController.text.trim().isNotEmpty) {
                            _showFilterHint();
                          } else {
                            _showFilterDialog();
                          }
                        },
                      ),
                    );
                  },
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Contenu scrollable
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFFFCC00),
              onRefresh: onPagePullRefresh,
              child: _pullRefreshing
                  ? SkeletonPresets.homeMarque()
                  : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSummarySection({
    required double screenWidth,
    required double screenHeight,
    required bool isPortrait,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final iconSize = screenWidth * (isPortrait ? 0.085 : 0.06);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8BF13).withOpacity(0.25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF8BF13).withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildServiceIcon(
                    label: l10n.vehicles,
                    icon: Icons.directions_car,
                    iconSize: iconSize,
                    //imagePath: 'assets/images/icon_vente.png',
                    imagePath: 'assets/images/icon_vente3.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VoituresPage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildServiceIcon(
                    label: l10n.pieces,
                    icon: Icons.build_circle,
                    iconSize: iconSize,
                    //imagePath: null,
                    imagePath: 'assets/images/icon_pieces2.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PiecePage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildServiceIcon(
                    label: l10n.deliveries,
                    icon: Icons.local_shipping,
                    iconSize: iconSize,
                    imagePath: 'assets/images/icon_livraison3.png',
                    onTap: () {
                      Navigator.push(
                        context,
                         MaterialPageRoute(builder: (context) => MesCommandesPage()),
                        // MaterialPageRoute(builder: (context) => PiecePage()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildServiceIcon(
                    label: l10n.tricycles,
                    icon: Icons.pedal_bike,
                    iconSize: iconSize,
                    //imagePath: 'assets/images/icon_tricycle.png',
                    imagePath: 'assets/images/icon_tricycle3.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TricycleHomePage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon({
    required String label,
    required IconData icon,
    required double iconSize,
    required VoidCallback onTap,
    String? imagePath,
    Color? accentColor,
  }) {
    final ringColor = accentColor ?? const Color(0xFFF8BF13);
    // Cercle jaune clair : le picto occupe ~82 % du diamètre (lisible, proche du bord du rond).
    final double circleDiameter = iconSize * 1.9;
    final double innerIconSize = circleDiameter * 0.82;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rond de fond (services) — bordure légère pour bien voir le rendu sur fond blanc.
            Container(
              width: circleDiameter,
              height: circleDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ringColor.withOpacity(0.22),
                border: Border.all(
                  color: ringColor.withOpacity(0.55),
                  width: 1,
                ),
              ),
              child: Center(
                child: imagePath != null
                    ? (accentColor != null
                        ? ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              accentColor,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              imagePath,
                              width: innerIconSize,
                              height: innerIconSize,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            imagePath,
                            width: innerIconSize,
                            height: innerIconSize,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              icon,
                              size: innerIconSize,
                              color: const Color(0xFF0A1F44),
                            ),
                          ))
                    : Icon(
                        icon,
                        size: innerIconSize,
                        color: accentColor ?? const Color(0xFF0A1F44),
                      ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
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
          ],
        ),
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
    if (isLoadingVoitures && voituresRecommandees.isEmpty) {
      return const CatalogFilterHorizSkeleton();
    }
    final options = buildMarqueFilterOptions(_catalogMapsForFilters(), isPiece: true);
    return CatalogMarqueFilterGrid(
      options: options,
      selected: _selectedBrand,
      onSelected: (v) => setState(() => _selectedBrand = v),
    );
  }

  Widget _buildModeleSection() {
    if (isLoadingVoitures && voituresRecommandees.isEmpty) {
      return const CatalogFilterHorizSkeleton(itemWidth: 88, height: 60);
    }
    final modeles = buildModeleFilterOptions(_catalogMapsForFilters());
    return CatalogModeleFilterGrid(
      modeles: modeles,
      selected: _selectedModel,
      onSelected: (v) => setState(() => _selectedModel = v),
    );
  }

  Widget _buildLocalisationSection() {
    if (isLoadingVoitures && voituresRecommandees.isEmpty) {
      return const CatalogFilterHorizSkeleton();
    }
    final options = buildLocationFilterOptions(_catalogMapsForFilters());
    return CatalogLocationFilterGrid(
      options: options,
      selected: _selectedLocation,
      onSelected: (v) => setState(() => _selectedLocation = v),
    );
  }

  Widget _buildBudgetSection() {
    final l10n = AppLocalizations.of(context)!;
    final carMaps = voituresRecommandees
        .map((v) => <String, dynamic>{'prix': v.prix, 'statut': v.statut})
        .toList();
    return CatalogBudgetFilterPanel(
      articles: carMaps,
      budgetMin: _budgetMin,
      budgetMax: _budgetMax,
      countLabel: (n) => l10n.vehiclesAvailableCount(n),
      onReset: () => setState(() {
        _budgetMin = null;
        _budgetMax = null;
      }),
      onApply: (min, max) => setState(() {
        _budgetMin = min;
        _budgetMax = max;
      }),
    );
  }
}
