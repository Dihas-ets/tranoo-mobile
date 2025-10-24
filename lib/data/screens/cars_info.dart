import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'movie.dart';
import 'payement.dart'; // Importer la page pour le paiement
import 'package:tranoo/services/user_service.dart'; // Importer UserService pour gérer les rôles
import 'package:tranoo/utils/role_redirect.dart'; // Importer RoleRedirect pour la redirection basée sur le rôle
import 'package:tranoo/data/screens/succes_vente.dart'; // Importer SuccesVenteScreen
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:confetti/confetti.dart';
import 'une.dart'; // Import pour la page de demande de pub
import 'dart:developer';
import 'verification_payment.dart'; // Import pour la page de vérification de paiement

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
  final String? video;
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
    this.video,
    this.selectedImageIndex,
    this.entreprise,
    this.fromPub = false,
  });

  @override
  State<CarsInfo> createState() => _CarsinfoState();
}

class _CarsinfoState extends State<CarsInfo> {
  late int _currentImageIndex; // Gère l'image actuelle affichée
  late PageController _pageController;
  Set<String> _favoriteIds = <String>{};
  bool isNew = false;
  bool is2023 = false;
  String? _selectedCountry;
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
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
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
    log('[CarsInfo] selectedImageIndex: ${widget.selectedImageIndex}');
    // Correction RangeError : si la liste est vide, index = 0
    if (widget.images.isEmpty) {
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
    _pageController = PageController(initialPage: _currentImageIndex);
    _loadArticleStatut();
  }

