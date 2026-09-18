import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/cars_info.dart';
import 'package:tranoo/data/screens/voitures.dart';
import 'package:tranoo/data/screens/motos.dart';
import 'package:tranoo/data/screens/moto_info.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/mastervacpage.dart';
import 'package:tranoo/utils/role_redirect.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/services/views_service.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/page_refresh_registry.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/widgets/page_pull_refresh.dart';
import 'package:tranoo/utils/catalog_filter_options.dart';
import 'package:tranoo/widgets/catalog_filter_sections.dart';
import 'package:tranoo/widgets/transitaire_carousel_section.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/widgets/cached_media_image.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/data/models/article.dart';
import 'package:tranoo/data/models/article_voiture.dart';
import 'package:tranoo/data/models/pub.dart';
import 'package:tranoo/data/repositories/marque_repository.dart';
import 'package:tranoo/data/screens/marque/marque_pubs_carousel.dart';
import 'package:tranoo/data/screens/marque/marque_catalog_sections.dart';
import 'package:tranoo/data/screens/marque/marque_filter_panels.dart';
import 'package:tranoo/data/screens/marque/marque_services_summary.dart';
import 'package:tranoo/data/screens/marque/marque_seller_stats.dart';
import 'package:tranoo/data/screens/marque/marque_search_dialogs.dart';

class Marque extends StatefulWidget {
  const Marque({super.key});

  @override
  State<Marque> createState() => _MarqueState();
}

