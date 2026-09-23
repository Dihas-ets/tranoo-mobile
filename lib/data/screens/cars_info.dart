import 'package:flutter/material.dart';
import 'movie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:confetti/confetti.dart';
import 'dart:developer';
import 'verification_payment.dart'; // Import pour la page de vérification de paiement
import 'package:url_launcher/url_launcher.dart';
import 'package:tranoo/utils/auth_dialog.dart';
import 'package:tranoo/utils/article_view_helper.dart';
import 'package:tranoo/utils/text_display.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/tranoo_toast.dart';
import 'package:tranoo/utils/transit_parcours_guard.dart';
import 'package:tranoo/widgets/transitaire_carousel_section.dart';
import 'package:tranoo/services/transit_mission_service.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/utils/whatsapp_helper.dart';
import 'package:tranoo/data/repositories/catalog_repository.dart';
import 'package:tranoo/widgets/catalog_detail_sections.dart';

class CarsInfo extends StatefulWidget {
  final String? id;
  final String? titre;
  final String? description;
  final String? marque;
  final String? modele;
  final String? annee;
  final String? prix;
  final String? condition;
  final String? boiteVitesse;
  final String? carburant;
  final String? climatiseur;
  final String? distance;
  final String? sieges;
  final String? portes;
  final String? cylindre; // Ajouté
  final String? couleur; // Couleur
  final bool? dedouanement; // Dédouanement
  final String? lieu;
  final List<String> images;
  final List<String> videos;
  final String? video;
  final String? videoOptimized;
  final int? selectedImageIndex;
  final String? entreprise;
  final bool fromPub;

  const CarsInfo({
    super.key,
    this.id,
    this.titre,
    this.description,
    this.marque,
    this.modele,
    this.annee,
    this.prix,
    this.condition,
    this.boiteVitesse,
    this.carburant,
    this.climatiseur,
    this.distance,
    this.sieges,
    this.portes,
    this.cylindre,
    this.couleur,
    this.dedouanement,
    this.lieu,
    required this.images,
    this.videos = const [],
    this.video,
    this.videoOptimized,
    this.selectedImageIndex,
    this.entreprise,
    this.fromPub = false,
  });

  @override
  State<CarsInfo> createState() => _CarsinfoState();
}

