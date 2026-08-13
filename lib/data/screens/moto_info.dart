import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'movie.dart';
import 'package:tranoo/services/user_service.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:confetti/confetti.dart';
import 'dart:developer';
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
import 'package:tranoo/utils/whatsapp_helper.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';

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

class MotoInfo extends StatefulWidget {
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
  final Map<String, dynamic>? fournisseur;
  final Map<String, dynamic>? vendeur;
  final List<String> images;
  final List<String> videos;
  final String? video;
  final String? videoOptimized;
  final int? selectedImageIndex;
  final String? entreprise;
  final bool fromPub;
  final String? typeMoto;
  final String? typeMoteur;
  final String? puissance;
  final String? transmission;
  final String? demarrage;
  final String? refroidissement;
  final String? capaciteReservoir;
  final String? autonomie;
  final String? disponibilite;
  final bool? garantieConstructeur;
  final String? dureeGarantie;
  final String? kilometrage;
  final List<String> equipements;
  final String? devise;

  const MotoInfo({
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
    this.fournisseur,
    this.vendeur,
    required this.images,
    this.videos = const [],
    this.video,
    this.videoOptimized,
    this.selectedImageIndex,
    this.entreprise,
    this.fromPub = false,
    this.typeMoto,
    this.typeMoteur,
    this.puissance,
    this.transmission,
    this.demarrage,
    this.refroidissement,
    this.capaciteReservoir,
    this.autonomie,
    this.disponibilite,
    this.garantieConstructeur,
    this.dureeGarantie,
    this.kilometrage,
    this.equipements = const [],
    this.devise,
  });

