import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'movie.dart';
import 'package:tranoo/services/user_service.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:confetti/confetti.dart';
import 'dart:developer';
import 'verification_payment.dart'; // Import pour la page de vérification de paiement
import 'package:tranoo/services/views_service.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/services/alert_service.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';
import 'package:tranoo/utils/auth_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tranoo/utils/auth_dialog.dart';
import 'package:tranoo/utils/article_view_helper.dart';
import 'package:tranoo/utils/text_display.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/widgets/spec_info_card.dart';
import 'package:tranoo/widgets/transitaire_carousel_section.dart';

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

  late int _currentImageIndex; // Gère l'image actuelle affichée
  late PageController _pageController;
  late List<String> _videos; // Vidéos associées
  Set<String> _favoriteIds = <String>{};
  String? _selectedCountry;
  int get _imagesCount => widget.images.length;
  int get _videosCount => _videos.length;
  int get _totalMediaCount => _imagesCount + _videosCount;
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

  bool _isNewCondition(String? value) {
    final lower = (value ?? '').toLowerCase();
    return lower == 'nouveau' || lower == 'neuf' || lower == 'new';
  }

  String _conditionLabel(AppLocalizations l10n, String? value) {
    if (_isNewCondition(value)) return l10n.newCondition;
    final lower = (value ?? '').toLowerCase();
    if (lower == 'occasion' || lower == 'used') return l10n.usedCondition;
    return value ?? l10n.notProvided;
  }

  String _specValue(AppLocalizations l10n, String? value) {
    if (value != null && value.isNotEmpty) return value;
    return l10n.notProvided;
  }

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

  Future<void> _loadVerificationPrice() async {
    try {
      final url =
          '${UserService().dio.options.baseUrl}/admin/verification-pricing';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = data['prixVerification'] ??
            (data['pricing'] is Map
                ? data['pricing']['prixVerification']
                : null);
        final parsed = int.tryParse('$raw');
        if (parsed != null && parsed >= 0 && mounted) {
          setState(() => _verificationPrice = parsed);
        }
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    trackArticleView(widget.id);
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
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (ctx) {
        final controller = PageController(initialPage: startIndex);
        return GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 5,
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: controller,
                    count: widget.images.length,
                    effect: WormEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white24,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    // Aligné sur Tranoo Pro : uniquement wa.me + app externe, jamais le Play Store.
    final phone = _whatsAppPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (e) {
      log('[CarsInfo] WhatsApp launchUrl error: $e');
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.whatsappOpenDetailed)),
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
    log(
      '[CarsInfo][_buildImageSection] widget.images.length = ${widget.images.length}',
    );
    log(
      '[CarsInfo][_buildImageSection] _currentImageIndex = $_currentImageIndex',
    );
    if (widget.images.isNotEmpty && _currentImageIndex < widget.images.length) {
      log(
        '[CarsInfo][_buildImageSection] Image affichée = ${widget.images[_currentImageIndex]}',
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: screenHeight * 0.4,
          width: double.infinity,
          child: _totalMediaCount > 0
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: _totalMediaCount,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (context, index) {
                    if (index < _imagesCount) {
                      final hasImage = index < widget.images.length &&
                          widget.images[index].isNotEmpty;
                      if (!hasImage) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 80),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () => _openImageViewer(index),
                        child: ClipRect(
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Image.network(
                              widget.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Text(l10n.imageNotAvailable),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      final videoIndex = index - _imagesCount;
                      final videoUrl = videoIndex < _videos.length
                          ? _videos[videoIndex]
                          : _primaryVideo;
                      return VideoPreviewPlaceholder(
                        videoUrl: videoUrl,
                        iconSize: 60,
                        onTap: () {
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
                              builder: (context) =>
                                  Movie(videoUrl: videoUrl, article: article),
                            ),
                          );
                        },
                      );
                    }
                  },
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 80),
                  ),
                ),
        ),
        // Badge condition (gauche)
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isNewCondition(widget.condition)
                  ? Colors.purple
                  : const Color(0xFFF8BF13),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _conditionLabel(l10n, widget.condition),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Icônes verticales (droite)
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              // Vue (remplacement du favori pour cohérence avec les cards)
              GestureDetector(
                onTap: () => _toggleFavorite(widget.id ?? ''),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Icône play vidéo
              GestureDetector(
                onTap: () {
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
                        builder: (context) =>
                            Movie(videoUrl: videoUrl, article: article),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.noVideoAvailable)),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      _primaryVideo != null ? Colors.white : Colors.grey[300],
                  child: Icon(
                    Icons.play_circle_fill,
                    color: _primaryVideo != null ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // WhatsApp
              GestureDetector(
                onTap: () async {
                  await _openWhatsApp();
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/images/whatsapp_icon.png',
                    width: 22,
                    height: 22,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.chat_bubble_outline,
                      color: Color(0xFF25D366),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Appel téléphonique
              GestureDetector(
                onTap: () async {
                  final url = 'tel:+2290141839801';
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.cannotMakeCall)),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.phone,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Dots indicator
        if (_totalMediaCount > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _totalMediaCount,
                effect: JumpingDotEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white70,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _toggleFavorite(String articleId) async {
    if (articleId.isEmpty) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) return;
      final isFav = _favoriteIds.contains(articleId);
      final uri = Uri.parse(
        '${UserService().dio.options.baseUrl}/users/me/favoris',
      );
      final response = await (isFav
          ? http.delete(
              uri,
              headers: {
                'Authorization': 'Bearer $idToken',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'articleId': articleId}),
            )
          : http.post(
              uri,
              headers: {
                'Authorization': 'Bearer $idToken',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'articleId': articleId}),
            ));
      if (response.statusCode == 200) {
        setState(() {
          if (isFav) {
            _favoriteIds.remove(articleId);
          } else {
            _favoriteIds.add(articleId);
          }
        });
      }
    } catch (_) {}
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
          const SizedBox(height: 24),
          _buildActionButton(isAcheteur, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (widget.titre != null && widget.titre!.isNotEmpty)
              ? widget.titre!
              : l10n.notProvided,
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        //Nom de l'entreprise
        Text(
          AuthConfig.displayEntreprise(widget.entreprise),
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 8),
        Text(
          (widget.prix != null && widget.prix!.isNotEmpty)
              ? '${formatPrice(widget.prix!)} FCFA'
              : l10n.notProvided,
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ],
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: cards,
    );
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSpecGrid(topCards),
        const SizedBox(height: 16),
        const TransitaireCarouselSection(
          showTitle: true,
          showSeeMoreButton: true,
          height: 116,
        ),
        const SizedBox(height: 16),
        _buildSpecGrid(bottomCards),
      ],
    );
  }

  // Map des couleurs
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

  // Carte d'information générique pour les spécifications
  Widget _buildSpecCard(String title, String value, IconData icon) {
    return SpecInfoCard(title: title, value: value, icon: icon);
  }

  Widget _buildSpecCardWithColor(
    String title,
    String value,
    IconData icon,
    String? couleur,
  ) {
    Widget? swatch;
    if (couleur != null && _couleurs.containsKey(couleur)) {
      swatch = Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: _couleurs[couleur],
          border: Border.all(
            color: _couleurs[couleur] == Colors.white
                ? Colors.grey
                : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }
    return SpecInfoCard(
      title: title,
      value: value,
      icon: icon,
      valueTrailing: swatch,
    );
  }

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
              onChanged: (value) => setState(() => _selectedCountry = value),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.chooseDeliveryMode)),
                );
                return;
              }
              if (_selectedCountry == null || _selectedCountry!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.selectLocationPlease)),
                );
                return;
              }

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

              await _openWhatsApp();
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