class _CarsinfoState extends State<CarsInfo> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  final _catalogRepo = CatalogRepository();

  late int _currentImageIndex; // Gère l'image actuelle affichée
  late PageController _pageController;
  late List<String> _videos; // Vidéos associées
  Set<String> _favoriteIds = <String>{};
  String? _selectedCountry;
  String? get _primaryVideo => _videos.isNotEmpty
      ? _videos.first
      : (widget.videoOptimized ?? widget.video);
  final List<String> africanCountries = [
    'Bénin',
    'Burkina Faso',
    'Côte d\'Ivoire',
    'Mali',
    'Niger',
    'Sénégal',
    'Togo',
    'Cameroun',
    'Gabon',
    'Guinée',
    'Congo',
    'RDC',
    'Maroc',
    'Algérie',
    'Tunisie',
    'Afrique du Sud',
    'Nigeria',
    'Ghana',
    'Kenya',
    'Éthiopie',
  ];
  late ConfettiController _confettiController;
  static const String _whatsAppPhone = '22941839801'; // sans +
  bool _isSpecsExpanded = false;
  int _verificationPrice = 20000;
  String _formatFcfa(int value) {
    final priceStr = value.toString();
    final reversed = priceStr.split('').reversed.join('');
    final withDots = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (Match m) => '${m[0]}.',
    );
    return withDots.split('').reversed.join('');
  }

  String get _verificationPriceLabel => '${_formatFcfa(_verificationPrice)} FCFA';

  String _conditionLabel(AppLocalizations l10n, String? value) =>
      catalogConditionLabel(
        value: value,
        newLabel: l10n.newCondition,
        usedLabel: l10n.usedCondition,
        fallback: l10n.notProvided,
      );

  String _specValue(AppLocalizations l10n, String? value) =>
      catalogSpecValue(value, l10n.notProvided);

  String _locationSpecValue(AppLocalizations l10n) {
    final raw = concatLocationParts(
      location: widget.lieu,
      company: widget.entreprise,
    );
    if (raw.isEmpty) return l10n.notProvided;
    return truncateWithEllipsis(raw);
  }

  String _yesNoValue(AppLocalizations l10n, bool? value) {
    if (value == null) return l10n.notProvided;
    return value ? l10n.yes : l10n.no;
  }

  bool _transitaireDejaChoisi = false;

  bool _missionHasTransitaire(Map<String, dynamic> mission) {
    final t = mission['transitaire'];
    if (t == null) return false;
    if (t is Map) {
      final id = (t['_id'] ?? t['id'])?.toString().trim() ?? '';
      return id.isNotEmpty;
    }
    return t.toString().trim().isNotEmpty;
  }

  Future<void> _restoreTransitParcours() async {
    final articleId = widget.id;
    if (articleId == null || articleId.isEmpty) return;
    final mission =
        await TransitMissionService.instance.getParcours(articleId);
    if (!mounted || mission == null) return;
    final mode = (mission['modeLivraison'] ?? '').toString();
    final pays = (mission['paysDestination'] ?? '').toString();
    final details = (mission['detailsSupplementaires'] ?? '').toString();
    setState(() {
      _transitaireDejaChoisi = _missionHasTransitaire(mission);
      if (mode == 'transit') {
        _isEnTransitChecked = true;
        _isEnConsommationChecked = false;
      } else if (mode == 'consommation') {
        _isEnConsommationChecked = true;
        _isEnTransitChecked = false;
      }
      if (pays.isNotEmpty) _selectedCountry = pays;
      if (details.isNotEmpty) _detailsController.text = details;
    });
  }

  Future<void> _persistTransitOptions() async {
    final articleId = widget.id;
    if (articleId == null || articleId.isEmpty) return;
    if (!_isEnConsommationChecked && !_isEnTransitChecked) return;
    if (_selectedCountry == null || _selectedCountry!.isEmpty) return;

    await TransitMissionService.instance.startParcours(
      articleId: articleId,
      articleTitre: _articleDisplayTitle,
      modeLivraison: _isEnTransitChecked ? 'transit' : 'consommation',
      paysDestination: _selectedCountry,
      detailsSupplementaires: _detailsController.text.trim().isEmpty
          ? null
          : _detailsController.text.trim(),
    );
  }

  String get _articleDisplayTitle {
    final titre = (widget.titre ?? '').trim();
    if (titre.isNotEmpty) return titre;
    final composed =
        '${widget.annee ?? ''} ${widget.marque ?? ''} ${widget.modele ?? ''}'
            .trim();
    return composed.isNotEmpty ? composed : 'Véhicule';
  }

  Future<void> _startTransitParcours() async {
    final articleId = widget.id;
    if (articleId == null || articleId.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await TransitMissionService.instance.startParcours(
      articleId: articleId,
      articleTitre: _articleDisplayTitle,
    );
  }

  Future<void> _loadVerificationPrice() async {
    final parsed = await _catalogRepo.fetchVerificationPricing();
    if (parsed != null && mounted) {
      setState(() => _verificationPrice = parsed);
    }
  }

  @override
  void initState() {
    super.initState();
    trackArticleView(widget.id);
    _startTransitParcours();
    _restoreTransitParcours();
    _loadVerificationPrice();
    // Log toutes les valeurs reçues
    log('[CarsInfo] titre: ${widget.titre}');
    log('[CarsInfo] description: ${widget.description}');
    log('[CarsInfo] marque: ${widget.marque}');
    log('[CarsInfo] modele: ${widget.modele}');
    log('[CarsInfo] annee: ${widget.annee}');
    log('[CarsInfo] prix: ${widget.prix}');
    log('[CarsInfo] condition: ${widget.condition}');
    log('[CarsInfo] boiteVitesse: ${widget.boiteVitesse}');
    log('[CarsInfo] carburant: ${widget.carburant}');
    log('[CarsInfo] climatiseur: ${widget.climatiseur}');
    log('[CarsInfo] distance: ${widget.distance}');
    log('[CarsInfo] sieges: ${widget.sieges}');
    log('[CarsInfo] portes: ${widget.portes}');
    log('[CarsInfo] cylindre: ${widget.cylindre}');
    log('[CarsInfo] images: ${widget.images}');
    log('[CarsInfo] video: ${widget.video}');
    _videos = widget.videos.isNotEmpty
        ? widget.videos.where((v) => v.isNotEmpty).toList()
        : (widget.video != null && widget.video!.isNotEmpty
            ? [widget.video!]
            : <String>[]);
    log('[CarsInfo] videos: $_videos');
    log('[CarsInfo] selectedImageIndex: ${widget.selectedImageIndex}');
    final totalMediaCount = widget.images.length + _videos.length;
    // Correction RangeError : si la liste est vide, index = 0
    if (totalMediaCount == 0) {
      _currentImageIndex = 0;
    } else if (widget.selectedImageIndex != null &&
        widget.selectedImageIndex! >= 0 &&
        widget.selectedImageIndex! < widget.images.length) {
      _currentImageIndex = widget.selectedImageIndex!;
    } else {
      _currentImageIndex = 0;
    }
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _pageController = PageController(
      initialPage: _currentImageIndex.clamp(
        0,
        totalMediaCount > 0 ? totalMediaCount - 1 : 0,
      ),
    );
  }

  void _openImageViewer(int startIndex) {
    showCatalogFullscreenImageViewer(
      context,
      images: widget.images,
      startIndex: startIndex,
    );
  }

  void _precacheAdjacentImages(int index) {
    if (!mounted || widget.images.isEmpty) return;
    final w = cloudinaryWidthPx(context);
    final urls = <String>[];
    for (final delta in [-1, 0, 1]) {
      final i = index + delta;
      if (i < 0 || i >= widget.images.length) continue;
      final url = widget.images[i].trim();
      if (url.startsWith('http')) urls.add(url);
    }
    precacheTranooImages(context, urls, cloudinaryWidthPx: w, maxCount: 3);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _buyWhatsAppMessage(AppLocalizations l10n) {
    final label = WhatsappHelper.articleListingLabel(
      titre: widget.titre,
      marque: widget.marque,
      modele: widget.modele,
      fallback: l10n.defaultVehicleTitle,
    );
    final id = (widget.id ?? '').trim();
    if (id.isNotEmpty) {
      return l10n.whatsappCarInterestWithRef(label, id);
    }
    return l10n.whatsappCarInterestNoRef(label);
  }

  Future<void> _openWhatsApp({String? message}) async {
    await WhatsappHelper.openChat(
      context,
      phone: _whatsAppPhone,
      message: message,
      unavailableMessage: l10n.sellerPhoneUnavailable,
      cannotOpenMessage: l10n.whatsappOpenDetailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // On garde uniquement les acheteurs, donc toujours true
    final isAcheteurOuChauffeur = true;

    // Récupération des dimensions de l'écran pour la responsivité
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // LOGS DEBUG
    log('[CarsInfo][build] widget.images.length = ${widget.images.length}');
    log('[CarsInfo][build] _currentImageIndex = $_currentImageIndex');
    if (widget.images.isNotEmpty) {
      log('[CarsInfo][build] Première image = ${widget.images[0]}');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: Container(
        color: const Color(0xFFF9FAFB),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildImageSection(screenWidth, screenHeight, l10n),
            _buildContentSection(screenWidth, isAcheteurOuChauffeur, l10n),
          ],
        ),
      ),
    );
  }

  // Barre d'application avec bouton de retour et partage
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // Affiche l'image principale sélectionnée
  Widget _buildImageSection(
    double screenWidth,
    double screenHeight,
    AppLocalizations l10n,
  ) {
    return CatalogDetailMediaSection(
      screenHeight: screenHeight,
      pageController: _pageController,
      images: widget.images,
      videos: _videos,
      primaryVideo: _primaryVideo,
      conditionLabel: _conditionLabel(l10n, widget.condition),
      isNewCondition: catalogIsNewCondition(widget.condition),
      onPageChanged: (i) {
        setState(() => _currentImageIndex = i);
        _precacheAdjacentImages(i);
      },
      onImageTap: _openImageViewer,
      onVideoPageTap: (videoUrl) {
        if (videoUrl == null || videoUrl.isEmpty) return;
        final article = {
          'id': widget.id,
          'titre': widget.titre,
          'description': widget.description,
          'marque': widget.marque,
          'modele': widget.modele,
          'annee': widget.annee,
          'prix': widget.prix,
          'photos': widget.images,
          'video': videoUrl,
          'entreprise': widget.entreprise,
          'type': 'voiture',
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Movie(videoUrl: videoUrl, article: article),
          ),
        );
      },
      onFavoriteTap: () => _toggleFavorite(widget.id ?? ''),
      onPlayVideoTap: () {
        final videoUrl = _primaryVideo;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          final article = {
            'titre': widget.titre,
            'description': widget.description,
            'marque': widget.marque,
            'modele': widget.modele,
            'annee': widget.annee,
            'prix': widget.prix,
            'condition': widget.condition,
            'boiteVitesse': widget.boiteVitesse,
            'carburant': widget.carburant,
            'climatiseur': widget.climatiseur,
            'distance': widget.distance,
            'sieges': widget.sieges,
            'portes': widget.portes,
            'cylindre': widget.cylindre,
            'couleur': widget.couleur,
            'dedouanement': widget.dedouanement,
            'photos': widget.images,
            'video': videoUrl,
            'entreprise': widget.entreprise,
            'type': 'voiture',
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Movie(videoUrl: videoUrl, article: article),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noVideoAvailable)),
          );
        }
      },
      onWhatsAppTap: () async {
        await _openWhatsApp();
      },
      onCallTap: () async {
        final url = 'tel:+2290141839801';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cannotMakeCall)),
          );
        }
      },
    );
  }

  Future<void> _toggleFavorite(String articleId) async {
    final isFav = _favoriteIds.contains(articleId);
    final ok = await _catalogRepo.toggleFavorite(
      articleId: articleId,
      isFavorite: isFav,
    );
    if (!ok || !mounted) return;
    setState(() {
      if (isFav) {
        _favoriteIds.remove(articleId);
      } else {
        _favoriteIds.add(articleId);
      }
    });
  }

  // Section des détails et spécifications
  Widget _buildContentSection(
    double screenWidth,
    bool isAcheteur,
    AppLocalizations l10n,
  ) {
    final bool shouldShowDeliveryOptions =
        isAcheteur || (widget.fromPub == true);
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04), // Espacement ajusté
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(screenWidth, l10n),
          const SizedBox(height: 16),
          _buildDescription(l10n),
          const SizedBox(height: 24),
          _buildSpecifications(l10n),
          const SizedBox(height: 24),
          _buildCheckboxes(screenWidth, shouldShowDeliveryOptions, l10n),
          if ((_isEnConsommationChecked || _isEnTransitChecked) &&
              !_transitaireDejaChoisi) ...[
            const SizedBox(height: 20),
            _buildTransitairesSection(l10n),
          ],
          const SizedBox(height: 24),
          _buildActionButton(isAcheteur, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth, AppLocalizations l10n) {
    return CatalogDetailHeader(
      screenWidth: screenWidth,
      titre: widget.titre,
      entreprise: widget.entreprise,
      prix: widget.prix,
      notProvidedLabel: l10n.notProvided,
    );
  }

  // Description de la voiture
  Widget _buildDescription(AppLocalizations l10n) {
    return Text(
      widget.description ?? l10n.sampleCarDescription,
      style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
    );
  }

  Widget _buildSpecGrid(List<Widget> cards) {
    return CatalogDetailSpecGrid(cards: cards);
  }

  Widget _buildSpecifications(AppLocalizations l10n) {
    final topCards = <Widget>[
      _buildSpecCard(
        l10n.cylinder,
        _specValue(l10n, widget.cylindre),
        Icons.settings,
      ),
      _buildSpecCard(
        l10n.fuel,
        _specValue(l10n, widget.carburant),
        Icons.local_gas_station,
      ),
      _buildSpecCard(
        l10n.airConditioner,
        _specValue(l10n, widget.climatiseur),
        Icons.ac_unit,
      ),
      _buildSpecCard(
        l10n.distanceKm,
        _specValue(l10n, widget.distance),
        Icons.speed,
      ),
      _buildSpecCard(
        l10n.location,
        _locationSpecValue(l10n),
        Icons.location_on,
      ),
      _buildSpecCard(
        l10n.seats,
        _specValue(l10n, widget.sieges),
        Icons.event_seat,
      ),
    ];
    final bottomCards = <Widget>[
      _buildSpecCard(
        l10n.doors,
        _specValue(l10n, widget.portes),
        Icons.door_front_door,
      ),
      _buildSpecCard(
        l10n.gearbox,
        _specValue(l10n, widget.boiteVitesse),
        Icons.settings,
      ),
      _buildSpecCardWithColor(
        l10n.colorField,
        _specValue(l10n, widget.couleur),
        Icons.palette,
        widget.couleur,
      ),
      _buildSpecCard(
        l10n.customsClearance,
        _yesNoValue(l10n, widget.dedouanement),
        Icons.check_circle,
      ),
    ];

    final allCards = [...topCards, ...bottomCards];
    final hasMore = allCards.length > 4;
    final visibleCards = (_isSpecsExpanded || !hasMore)
        ? allCards
        : allCards.take(4).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSpecGrid(visibleCards),
        if (hasMore) ...[
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isSpecsExpanded = !_isSpecsExpanded;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isSpecsExpanded ? l10n.viewLess : l10n.viewMore,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2B4B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _isSpecsExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: Color(0xFF1B2B4B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<bool> _ensureTransitInfoForBrowse() async {
    final error = TransitParcoursGuard.validateBrowse(
      transitChecked: _isEnTransitChecked,
      consommationChecked: _isEnConsommationChecked,
      paysDestination: _selectedCountry,
    );
    if (error != null) {
      if (!mounted) return false;
      showTranooToast(context, message: error, isError: true);
      return false;
    }
    await _persistTransitOptions();
    return true;
  }

  Future<bool> _ensureTransitInfoForSelect() async {
    return _ensureTransitInfoForBrowse();
  }

  void _onTransitaireChosen() {
    if (!mounted) return;
    showTranooToast(
      context,
      message: 'Transitaire choisi pour ce véhicule',
      isSuccess: true,
    );
  }

  Widget _buildTransitairesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recommendedForwarders,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B2B4B),
          ),
        ),
        const SizedBox(height: 8),
        TransitaireCarouselSection(
          showTitle: false,
          showSeeMoreButton: true,
          articleId: widget.id,
          beforeBrowseTransitaire: _ensureTransitInfoForBrowse,
          beforeSelectTransitaire: _ensureTransitInfoForSelect,
          onSelectSuccess: _onTransitaireChosen,
        ),
      ],
    );
  }

  Widget _buildSpecCard(String title, String value, IconData icon) =>
      catalogSpecCard(title, value, icon);

  Widget _buildSpecCardWithColor(
    String title,
    String value,
    IconData icon,
    String? couleur,
  ) =>
      catalogSpecCardWithColor(title, value, icon, couleur);

  // Cases à cocher et champs de livraison (ramenés ici)
  bool _isEnConsommationChecked = false;
  bool _isEnTransitChecked = false;
  final TextEditingController _detailsController = TextEditingController();

  Widget _buildCheckboxes(
    double screenWidth,
    bool shouldShowDeliveryOptions,
    AppLocalizations l10n,
  ) {
    if (!shouldShowDeliveryOptions) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isEnConsommationChecked,
              onChanged: (v) {
                setState(() {
                  _isEnConsommationChecked = v ?? false;
                  if (_isEnConsommationChecked) _isEnTransitChecked = false;
                });
                _persistTransitOptions();
              },
              activeColor: Colors.black,
            ),
            Text(l10n.inConsumption),
            const SizedBox(width: 16),
            Checkbox(
              value: _isEnTransitChecked,
              onChanged: (v) {
                setState(() {
                  _isEnTransitChecked = v ?? false;
                  if (_isEnTransitChecked) _isEnConsommationChecked = false;
                });
                _persistTransitOptions();
              },
              activeColor: Colors.black,
            ),
            Text(l10n.inTransit),
          ],
        ),
        const SizedBox(height: 12),
        Text(l10n.location, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              hint: Text(
                l10n.chooseCountry,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              isExpanded: true,
              items: africanCountries
                  .map(
                    (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCountry = value);
                _persistTransitOptions();
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.additionalDetails,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _detailsController,
          onChanged: (_) => _persistTransitOptions(),
          decoration: InputDecoration(
            hintText: l10n.enterDestinationDetails,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // Bouton d'action dynamique - Toujours afficher les 2 boutons (bleu + jaune) pour les acheteurs
  Widget _buildActionButton(bool isAcheteurOuChauffeur, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final firebaseUser = FirebaseAuth.instance.currentUser;
              if (firebaseUser == null) {
                showAuthDialog(context, message: l10n.signInForVerification);
                return;
              }

              if (!_isEnConsommationChecked && !_isEnTransitChecked) {
                showTranooToast(
                  context,
                  message: l10n.chooseDeliveryMode,
                  isError: true,
                );
                return;
              }
              if (_selectedCountry == null || _selectedCountry!.isEmpty) {
                showTranooToast(
                  context,
                  message: l10n.selectLocationPlease,
                  isError: true,
                );
                return;
              }

              _persistTransitOptions();

              final article = {
                '_id': widget.id, // Doit être l'ID Mongo réel
                'titre': widget.titre,
                'description': widget.description,
                'marque': widget.marque,
                'modele': widget.modele,
                'annee': widget.annee,
                'prix': widget.prix,
                'condition': widget.condition,
                'boiteVitesse': widget.boiteVitesse,
                'carburant': widget.carburant,
                'climatiseur': widget.climatiseur,
                'distance': widget.distance,
                'sieges': widget.sieges,
                'portes': widget.portes,
                'cylindre': widget.cylindre,
                'couleur': widget.couleur,
                'dedouanement': widget.dedouanement,
                'photos': widget.images,
                'video': _primaryVideo,
                'entreprise': widget.entreprise,
                'type': 'voiture',
                'modeLivraison':
                    _isEnTransitChecked ? 'transit' : 'consommation',
                'paysDestination': _selectedCountry,
                'detailsSupplementaires': _detailsController.text.trim(),
              };
              log('[CarsInfo][verif] Article payload: $article');

              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/smiley.png',
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.verificationInProgress,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(text: l10n.verificationChecksPrefix),
                              TextSpan(
                                text: l10n.tenBusinessDays,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFA000),
                                ),
                              ),
                              TextSpan(text: l10n.verificationChecksMiddle),
                              TextSpan(
                                text: l10n.verificationFeesLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00A86B),
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _verificationPriceLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A86B),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VerificationPaymentScreen(
                                    articleId: widget.id.toString(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(l10n.payVerificationFees),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                l10n.requestVerification,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              // Vérifier l'authentification avant de continuer
              final firebaseUser = FirebaseAuth.instance.currentUser;
              if (firebaseUser == null) {
                showAuthDialog(context, message: l10n.signInToBuyThisCar);
                return;
              }

              await _openWhatsApp(message: _buyWhatsAppMessage(l10n));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.buyThisCar,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