  factory MotoInfo.fromArticleMap(Map<String, dynamic> m, {bool fromPub = false}) {
    final photos =
        (m['photos'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final equips = (m['equipements'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
    return MotoInfo(
      id: (m['_id'] ?? m['id'] ?? '').toString(),
      titre: m['titre']?.toString(),
      description: m['description']?.toString(),
      marque: m['marque']?.toString(),
      modele: m['modele']?.toString(),
      annee: m['annee']?.toString(),
      prix: m['prix']?.toString(),
      condition: m['condition']?.toString(),
      cylindre: m['cylindre']?.toString(),
      lieu: (m['localisation'] ?? m['lieu'])?.toString(),
      fournisseur: m['fournisseur'] is Map
          ? Map<String, dynamic>.from(m['fournisseur'] as Map)
          : null,
      vendeur: m['vendeur'] is Map
          ? Map<String, dynamic>.from(m['vendeur'] as Map)
          : null,
      images: photos,
      video: m['video']?.toString(),
      videoOptimized: m['videoOptimized']?.toString(),
      entreprise: m['entreprise']?.toString(),
      fromPub: fromPub,
      typeMoto: m['typeMoto']?.toString(),
      typeMoteur: m['typeMoteur']?.toString(),
      puissance: m['puissance']?.toString(),
      transmission: m['transmission']?.toString(),
      demarrage: m['demarrage']?.toString(),
      refroidissement: m['refroidissement']?.toString(),
      capaciteReservoir: m['capaciteReservoir']?.toString(),
      autonomie: m['autonomie']?.toString(),
      disponibilite: m['disponibilite']?.toString(),
      garantieConstructeur: m['garantieConstructeur'] == true,
      dureeGarantie: m['dureeGarantie']?.toString(),
      kilometrage: (m['kilometrage'] ?? m['distance'])?.toString(),
      equipements: equips,
      devise: m['devise']?.toString(),
    );
  }

  @override
  State<MotoInfo> createState() => _MotoInfoState();
}

class _MotoInfoState extends State<MotoInfo> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  late int _currentImageIndex; // Gère l'image actuelle affichée
  late PageController _pageController;
  late List<String> _videos; // Vidéos associées
  Set<String> _favoriteIds = <String>{};
  int get _imagesCount => widget.images.length;
  int get _videosCount => _videos.length;
  int get _totalMediaCount => _imagesCount + _videosCount;
  String? get _primaryVideo => _videos.isNotEmpty
      ? _videos.first
      : (widget.videoOptimized ?? widget.video);
  late ConfettiController _confettiController;
  String? _sellerPhone;

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

  String _yesNoValue(AppLocalizations l10n, bool? value) {
    if (value == null) return l10n.notProvided;
    return value ? l10n.yes : l10n.no;
  }

  bool _isSpecsExpanded = false;

  @override
  void initState() {
    super.initState();
    trackArticleView(widget.id);
    // Log toutes les valeurs reçues
    log('[MotoInfo] titre: ${widget.titre}');
    log('[MotoInfo] description: ${widget.description}');
    log('[MotoInfo] marque: ${widget.marque}');
    log('[MotoInfo] modele: ${widget.modele}');
    log('[MotoInfo] annee: ${widget.annee}');
    log('[MotoInfo] prix: ${widget.prix}');
    log('[MotoInfo] condition: ${widget.condition}');
    log('[MotoInfo] boiteVitesse: ${widget.boiteVitesse}');
    log('[MotoInfo] carburant: ${widget.carburant}');
    log('[MotoInfo] climatiseur: ${widget.climatiseur}');
    log('[MotoInfo] distance: ${widget.distance}');
    log('[MotoInfo] sieges: ${widget.sieges}');
    log('[MotoInfo] portes: ${widget.portes}');
    log('[MotoInfo] cylindre: ${widget.cylindre}');
    log('[MotoInfo] images: ${widget.images}');
    log('[MotoInfo] video: ${widget.video}');
    _videos = widget.videos.isNotEmpty
        ? widget.videos.where((v) => v.isNotEmpty).toList()
        : (widget.video != null && widget.video!.isNotEmpty
            ? [widget.video!]
            : <String>[]);
    log('[MotoInfo] videos: $_videos');
    log('[MotoInfo] selectedImageIndex: ${widget.selectedImageIndex}');
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
    _sellerPhone = WhatsappHelper.phoneFromArticleSupplier(
      fournisseur: widget.fournisseur,
      vendeur: widget.vendeur,
    );
    _loadArticleDetails();
  }

  String? _extractSellerPhone(Map<String, dynamic> data) =>
      WhatsappHelper.phoneFromArticle(data) ?? _sellerPhone;

  Future<void> _loadArticleDetails() async {
    try {
      final id = widget.id;
      if (id == null || id.isEmpty) return;
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final res = await http.get(
        Uri.parse('${getBaseUrl()}/public/articles/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _sellerPhone = _extractSellerPhone(data);
        });
      }
    } catch (_) {}
  }

  String _buyWhatsAppMessage(AppLocalizations l10n) {
    final label = WhatsappHelper.articleListingLabel(
      titre: widget.titre,
      marque: widget.marque,
      modele: widget.modele,
      fallback: l10n.defaultMotoTitle,
    );
    final id = (widget.id ?? '').trim();
    if (id.isNotEmpty) {
      return l10n.whatsappMotoInterestWithRef(label, id);
    }
    return l10n.whatsappMotoInterestNoRef(label);
  }

  Future<void> _openSellerWhatsApp({String? message}) async {
    await WhatsappHelper.openChat(
      context,
      phone: _sellerPhone,
      message: message,
      unavailableMessage: l10n.sellerPhoneUnavailable,
      cannotOpenMessage: l10n.cannotOpenWhatsApp,
    );
  }

  Future<void> _callSeller() async {
    final digits = WhatsappHelper.normalizeWaMeDigits(_sellerPhone);
    if (digits.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sellerPhoneUnavailable)),
      );
      return;
    }
    final uri = Uri.parse('tel:+$digits');
    try {
      if (await launchUrl(uri)) return;
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.cannotMakeCall)),
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
                      child: TranooNetworkImage(
                        url: widget.images[index],
                        fit: BoxFit.contain,
                        cloudinaryWidthPx: cloudinaryWidthPx(context),
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
    log('[MotoInfo][build] widget.images.length = ${widget.images.length}');
    log('[MotoInfo][build] _currentImageIndex = $_currentImageIndex');
    if (widget.images.isNotEmpty) {
      log('[MotoInfo][build] Première image = ${widget.images[0]}');
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
      '[MotoInfo][_buildImageSection] widget.images.length = ${widget.images.length}',
    );
    log(
      '[MotoInfo][_buildImageSection] _currentImageIndex = $_currentImageIndex',
    );
    if (widget.images.isNotEmpty && _currentImageIndex < widget.images.length) {
      log(
        '[MotoInfo][_buildImageSection] Image affichée = ${widget.images[_currentImageIndex]}',
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
                  onPageChanged: (i) {
                    setState(() => _currentImageIndex = i);
                    _precacheAdjacentImages(i);
                  },
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
                            child: TranooNetworkImage(
                              url: widget.images[index],
                              fit: BoxFit.cover,
                              cloudinaryWidthPx: cloudinaryWidthPx(context),
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
                        enablePreviewFrame: false,
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
                            'type': 'moto',
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
                      'type': 'moto',
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
                  await _openSellerWhatsApp();
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
                onTap: _callSeller,
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

  // Description de la moto
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
      _buildSpecCard('Type de moto', _specValue(l10n, widget.typeMoto), Icons.motorcycle),
      _buildSpecCard(l10n.cylinder, _specValue(l10n, widget.cylindre), Icons.speed),
      _buildSpecCard('Type moteur', _specValue(l10n, widget.typeMoteur), Icons.local_gas_station),
      _buildSpecCard('Puissance', _specValue(l10n, widget.puissance), Icons.bolt),
      _buildSpecCard('Transmission', _specValue(l10n, widget.transmission ?? widget.boiteVitesse), Icons.settings),
      _buildSpecCard('Démarrage', _specValue(l10n, widget.demarrage), Icons.power_settings_new),
    ];
    final bottomCards = <Widget>[
      _buildSpecCard('Refroidissement', _specValue(l10n, widget.refroidissement), Icons.ac_unit),
      _buildSpecCard('Réservoir', _specValue(l10n, widget.capaciteReservoir), Icons.local_drink),
      if ((widget.typeMoteur ?? '').toLowerCase() == 'électrique')
        _buildSpecCard('Autonomie', _specValue(l10n, widget.autonomie), Icons.battery_charging_full),
      _buildSpecCard('Disponibilité', _specValue(l10n, widget.disponibilite), Icons.inventory_2),
      _buildSpecCard(
        'Garantie',
        widget.garantieConstructeur == true
            ? _specValue(l10n, widget.dureeGarantie?.isNotEmpty == true ? widget.dureeGarantie : 'Oui')
            : l10n.no,
        Icons.verified,
      ),
      _buildSpecCard('Kilométrage', _specValue(l10n, widget.kilometrage ?? widget.distance), Icons.speed),
      if (widget.equipements.isNotEmpty)
        _buildSpecCard('Équipements', widget.equipements.join(', '), Icons.checklist),
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

  // Bouton acheteur : acheter via WhatsApp du vendeur
  Widget _buildActionButton(bool isAcheteurOuChauffeur, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser == null) {
            showAuthDialog(context, message: l10n.signInToBuyThisMoto);
            return;
          }
          await _openSellerWhatsApp(message: _buyWhatsAppMessage(l10n));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          l10n.buyThisMoto,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
