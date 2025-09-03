import 'package:flutter/material.dart';
// import 'package:tranoo/data/screens/paymentscreen.dart';
import 'movie.dart'; // Importer la page pour les vidéos
import 'payement.dart'; // Importer la page pour le paiement
import 'package:tranoo/services/user_service.dart'; // Importer UserService pour gérer les rôles
import 'package:tranoo/utils/role_redirect.dart'; // Importer RoleRedirect pour la redirection basée sur le rôle
import 'package:tranoo/data/screens/succes6.dart'; // Importer SuccesScreen6
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
  }

  @override
  void dispose() {
    _confettiController.dispose();
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
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: () {
            // Action de partage ici
          },
        ),
      ],
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
          height: screenHeight * 0.4, // Hauteur ajustée pour la responsivité
          width: double.infinity,
          child:
              (widget.images.isNotEmpty &&
                      _currentImageIndex < widget.images.length &&
                      widget.images[_currentImageIndex].isNotEmpty)
                  ? Image.network(
                    widget.images[_currentImageIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Image non disponible'),
                        ),
                      );
                    },
                  )
                  : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 80),
                    ),
                  ),
        ),
        // Bouton pour accéder à la page des vidéos (seulement si vidéo présente)
        if (widget.video != null && widget.video!.isNotEmpty)
          Positioned(
            right: 16,
            top: 16,
            child: IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.red,
                size: 40,
              ),
              onPressed: () {
                // Créer l'objet article pour la page vidéo
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
              },
            ),
          ),
        // Liste des miniatures pour changer l'image affichée
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: screenHeight * 0.15, // Hauteur ajustée pour la responsivité
            color: Colors.black.withAlpha(50),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = index; // Change l'image affichée
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    width:
                        screenWidth *
                        0.3, // Largeur ajustée pour la responsivité
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _currentImageIndex == index
                                ? Colors.amber
                                : Colors
                                    .transparent, // Image sélectionnée mise en évidence
                        width: 2,
                      ),
                    ),
                    child:
                        (widget.images.isNotEmpty &&
                                widget.images[index].isNotEmpty)
                            ? Image.network(
                              widget.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            )
                            : Image.asset(
                              'assets/images/image_not_found.png',
                              fit: BoxFit.cover,
                            ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
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
      ],
    );
  }

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
              onPressed: () async {
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
                    Uri.parse('${getBaseUrl()}/articles/'),
                    headers: {
                      'Content-Type': 'application/json',
                      if (token != null) 'Authorization': 'Bearer $token',
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
                      MaterialPageRoute(builder: (context) => SuccesScreen6()),
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
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Vendre ma voiture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
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
                              null, // Pas d'articleId car c'est une nouvelle voiture
                          articleType: 'voiture',
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
