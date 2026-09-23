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
import 'package:url_launcher/url_launcher.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/page_refresh_registry.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/widgets/page_pull_refresh.dart';
import 'package:tranoo/utils/catalog_filter_options.dart';
import 'package:tranoo/widgets/catalog_filter_sections.dart';
import 'package:tranoo/widgets/transitaire_carousel_section.dart';
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
import 'package:tranoo/data/screens/marque/marque_sponsored_pub.dart';
import 'package:tranoo/data/screens/marque/marque_flyer_preview.dart';
import 'package:tranoo/data/screens/marque/marque_catalog_controller.dart';
import 'package:tranoo/data/screens/marque/marque_search_bar.dart';

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
      await _catalog.refreshAll(
        loadSellerStats: _userService.currentRole == UserRole.vendeur
            ? _loadSellerMarqueStats
            : null,
      );
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
  late final MarqueCatalogController _catalog;
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

  // Recherche globale (barre en haut)
  final TextEditingController _searchGlobalController = TextEditingController();

  final _logger = Logger('MarquePage');

  // Filtres
  String? _selectedBrand;
  String? _selectedLocation;
  double? _budgetMin;
  double? _budgetMax;

  final ViewsService _viewsService = ViewsService();

  @override
  void initState() {
    super.initState();

    _catalog = MarqueCatalogController(
      repository: _marqueRepo,
      isVendeur: () => _userService.currentRole == UserRole.vendeur,
      isMounted: () => mounted,
    );
    _catalog.onPubsALaUneUpdated = (pubs) {
      if (pubs.isNotEmpty) _startCarouselTimer();
      _precachePubImages(pubs);
    };
    _catalog.onPubsPrecache = _precachePubImages;
    _catalog.onVoituresPrecache = _precacheArticleVoitureThumbs;
    _catalog.onPiecesPrecache = _precachePieceThumbs;
    _catalog.onCatalogLoaded = () {
      unawaited(_loadBackendViews());
    };
    _catalog.addListener(() {
      if (mounted) setState(() {});
    });

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
      _logger.info(
        '[DEBUG] 🔍 Recherche tapée: "${_searchGlobalController.text}"',
      );
    });

    // Configuration du carrousel automatique
    _startCarouselTimer();
    unawaited(_catalog.primeFromStaleCache());
    unawaited(_catalog.loadInitial(
      loadSellerStats: isVendeur ? _loadSellerMarqueStats : null,
    ));
    _marqueAutoRefreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted) return;
      await _catalog.refreshSilent();
    });
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

  void _recordVehicleInteraction(String articleId) async {
    if (articleId.isEmpty) return;

    // Optimistic UI: incrémenter localement le compteur backend (puis sync)
    _catalog.bumpViewOptimistic(articleId);

    // Enregistrer la vue sur le backend (compteur global)
    try {
      await _viewsService.recordView(articleId);
      _logger.info('[VIEWS] Vue enregistrée pour l\'article: $articleId');
      final viewsData = await _viewsService.getArticleViews(articleId);
      if (viewsData != null && viewsData['success'] == true && mounted) {
        _catalog.setBackendView(
          articleId,
          (viewsData['views'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (e) {
      _logger.warning('[VIEWS] Erreur enregistrement vue backend: $e');
    }
  }

  // Charger les vues depuis le backend pour les véhicules recommandés
  Future<void> _loadBackendViews() async {
    try {
      final ids = <String>{
        ..._catalog.voitures.map((e) => e.id).where((e) => e.isNotEmpty),
        ..._catalog.pieces.map((e) => e.id).where((e) => e.isNotEmpty),
      }.toList();
      if (ids.isEmpty) return;

      final nextViews = Map<String, int>.from(_catalog.backendViews);
      for (final id in ids) {
        final viewsData = await _viewsService.getArticleViews(id);
        if (viewsData != null && viewsData['success'] == true) {
          nextViews[id] =
              (viewsData['views'] as num?)?.toInt() ?? (nextViews[id] ?? 0);
        }
      }
      if (!mounted) return;
      _catalog.replaceBackendViews(nextViews);
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
    return _catalog.voitures.map((v) => v.toArticleMap()).toList();
  }

  List<Map<String, dynamic>> _catalogMotoMapsForFilters() {
    return _catalog.motos.map((m) => m.toArticleMap()).toList();
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

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted || _catalog.pubsALaUne.isEmpty) return;
      if (_currentPage < _catalog.pubsALaUne.length - 1) {
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

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _marqueAutoRefreshTimer?.cancel();
    _catalog.dispose();
    _tabController.dispose();
    _pageController.dispose();
    _searchGlobalController.dispose();
    super.dispose();
  }


  Widget buildVoituresRecommandeesSection() {
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final voituresEnLigne = _catalog.voitures
        .where(
          (v) =>
              (v.statut ?? 'en_ligne') == 'en_ligne' &&
              (v.statut ?? '') != 'vendu',
        )
        .toList();
    return MarqueVoituresSection(
      voitures: _applyFilters(voituresEnLigne),
      isLoading: _catalog.isLoadingVoitures,
      error: _catalog.errorVoitures,
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
    final motosEnLigne = _applyMotoFilters(_catalog.motos
        .where(
          (m) =>
              (m.statut ?? 'en_ligne') == 'en_ligne' &&
              (m.statut ?? '') != 'vendu',
        )
        .toList());
    return MarqueMotosSection(
      motos: motosEnLigne,
      isLoading: _catalog.isLoadingMotos,
      error: _catalog.errorMotos,
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
    final piecesEnLigne = _catalog.pieces
        .where(
          (p) =>
              (p.statut ?? 'en_ligne') == 'en_ligne' &&
              (p.statut ?? '') != 'vendu',
        )
        .toList();
    return MarquePiecesSection(
      pieces: piecesEnLigne,
      isLoading: _catalog.isLoadingPieces,
      error: _catalog.errorPieces,
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
      pubs: _catalog.pubsSponsorisees,
      isLoading: _catalog.isLoadingPubs,
      error: _catalog.errorPubs,
      onPubTap: (pub) => handleMarqueSponsoredPubTap(
        context: context,
        pub: pub,
        repository: _marqueRepo,
      ),
    );
  }

  Widget buildPubsALaUneCarousel() {
    return MarquePubsCarousel(
      pubs: _catalog.pubsALaUne,
      isLoading: _catalog.isLoadingPubs,
      error: _catalog.errorPubs,
      pageController: _pageController,
      onOpenLink: _openPubLink,
      onOpenFlyer: (url) => showMarqueFlyerPreview(context, url),
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
    final isInitialHomeLoading = _catalog.isLoadingPubs &&
        _catalog.pubsALaUne.isEmpty &&
        _catalog.isLoadingVoitures &&
        _catalog.voitures.isEmpty;

    return Scaffold(
      body: Column(
        children: [
          if (!isVendeur)
            MarqueSearchBar(
              controller: _searchGlobalController,
              hintText: l10n.searchVehiclesPartsHint,
              onFilterPressed: () {
                if (_searchGlobalController.text.trim().isNotEmpty) {
                  _showFilterHint();
                } else {
                  _showFilterDialog();
                }
              },
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
    if (_catalog.isLoadingVoitures && _catalog.voitures.isEmpty) {
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
    if (_catalog.isLoadingMotos && _catalog.motos.isEmpty) {
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
      voitures: _catalog.voitures,
      motos: _catalog.motos,
      pieces: _catalog.pieces,
      backendViews: _catalog.backendViews,
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
    final onlinePrices = _catalog.voitures
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