  Future<void> _loadArticleStatut() async {
    try {
      final id = widget.id;
      if (id == null || id.isEmpty) return;
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final res = await http.get(
        Uri.parse('${UserService().dio.options.baseUrl}/articles/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final statut = (data['statut'] ?? '').toString().toLowerCase();
        if (!mounted) return;
        setState(() {
          _isOnline = (statut == 'en_ligne');
        });
      }
    } catch (_) {}
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
                        errorBuilder:
                            (c, e, s) => const Icon(
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

  @override
  Widget build(BuildContext context) {
    final userService = UserService(); // Instance du service utilisateur
    final isAcheteurOuChauffeur =
        userService.currentRole == UserRole.acheteur ||
        userService.currentRole == UserRole.chauffeur;

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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildImageSection(screenWidth, screenHeight),
          _buildContentSection(screenWidth, isAcheteurOuChauffeur),
        ],
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
  Widget _buildImageSection(double screenWidth, double screenHeight) {
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
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.isNotEmpty ? widget.images.length : 1,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, index) {
              final hasImage =
                  widget.images.isNotEmpty &&
                  index < widget.images.length &&
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
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('Image non disponible'),
                            ),
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Badge condition (gauche)
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  ((widget.condition ?? '').toLowerCase() == 'nouveau' ||
                          (widget.condition ?? '').toLowerCase() == 'neuf')
                      ? Colors.purple
                      : const Color(0xFFF8BF13),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ((widget.condition ?? '').toLowerCase() == 'nouveau' ||
                      (widget.condition ?? '').toLowerCase() == 'neuf')
                  ? 'Nouveau'
                  : 'Occasion',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Favori (droite)
        Positioned(
          right: 16,
          top: 16,
          child: GestureDetector(
            onTap: () => _toggleFavorite(widget.id ?? ''),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(
                _favoriteIds.contains((widget.id ?? ''))
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
            ),
          ),
        ),
        // Icône play vidéo (juste en dessous du favori)
        Positioned(
          right: 16,
          top: 16 + 44,
          child: GestureDetector(
            onTap: () {
              if (widget.video != null && widget.video!.isNotEmpty) {
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
                  'video': widget.video,
                  'entreprise': widget.entreprise,
                  'type': 'voiture',
                };
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            Movie(videoUrl: widget.video, article: article),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Aucune vidéo disponible')),
                );
              }
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor:
                  widget.video != null && widget.video!.isNotEmpty
                      ? Colors.white
                      : Colors.grey[300],
              child: Icon(
                Icons.play_circle_fill,
                color:
                    widget.video != null && widget.video!.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                size: 24,
              ),
            ),
          ),
        ),
        // Dots indicator
        if (widget.images.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.images.length,
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
      final response =
          await (isFav
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
  Widget _buildContentSection(double screenWidth, bool isAcheteur) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04), // Espacement ajusté
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(screenWidth), // En-tête avec le modèle et le prix
          const SizedBox(height: 16),
          _buildDescription(screenWidth), // Description de la voiture
          const SizedBox(height: 24),
          _buildSpecifications(screenWidth), // Liste des spécifications
          const SizedBox(height: 24),
          // Affichage readonly des checkboxes pour la condition
          Row(
            children: [
              Checkbox(
                value: widget.condition == "Nouveau",
                onChanged: null,
                activeColor: Colors.black,
              ),
              const Text('Nouveau'),
              const SizedBox(width: 16),
              Checkbox(
                value: widget.condition == "Occasion",
                onChanged: null,
                activeColor: Colors.black,
              ),
              const Text('Occasion'),
            ],
          ),
          const SizedBox(height: 24),
          _buildCheckboxes(
            screenWidth,
            isAcheteur,
          ), // Cases à cocher (si applicable)
          const SizedBox(height: 24),
          _buildActionButton(isAcheteur), // Bouton d'action dynamique
        ],
      ),
    );
  }

  // En-tête avec le nom de la voiture et le prix
  Widget _buildHeader(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (widget.titre != null && widget.titre!.isNotEmpty)
              ? widget.titre!
              : 'Non renseigné',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        //Nom de l'entreprise
        Text(
          (widget.entreprise != null && widget.entreprise!.isNotEmpty)
              ? widget.entreprise!
              : 'Entreprise non renseignée',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 8),
        Text(
          (widget.prix != null && widget.prix!.isNotEmpty)
              ? widget.prix!
              : 'Non renseigné',
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
  Widget _buildDescription(double screenWidth) {
    return Text(
      widget.description ??
          'La Tesla Model 3 est une berline électrique de taille moyenne, reconnue pour ses performances impressionnantes, son accélération et son autonomie.',
      style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
    );
  }

  // Spécifications de la voiture sous forme de grille
  Widget _buildSpecifications(double screenWidth) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSpecCard(
          'Cylindre',
          (widget.cylindre != null && widget.cylindre!.isNotEmpty)
              ? widget.cylindre!
              : 'Non renseigné',
          Icons.settings,
        ),
        _buildSpecCard(
          'Carburant',
          (widget.carburant != null && widget.carburant!.isNotEmpty)
              ? widget.carburant!
              : 'Non renseigné',
          Icons.local_gas_station,
        ),
        _buildSpecCard(
          'Climatiseur',
          (widget.climatiseur != null && widget.climatiseur!.isNotEmpty)
              ? widget.climatiseur!
              : 'Non renseigné',
          Icons.ac_unit,
        ),
        _buildSpecCard(
          'Distance',
          (widget.distance != null && widget.distance!.isNotEmpty)
              ? widget.distance!
              : 'Non renseigné',
          Icons.speed,
        ),
        _buildSpecCard(
          'Sièges',
          (widget.sieges != null && widget.sieges!.isNotEmpty)
              ? widget.sieges!
              : 'Non renseigné',
          Icons.event_seat,
        ),
        _buildSpecCard(
          'Portes',
          (widget.portes != null && widget.portes!.isNotEmpty)
              ? widget.portes!
              : 'Non renseigné',
          Icons.door_front_door,
        ),
        _buildSpecCard(
          'Boîte à vitesse',
          (widget.boiteVitesse != null && widget.boiteVitesse!.isNotEmpty)
              ? widget.boiteVitesse!
              : 'Non renseigné',
          Icons.settings,
        ),
        _buildSpecCardWithColor(
          'Couleur',
          (widget.couleur != null && widget.couleur!.isNotEmpty)
              ? widget.couleur!
              : 'Non renseigné',
          Icons.palette,
          widget.couleur,
        ),
        _buildSpecCard(
          'Dédouanement',
          widget.dedouanement != null
              ? (widget.dedouanement! ? 'Oui' : 'Non')
              : 'Non renseigné',
          Icons.check_circle,
        ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Carte spéciale pour la couleur avec carré de couleur
  Widget _buildSpecCardWithColor(
    String title,
    String value,
    IconData icon,
    String? couleur,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              if (couleur != null && _couleurs.containsKey(couleur))
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: _couleurs[couleur],
                    border: Border.all(
                      color:
                          _couleurs[couleur] == Colors.white
                              ? Colors.grey
                              : Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cases à cocher et champs de livraison (ramenés ici)
  bool _isEnConsommationChecked = false;
  bool _isEnTransitChecked = false;
  final TextEditingController _detailsController = TextEditingController();

  Widget _buildCheckboxes(double screenWidth, bool isAcheteurOuChauffeur) {
    if (!isAcheteurOuChauffeur) return const SizedBox.shrink();
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
            const Text('En Consommation'),
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
            const Text('En Transit'),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Lieu', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              hint: const Text(
                'Choisissez un pays',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              isExpanded: true,
              items:
                  africanCountries
                      .map(
                        (c) =>
                            DropdownMenuItem<String>(value: c, child: Text(c)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedCountry = value),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Détails supplémentaires',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _detailsController,
          decoration: InputDecoration(
            hintText: 'Entrez vos détails concernant la destination ici...',
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

  // Widget générique pour une case à cocher
  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          checkColor: Colors.white,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Bouton d'action dynamique
  Widget _buildActionButton(bool isAcheteurOuChauffeur) {
    final userService = UserService();
    final isVendeur = userService.currentRole == UserRole.vendeur;

    if (widget.fromPub == true) {
      // Toujours afficher uniquement le bouton Acheter
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (!_isEnConsommationChecked && !_isEnTransitChecked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Veuillez choisir un mode de livraison (En Consommation ou En Transit).',
                  ),
                ),
              );
              return;
            }
            if (_selectedCountry == null || _selectedCountry!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez sélectionner un lieu.')),
              );
              return;
            }
            // Créer l'objet article à partir des propriétés du widget
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
              'video': widget.video,
              'entreprise': widget.entreprise,
              'type': 'voiture',
              // Pré-sélections pour payement
              'modeLivraison': _isEnTransitChecked ? 'transit' : 'consommation',
              'paysDestination': _selectedCountry,
              'detailsSupplementaires': _detailsController.text.trim(),
            };
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
                      const Text(
                        'Contrôle en cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Les vérifications seront effectuées et vous seront envoyées sous ',
                            ),
                            TextSpan(
                              text: '10 jours',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFA000),
                              ),
                            ),
                            TextSpan(
                              text: '. Pour démarrer, veuillez payer les ',
                            ),
                            TextSpan(
                              text: 'frais de vérification',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A86B),
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '20.000 FCFA',
                        style: TextStyle(
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
                                builder:
                                    (context) =>
                                        const VerificationPaymentScreen(),
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
                          child: const Text('Payer les frais de vérification'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Acheter cette voiture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    if (!isVendeur) {
      // Pour les acheteurs/chauffeurs, un seul bouton
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (!_isEnConsommationChecked && !_isEnTransitChecked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Veuillez choisir un mode de livraison (En Consommation ou En Transit).',
                  ),
                ),
              );
              return;
            }
            if (_selectedCountry == null || _selectedCountry!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez sélectionner un lieu.')),
              );
              return;
            }

            // Créer l'objet article à partir des propriétés du widget
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
              'video': widget.video,
              'entreprise': widget.entreprise,
              'type': 'voiture',
              // Pré-sélections pour payement
              'modeLivraison': _isEnTransitChecked ? 'transit' : 'consommation',
              'paysDestination': _selectedCountry,
              'detailsSupplementaires': _detailsController.text.trim(),
            };

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
                      const Text(
                        'Contrôle en cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Les vérifications seront effectuées et vous seront envoyées sous ',
                            ),
                            TextSpan(
                              text: '10 jours',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFA000),
                              ),
                            ),
                            TextSpan(
                              text: '. Pour démarrer, veuillez payer les ',
                            ),
                            TextSpan(
                              text: 'frais de vérification',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A86B),
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '20.000 FCFA',
                        style: TextStyle(
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
                                builder:
                                    (context) =>
                                        const VerificationPaymentScreen(),
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
                          child: const Text('Payer les frais de vérification'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Acheter cette voiture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    } else {
      // Pour les vendeurs, deux boutons
      return Column(
        children: [
          // Bouton principal "Vendre ma voiture"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isOnline
                      ? null
                      : () async {
                        // Vendeur : enregistre l'article dans la BDD puis redirige vers la page de succès
                        final articleData = {
                          'type': 'voiture',
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
                          'video': widget.video,
                          'entreprise': widget.entreprise,
                        };
                        log('[DEBUG] Données envoyées à l\'API :');
                        log(articleData.toString());
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          final token = await user?.getIdToken();
                          final response = await http.post(
                            Uri.parse(
                              '${UserService().dio.options.baseUrl}/articles/',
                            ),
                            headers: {
                              'Content-Type': 'application/json',
                              if (token != null)
                                'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode(articleData),
                          );
                          log(
                            '[DEBUG] Status code réponse API : ${response.statusCode}',
                          );
                          log('[DEBUG] Body réponse API : ${response.body}');
                          if (response.statusCode == 201 ||
                              response.statusCode == 200) {
                            _confettiController.play();
                            await Future.delayed(const Duration(seconds: 2));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SuccesVenteScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erreur lors de l\'enregistrement en BDD',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          log('[DEBUG] Exception lors de l\'appel API : $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur réseau ou serveur')),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOnline ? Colors.grey[300] : Colors.amber,
                foregroundColor: _isOnline ? Colors.grey[600] : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Vendre ma voiture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton "Faire une pub" pour les vendeurs
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                log('[DEBUG] Bouton Faire une pub cliqué');
                // Ouvrir la page de demande de pub avec les infos de l'article
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Une(
                          articleId:
                              widget.id, // Utiliser l'ID réel de l'article
                          articleType: 'voiture',
                          isStandalone: false,
                          articleTitle: widget.titre,
                          articleYear: widget.annee,
                          articleLocation: widget.lieu,
                          articlePrice: widget.prix,
                          articleDescription: widget.description,
                          articleCompany: widget.entreprise,
                          articleModel: widget.modele,
                          articleFuelType: widget.carburant,
                          articlePieceType: widget.condition,
                          articleImages: widget.images,
                          articleVideo: widget.video,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Faire une pub pour cette voiture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 8,
            gravity: 0.3,
          ),
        ],
      );
    }
  }
}