class _MarqueState extends State<Marque>
    with SingleTickerProviderStateMixin, RegisterPageRefresh {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  Future<void> onPagePullRefresh() async {
    final started = DateTime.now();
    try {
      await Future.wait<void>([
        fetchArticlesPieces(),
        fetchVoituresRecommandees(),
        fetchMotosRecommandees(),
        fetchPubs(),
        fetchPubsSponsorisees(),
      ]);
      if (_userService.currentRole == UserRole.vendeur) {
        await _loadSellerMarqueStats();
      }
    } catch (_) {
      // RefreshIndicator gère l'état visuel.
    } finally {
      final elapsed = DateTime.now().difference(started);
      const minSkeleton = Duration(milliseconds: 400);
      if (elapsed < minSkeleton) {
        await Future.delayed(minSkeleton - elapsed);
      }
    }
  }

  int _currentPage = 0;
  late PageController _pageController;
  late TabController _tabController;
  Timer? _carouselTimer;

  /// Rafraîchissement périodique des données (comme la liste tricycle), sans bloquer l’UI.
  Timer? _marqueAutoRefreshTimer;
  final UserService _userService = UserService();
  final MarqueRepository _marqueRepo = MarqueRepository();
  late int _marqueTabIndex;
  late int _modeleTabIndex;
  late int _statistiquesTabIndex;
  late int _localisationTabIndex;
  late int _budgetTabIndex;
  String? _selectedMotoBrand;
  String? _statsVendeurType;
  int _statsVehiclesOnline = 0;
  int _statsPiecesOnline = 0;
  int _statsVehiclesSold = 0;
  int _statsPiecesSold = 0;
  bool _sellerMarqueStatsLoading = false;
  List<ArticleVoiture> voituresRecommandees = [];
  bool isLoadingVoitures = true;
  String? errorVoitures;
  List<ArticleVoiture> motosRecommandees = [];
  bool isLoadingMotos = true;
  String? errorMotos;
  List<Article> articlesPieces = [];
  bool isLoadingPieces = true;
  String? errorPieces;
  List<Pub> pubsSponsorisees = [];
  List<Pub> pubsALaUne = [];
  bool isLoadingPubs = true;
  String? errorPubs;

  // Recherche globale (barre en haut)
  final TextEditingController _searchGlobalController = TextEditingController();
  bool _hasTypedSearch = false;

  final _logger = Logger('MarquePage');

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

    final isVendeur = _userService.currentRole == UserRole.vendeur;
    if (isVendeur) {
      _marqueTabIndex = 0;
      _statistiquesTabIndex = 1;
      _modeleTabIndex = 0;
      _localisationTabIndex = 0;
      _budgetTabIndex = 0;
      _tabController = TabController(length: 2, vsync: this);
    } else {
      _marqueTabIndex = 0;
      _modeleTabIndex = 1;
      _localisationTabIndex = 2;
      _budgetTabIndex = 3;
      _statistiquesTabIndex = 0;
      _tabController = TabController(length: 4, vsync: this);
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _userService.currentRole == UserRole.vendeur &&
          _tabController.index == _statistiquesTabIndex) {
        _loadSellerMarqueStats();
      }
      setState(() {});
    });

    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85,
    );
    _searchGlobalController.addListener(() {
      setState(() {
        _hasTypedSearch = _searchGlobalController.text.trim().isNotEmpty;
        _logger.info(
          '[DEBUG] 🔍 Recherche tapée: "${_searchGlobalController.text}"',
        );
      });
    });

    // Configuration du carrousel automatique
    _startCarouselTimer();
    unawaited(_primeFromStaleCache());
    _loadMarqueInitialData();
    _marqueAutoRefreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted) return;
      await _refreshMarqueDataSilent();
    });
  }

  Future<void> _primeFromStaleCache() async {
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final pubs = await _marqueRepo.readStalePubsALaUne(isVendeur: isVendeur);
    if (pubs != null && mounted) {
      setState(() {
        pubsALaUne = pubs;
        isLoadingPubs = false;
        if (pubsALaUne.isNotEmpty) {
          _startCarouselTimer();
        }
      });
      _precachePubImages(pubsALaUne);
    }

    final voitures =
        await _marqueRepo.readStaleVoitures(isVendeur: isVendeur);
    if (voitures != null && mounted) {
      setState(() {
        voituresRecommandees = voitures;
        isLoadingVoitures = false;
      });
      _precacheArticleVoitureThumbs(voituresRecommandees);
    }
  }

  Future<void> _loadMarqueInitialData() async {
    // Pubs en priorité (visibles en haut de l'accueil).
    await Future.wait<void>([
      fetchPubs(),
      fetchPubsSponsorisees(),
    ]);
    if (!mounted) return;
    unawaited(Future.wait<void>([
      fetchArticlesPieces(),
      fetchVoituresRecommandees(),
      fetchMotosRecommandees(),
      if (_userService.currentRole == UserRole.vendeur) _loadSellerMarqueStats(),
    ]));
  }

  void _precachePubImages(Iterable<Pub> pubs) {
    if (!mounted) return;
    final urls = pubs
        .expand((p) => p.media)
        .where((u) => u.trim().isNotEmpty)
        .take(12);
    precacheMediaImages(
      context,
      urls,
      cloudinaryWidthPx: cloudinaryWidthPx(context, logicalWidth: 280),
      maxCount: 12,
    );
  }

  bool get _isVendeurRole => _userService.currentRole == UserRole.vendeur;

  void _precacheArticleVoitureThumbs(Iterable<ArticleVoiture> items) {
    if (!mounted) return;
    precacheTranooImages(
      context,
      items.where((v) => v.images.isNotEmpty).map((v) => v.images.first),
      cloudinaryWidthPx: cloudinaryWidthPx(context, logicalWidth: 180),
    );
  }

  void _precachePieceThumbs(Iterable<Article> items) {
    if (!mounted) return;
    precacheTranooImages(
      context,
      items.where((p) => p.images.isNotEmpty).map((p) => p.images.first),
      cloudinaryWidthPx: cloudinaryWidthPx(context, logicalWidth: 120),
    );
  }

  /// Recharge listes / pubs sans réinitialiser filtres ni afficher les spinners de chargement.
  Future<void> _refreshMarqueDataSilent() async {
    await Future.wait<void>([
      fetchArticlesPieces(silent: true),
      fetchVoituresRecommandees(silent: true),
      fetchMotosRecommandees(silent: true),
      fetchPubs(silent: true),
      fetchPubsSponsorisees(silent: true),
    ]);
  }

  Future<void> fetchArticlesPieces({bool silent = false}) async {
    final isVendeur = _isVendeurRole;
    if (!silent) {
      final cached = await _marqueRepo.readStalePieces(isVendeur: isVendeur);
      if (cached != null && mounted) {
        setState(() {
          articlesPieces = cached;
          isLoadingPieces = false;
        });
        _precachePieceThumbs(articlesPieces);
      } else if (mounted) {
        setState(() {
          isLoadingPieces = true;
          errorPieces = null;
        });
      }
    }
    try {
      final pieces = await _marqueRepo.fetchPieces(isVendeur: isVendeur);
      if (!mounted) return;
      setState(() {
        articlesPieces = pieces;
        for (final p in pieces) {
          _backendViews[p.id] = p.views;
        }
        isLoadingPieces = false;
      });
      _precachePieceThumbs(pieces);
      _loadBackendViews();
    } on MarqueFetchException catch (e) {
      if (!mounted) return;
      setState(() {
        errorPieces = e.message;
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
          nextViews[id] =
              (viewsData['views'] as num?)?.toInt() ?? (nextViews[id] ?? 0);
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

  List<ArticleVoiture> _applyMotoFilters(List<ArticleVoiture> source) {
    return source.where((m) {
      if (_selectedMotoBrand != null && _selectedMotoBrand!.isNotEmpty) {
        if (!catalogValueMatches(_selectedMotoBrand, m.marque)) return false;
      }
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        final loc = [
          m.entreprise,
          m.description,
          m.titre,
        ].map((e) => e?.toString() ?? '').join(' ');
        if (!catalogValueMatches(_selectedLocation, loc)) return false;
      }
      if (_budgetMin != null || _budgetMax != null) {
        final price =
            double.tryParse(m.prix.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (_budgetMin != null && price < _budgetMin!) return false;
        if (_budgetMax != null && price > _budgetMax!) return false;
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _catalogMapsForFilters() {
    return voituresRecommandees.map((v) => v.toArticleMap()).toList();
  }

  List<Map<String, dynamic>> _catalogMotoMapsForFilters() {
    return motosRecommandees.map((m) => m.toArticleMap()).toList();
  }

  Future<void> _loadSellerMarqueStats() async {
    if (_userService.currentRole != UserRole.vendeur) return;
    setState(() => _sellerMarqueStatsLoading = true);
    try {
      final data = await _marqueRepo.fetchSellerMarqueStats();
      if (data == null || !mounted) {
        if (mounted) setState(() => _sellerMarqueStatsLoading = false);
        return;
      }
      setState(() {
        _statsVendeurType = data['vendeurType']?.toString();
        _statsVehiclesOnline = (data['vehiclesOnline'] as num?)?.round() ?? 0;
        _statsPiecesOnline = (data['piecesOnline'] as num?)?.round() ?? 0;
        _statsVehiclesSold = (data['vehiclesSold'] as num?)?.round() ?? 0;
        _statsPiecesSold = (data['piecesSold'] as num?)?.round() ?? 0;
        _sellerMarqueStatsLoading = false;
      });
    } catch (e) {
      _logger.warning('[SELLER_STATS] $e');
      if (mounted) setState(() => _sellerMarqueStatsLoading = false);
    }
  }

  Future<void> fetchVoituresRecommandees({bool silent = false}) async {
    final isVendeur = _isVendeurRole;
    if (!silent) {
      final cached =
          await _marqueRepo.readStaleVoitures(isVendeur: isVendeur);
      if (cached != null && mounted) {
        setState(() {
          voituresRecommandees = cached;
          isLoadingVoitures = false;
        });
        _precacheArticleVoitureThumbs(voituresRecommandees);
      } else if (mounted) {
        setState(() {
          isLoadingVoitures = true;
          errorVoitures = null;
        });
      }
    }
    try {
      final voitures =
          await _marqueRepo.fetchVoitures(isVendeur: isVendeur);
      if (!mounted) return;
      setState(() {
        voituresRecommandees = voitures;
        for (final v in voitures) {
          _backendViews[v.id] = v.views;
        }
        isLoadingVoitures = false;
      });
      _precacheArticleVoitureThumbs(voitures);
      _loadBackendViews();
    } on MarqueFetchException catch (e) {
      if (!mounted) return;
      setState(() {
        errorVoitures = e.message;
        isLoadingVoitures = false;
      });
    }
  }

  Future<void> fetchMotosRecommandees({bool silent = false}) async {
    final isVendeur = _isVendeurRole;
    if (!silent) {
      final cached = await _marqueRepo.readStaleMotos(isVendeur: isVendeur);
      if (cached != null && mounted) {
        setState(() {
          motosRecommandees = cached;
          isLoadingMotos = false;
        });
        _precacheArticleVoitureThumbs(motosRecommandees);
      } else if (mounted) {
        setState(() {
          isLoadingMotos = true;
          errorMotos = null;
        });
      }
    }
    try {
      final motos = await _marqueRepo.fetchMotos(isVendeur: isVendeur);
      if (!mounted) return;
      setState(() {
        motosRecommandees = motos;
        for (final m in motos) {
          _backendViews[m.id] = m.views;
        }
        isLoadingMotos = false;
      });
      _precacheArticleVoitureThumbs(motos);
      _loadBackendViews();
    } on MarqueFetchException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMotos = e.message;
        isLoadingMotos = false;
      });
    }
  }

  Future<void> fetchPubs({bool silent = false}) async {
    final isVendeur = _isVendeurRole;
    if (!silent) {
      final cached =
          await _marqueRepo.readStalePubsALaUne(isVendeur: isVendeur);
      if (cached != null && mounted) {
        setState(() {
          pubsALaUne = cached;
          isLoadingPubs = false;
          if (pubsALaUne.isNotEmpty) {
            _startCarouselTimer();
          }
        });
        _precachePubImages(pubsALaUne);
      } else if (mounted) {
        setState(() {
          isLoadingPubs = true;
          errorPubs = null;
        });
      }
    }
    try {
      final pubs = await _marqueRepo.fetchPubsALaUne(isVendeur: isVendeur);
      if (!mounted) return;
      setState(() {
        pubsALaUne = pubs;
        isLoadingPubs = false;
        if (pubsALaUne.isNotEmpty) {
          _startCarouselTimer();
        }
      });
      _precachePubImages(pubsALaUne);
    } on MarqueFetchException catch (e) {
      if (!mounted) return;
      setState(() {
        errorPubs = e.message;
        isLoadingPubs = false;
      });
    }
  }

  Future<void> fetchPubsSponsorisees({bool silent = false}) async {
    final isVendeur = _isVendeurRole;
    if (!silent) {
      final cached =
          await _marqueRepo.readStalePubsSponsorisees(isVendeur: isVendeur);
      if (cached != null && mounted) {
        setState(() {
          pubsSponsorisees = cached;
          isLoadingPubs = false;
        });
        _precachePubImages(pubsSponsorisees);
      } else if (mounted) {
        setState(() {
          isLoadingPubs = true;
          errorPubs = null;
        });
      }
    }
    try {
      final pubs =
          await _marqueRepo.fetchPubsSponsorisees(isVendeur: isVendeur);
      if (!mounted) return;
      setState(() {
        pubsSponsorisees = pubs;
        isLoadingPubs = false;
      });
      _precachePubImages(pubsSponsorisees);
    } on MarqueFetchException catch (e) {
      if (!mounted) return;
      setState(() {
        errorPubs = e.message;
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
                child: TranooNetworkImage(
                  url: imageUrl,
                  fit: BoxFit.contain,
                  cloudinaryWidthPx:
                      (MediaQuery.of(context).size.width *
                              MediaQuery.of(context).devicePixelRatio)
                          .round()
                          .clamp(600, 1600),
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
    _searchGlobalController.dispose();
    super.dispose();
  }


  Widget buildVoituresRecommandeesSection() {
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final voituresEnLigne = voituresRecommandees
        .where(
          (v) =>
              (v.statut ?? 'en_ligne') == 'en_ligne' &&
              (v.statut ?? '') != 'vendu',
        )
        .toList();
    return MarqueVoituresSection(
      voitures: _applyFilters(voituresEnLigne),
      isLoading: isLoadingVoitures,
      error: errorVoitures,
      isVendeur: isVendeur,
      conditionNewLabel: l10n.conditionNew,
      conditionUsedLabel: l10n.usedCondition,
      defaultTransmission: l10n.automaticTransmission,
      onSeeAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VoituresPage()),
        );
      },
      onVehicleTap: (voiture) {
        _recordVehicleInteraction(voiture.id.toString());
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
    );
  }

  Widget buildMotosSection() {
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final motosEnLigne = _applyMotoFilters(motosRecommandees
        .where(
          (m) =>
              (m.statut ?? 'en_ligne') == 'en_ligne' &&
              (m.statut ?? '') != 'vendu',
        )
        .toList());
    return MarqueMotosSection(
      motos: motosEnLigne,
      isLoading: isLoadingMotos,
      error: errorMotos,
      isVendeur: isVendeur,
      conditionNewLabel: l10n.conditionNew,
      conditionUsedLabel: l10n.usedCondition,
      onSeeAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MotosPage()),
        );
      },
      onMotoTap: (moto) {
        _recordVehicleInteraction(moto.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MotoInfo.fromArticleMap(moto.toArticleMap()),
          ),
        );
      },
    );
  }

  Widget buildPiecesSection() {
    final piecesEnLigne = articlesPieces
        .where(
          (p) =>
              (p.statut ?? 'en_ligne') == 'en_ligne' &&
              (p.statut ?? '') != 'vendu',
        )
        .toList();
    return MarquePiecesSection(
      pieces: piecesEnLigne,
      isLoading: isLoadingPieces,
      error: errorPieces,
      onSeeAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PiecePage()),
        );
      },
      onPieceTap: (piece) {
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
    );
  }

  Widget buildPubsSponsoriseesSection() {
    return MarqueSponsoredPubsSection(
      pubs: pubsSponsorisees,
      isLoading: isLoadingPubs,
      error: errorPubs,
      onPubTap: _onSponsoredPubTap,
    );
  }

  Future<void> _onSponsoredPubTap(Pub pub) async {
    if (pub.id.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator()),
    );
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final pubResponse = await http.get(
        Uri.parse('${getBaseUrl()}/publicites/${pub.id}'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );
      if (pubResponse.statusCode == 200) {
        final pubData = jsonDecode(pubResponse.body);
        final articleId = pubData['articleId'];
        if (articleId != null && articleId.toString().isNotEmpty) {
          final articleResponse = await http.get(
            Uri.parse('${getBaseUrl()}/articles/$articleId'),
            headers: {
              'Content-Type': 'application/json',
              if (idToken != null) 'Authorization': 'Bearer $idToken',
            },
          );
          if (articleResponse.statusCode == 200) {
            final article = jsonDecode(articleResponse.body);
            if (!mounted) return;
            Navigator.pop(context);
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Type d'article inconnu.")),
              );
            }
          } else {
            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Erreur lors du chargement de l'article."),
              ),
            );
          }
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun article lié à cette pub.')),
          );
        }
      } else {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement de la pub.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau : $e')),
      );
    }
  }

  Widget buildPubsALaUneCarousel() {
    return MarquePubsCarousel(
      pubs: pubsALaUne,
      isLoading: isLoadingPubs,
      error: errorPubs,
      pageController: _pageController,
      onOpenLink: _openPubLink,
      onOpenFlyer: _openFlyerPreview,
    );
  }

  void _showFilterDialog() {
    _logger.info('[DEBUG] 🔧 Ouverture du dialogue de filtre');
    showMarqueSearchTypeDialog(
      context: context,
      searchQuery: _searchGlobalController.text,
      onError: (e, stackTrace) {
        _logger.severe('[ERROR] 💥 Erreur lors de l\'ouverture du dialogue: $e');
        _logger.severe('[ERROR] 💥 Stack trace: $stackTrace');
      },
    );
  }

  void _showFilterHint() {
    showMarqueSearchHintDialog(
      context: context,
      searchQuery: _searchGlobalController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final isMotoSeller = isVendeur &&
        _userService.peutVendreMotos &&
        !_userService.peutVendreVehicules;

    final showBudgetPanel =
        !isVendeur && _tabController.index == _budgetTabIndex;
    final isInitialHomeLoading = isLoadingPubs &&
        pubsALaUne.isEmpty &&
        isLoadingVoitures &&
        voituresRecommandees.isEmpty;

    return Scaffold(
      body: Column(
        children: [
          if (!isVendeur)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchGlobalController,
                decoration: InputDecoration(
                  hintText: l10n.searchVehiclesPartsHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: AnimatedBuilder(
                    animation: _searchGlobalController,
                    builder: (context, child) {
                      return IconButton(
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
                          if (_hasTypedSearch &&
                              _searchGlobalController.text.trim().isNotEmpty) {
                            _showFilterHint();
                          } else {
                            _showFilterDialog();
                          }
                        },
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
          Expanded(
            child: PagePullRefresh(
              onRefresh: onPagePullRefresh,
              refreshSkeleton: SkeletonPresets.homeMarque(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    buildPubsALaUneCarousel(),
                    if (isVendeur)
                      _buildFilterTabRow(screenWidth)
                    else if (isInitialHomeLoading)
                      SkeletonPresets.servicesSummary()
                    else
                      MarqueServicesSummarySection(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        isPortrait: isPortrait,
                      ),
                    if (isVendeur && _tabController.index == _marqueTabIndex)
                      isMotoSeller
                          ? _buildMotosMarqueSection()
                          : _buildMarqueSection(),
                    if (!isVendeur && _tabController.index == _modeleTabIndex)
                      _buildMotosMarqueSection(),
                    if (isVendeur &&
                        _tabController.index == _statistiquesTabIndex)
                      _buildStatistiquesSection(),
                    if (!isVendeur &&
                        _tabController.index == _localisationTabIndex)
                      _buildLocalisationSection(),
                    buildPubsSponsoriseesSection(),
                    if (!isVendeur || _userService.peutVendreVehicules)
                      buildVoituresRecommandeesSection(),
                    if (!isVendeur || _userService.peutVendreVehicules)
                      _buildHomeTransitairesSection(),
                    if (!isVendeur || _userService.peutVendreMotos)
                      buildMotosSection(),
                    if (!isVendeur || _userService.peutVendrePieces)
                      buildPiecesSection(),
                  ],
                ),
              ),
            ),
          ),
          if (showBudgetPanel) _buildBudgetSection(),
        ],
      ),
    );
  }

  Widget _buildHomeTransitairesSection() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: TransitaireCarouselSection(
        showTitle: false,
        showSeeMoreButton: true,
      ),
    );
  }

  // Helpers inline supprimés (non utilisés)

  Widget _buildFilterTabRow(double screenWidth) {
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final isMotoSeller = isVendeur &&
        _userService.peutVendreMotos &&
        !_userService.peutVendreVehicules;
    return MarqueFilterTabRow(
      screenWidth: screenWidth,
      selectedIndex: _tabController.index,
      isVendeur: isVendeur,
      isMotoSeller: isMotoSeller,
      marqueTabIndex: _marqueTabIndex,
      modeleTabIndex: _modeleTabIndex,
      statistiquesTabIndex: _statistiquesTabIndex,
      localisationTabIndex: _localisationTabIndex,
      budgetTabIndex: _budgetTabIndex,
      onTabSelected: (index) => setState(() => _tabController.index = index),
    );
  }

  Widget _buildMarqueSection() {
    if (isLoadingVoitures && voituresRecommandees.isEmpty) {
      return const CatalogFilterHorizSkeleton();
    }
    final options =
        buildMarqueFilterOptions(_catalogMapsForFilters(), isPiece: false);
    return CatalogMarqueFilterGrid(
      options: options,
      selected: _selectedBrand,
      onSelected: (v) => setState(() => _selectedBrand = v),
    );
  }

  Widget _buildMotosMarqueSection() {
    if (isLoadingMotos && motosRecommandees.isEmpty) {
      return const CatalogFilterHorizSkeleton();
    }
    final options = buildMarqueFilterOptions(
      _catalogMotoMapsForFilters(),
      isPiece: false,
      isMoto: true,
    );
    return CatalogMarqueFilterGrid(
      options: options,
      selected: _selectedMotoBrand,
      onSelected: (v) => setState(() => _selectedMotoBrand = v),
    );
  }

  Widget _buildStatistiquesSection() {
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    return MarqueSellerStatsSection(
      isVendeur: isVendeur,
      vendeurType: _statsVendeurType ?? _userService.vendeurType,
      voitures: voituresRecommandees,
      motos: motosRecommandees,
      pieces: articlesPieces,
      backendViews: _backendViews,
      vehiclesOnline: _statsVehiclesOnline,
      piecesOnline: _statsPiecesOnline,
      vehiclesSold: _statsVehiclesSold,
      piecesSold: _statsPiecesSold,
      isLoading: _sellerMarqueStatsLoading,
    );
  }
  // Section Localisation (visible pour rôles non-vendeurs)
  Widget _buildLocalisationSection() {
    return MarqueLocalisationSection(
      selected: _selectedLocation,
      onSelected: (v) => setState(() => _selectedLocation = v),
    );
  }

  // Section Budget (visible pour rôles non-vendeurs)
  Widget _buildBudgetSection() {
    return MarqueBudgetFilterButton(onPressed: _openBudgetSheet);
  }

  void _openBudgetSheet() {
    final onlinePrices = voituresRecommandees
        .where((v) => (v.statut ?? 'en_ligne') == 'en_ligne')
        .map((v) => double.tryParse(v.prix.replaceAll(RegExp(r'[^0-9.]'), '')))
        .whereType<double>()
        .toList();

    showMarqueBudgetSheet(
      context: context,
      onlinePrices: onlinePrices,
      initialMin: _budgetMin,
      initialMax: _budgetMax,
      onApply: (min, max) {
        setState(() {
          _budgetMin = min;
          _budgetMax = max;
        });
      },
    );
  }
}
