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
import 'package:tranoo/data/screens/movie.dart';

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
  final List<String> media;

  Pub({
    required this.id,
    required this.description,
    required this.typePub,
    required this.statut,
    required this.media,
  });

  factory Pub.fromJson(Map<String, dynamic> json) {
    return Pub(
      id: json['_id'] ?? '',
      description: json['description'] ?? '',
      typePub: json['typePub'] ?? '',
      statut: json['statut'] ?? '',
      media: (json['media'] as List?)?.map((e) => e.toString()).toList() ?? [],
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
  final UserService _userService = UserService();
  late int _marqueTabIndex;
  late int _modeleTabIndex;
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

  final _logger = Logger('MarquePage');

  @override
  void initState() {
    super.initState();

    // Initialisation des indices des onglets selon le rôle
    final isTransitaire = _userService.currentRole == UserRole.transitaire;
    _marqueTabIndex = isTransitaire ? 1 : 0;
    _modeleTabIndex = isTransitaire ? 2 : 1;
    _localisationTabIndex = isTransitaire ? 3 : 2;
    _budgetTabIndex = isTransitaire ? 4 : 3;

    _tabController = TabController(length: isTransitaire ? 5 : 4, vsync: this);

    _tabController.addListener(() {
      setState(() {});
    });

    _pageController = PageController(initialPage: 0);

    // Configuration du carrousel automatique
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (pubsALaUne.isEmpty) return;
        if (_currentPage < pubsALaUne.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (pubsALaUne.isNotEmpty && _pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });
    fetchArticlesPieces();
    fetchVoituresRecommandees();
    fetchPubs();
    fetchPubsSponsorisees();
  }

  Future<void> fetchArticlesPieces() async {
    setState(() {
      isLoadingPieces = true;
      errorPieces = null;
    });
    try {
      final role = _userService.currentRole;
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final userId = user?.uid;
      String url = getBaseUrl() + '/articles?type=piece&statut=en_ligne';
      if (role == UserRole.vendeur && userId != null) {
        url += '&vendeur=$userId';
      }
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final body = response.body;
        try {
          final List<dynamic> data = json.decode(body);
          if (!mounted) return;
          setState(() {
            articlesPieces = data.map((e) => Article.fromJson(e)).toList();
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

  Future<void> fetchVoituresRecommandees() async {
    setState(() {
      isLoadingVoitures = true;
      errorVoitures = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url = getBaseUrl() + '/articles?type=voiture&statut=en_ligne';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          voituresRecommandees =
              data.map((e) => ArticleVoiture.fromJson(e)).toList();
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
      String url = getBaseUrl() + '/publicites?typePub=À la une&statut=valide';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final pubs = data.map((e) => Pub.fromJson(e)).toList();
        if (!mounted) return;
        setState(() {
          pubsSponsorisees =
              pubs.where((p) => p.typePub == 'Sponsorisée').toList();
          pubsALaUne = pubs.where((p) => p.typePub == 'À la une').toList();
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

  Future<void> fetchPubsSponsorisees() async {
    setState(() {
      isLoadingPubs = true;
      errorPubs = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url =
          getBaseUrl() + '/publicites?typePub=Sponsorisée&statut=valide';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          pubsSponsorisees = data.map((e) => Pub.fromJson(e)).toList();
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

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTabButton(String title, int index, {bool isWide = false}) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = index;
        });
      },
      child: Container(
        width: isWide ? 85 : 65,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF007AFF) : const Color(0xFF000000),
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
    // Filtrer les voitures avec statut 'en_ligne'
    final userService = _userService;
    final isVendeur = userService.currentRole == UserRole.vendeur;
    final voituresEnLigne =
        voituresRecommandees
            .where((v) => (v.statut ?? 'en_ligne') == 'en_ligne')
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
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: voituresEnLigne.length > 8 ? 8 : voituresEnLigne.length,
      itemBuilder: (context, index) {
        final voiture = voituresEnLigne[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CarsInfo(
                      id: voiture.id?.toString(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        voiture.images.isNotEmpty
                            ? Image.network(
                              voiture.images.first,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 140,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  if (voiture.video != null && voiture.video!.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.red,
                            size: 18,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => Movie(videoUrl: voiture.video),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                voiture.marque + ' ' + voiture.modele,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(voiture.prix, style: const TextStyle(color: Colors.grey)),
              Row(
                children: [
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF188100),
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Vérifiée",
                    style: TextStyle(color: Color(0xFF188100)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPiecesGrid() {
    if (isLoadingPieces) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorPieces != null) {
      return Center(child: Text(errorPieces!));
    }
    final userService = _userService;
    final isVendeur = userService.currentRole == UserRole.vendeur;
    final piecesEnLigne =
        articlesPieces
            .where((p) => (p.statut ?? 'en_ligne') == 'en_ligne')
            .toList();
    // Filtrage recherche
    final filteredPieces =
        piecesEnLigne
            .where(
              (p) => p.title.toLowerCase().contains(
                _searchPieceText.toLowerCase(),
              ),
            )
            .toList();
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MastervacPage(
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
                      child:
                          piece.images.isNotEmpty
                              ? Image.network(
                                piece.images.first,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              )
                              : Container(
                                height: 40,
                                width: 40,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
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
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final voituresEnLigne =
        voituresRecommandees
            .where((v) => (v.statut ?? 'en_ligne') == 'en_ligne')
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
          voituresEnLigne.isEmpty
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
              : GridView.builder(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount:
                    voituresEnLigne.length > 8 ? 8 : voituresEnLigne.length,
                itemBuilder: (context, index) {
                  final voiture = voituresEnLigne[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CarsInfo(
                                id: voiture.id?.toString(),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  voiture.images.isNotEmpty
                                      ? Image.network(
                                        voiture.images.first,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        height: 140,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                            if (voiture.video != null &&
                                voiture.video!.isNotEmpty)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => Movie(
                                                videoUrl: voiture.video,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          voiture.marque + ' ' + voiture.modele,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          voiture.prix,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF188100),
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "Vérifiée",
                              style: TextStyle(color: Color(0xFF188100)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget buildPiecesSection() {
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final piecesEnLigne =
        articlesPieces
            .where((p) => (p.statut ?? 'en_ligne') == 'en_ligne')
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pièces détachées",
                style: TextStyle(
                  fontSize: 25,
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
                  style: TextStyle(fontSize: 16, color: Colors.black),
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
              : GridView.builder(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: piecesEnLigne.length > 8 ? 8 : piecesEnLigne.length,
                itemBuilder: (context, index) {
                  final piece = piecesEnLigne[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MastervacPage(
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
                          child:
                              piece.images.isNotEmpty
                                  ? Image.network(
                                    piece.images.first,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    height: 40,
                                    width: 40,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
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
      ],
    );
  }

  // SECTION SPONSORISÉE
  Widget buildPubsSponsoriseesSection() {
    if (isLoadingPubs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorPubs != null) {
      return Center(child: Text(errorPubs!));
    }
    if (pubsSponsorisees.isEmpty) {
      return const SizedBox.shrink();
    }
    // Affichage horizontal des pubs sponsorisées avec description en overlay
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.star, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              "Sponsorisé",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pubsSponsorisees.length,
            itemBuilder: (context, index) {
              final pub = pubsSponsorisees[index];
              return GestureDetector(
                onTap: () async {
                  if (pub.id.isEmpty) return;
                  // Afficher un indicateur de chargement
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
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
                        if (idToken != null) 'Authorization': 'Bearer $idToken',
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
                                builder:
                                    (context) => CarsInfo(
                                      titre: article['titre'] ?? '',
                                      description: article['description'] ?? '',
                                      marque: article['marque'] ?? '',
                                      modele: article['modele'] ?? '',
                                      annee: article['annee'] ?? '',
                                      prix: article['prix']?.toString() ?? '',
                                      condition: article['condition'] ?? '',
                                      boiteVitesse:
                                          article['boiteVitesse'] ?? '',
                                      carburant: article['carburant'] ?? '',
                                      climatiseur: article['climatiseur'] ?? '',
                                      distance: article['distance'] ?? '',
                                      sieges: article['sieges'] ?? '',
                                      portes: article['portes'] ?? '',
                                      cylindre: article['cylindre'] ?? '',
                                      lieu: article['lieu'] ?? '',
                                      images:
                                          (article['photos'] as List?)
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
                                builder:
                                    (context) => MastervacPage(
                                      isAcheteur: true,
                                      title: article['titre'] ?? '',
                                      year: article['annee'] ?? '',
                                      description: article['description'] ?? '',
                                      company: article['entreprise'] ?? '',
                                      location: article['localisation'] ?? '',
                                      price: article['prix']?.toString() ?? '',
                                      images:
                                          (article['photos'] as List?)
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
                          content: Text('Erreur lors du chargement de la pub.'),
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
                              child:
                                  pub.media.isNotEmpty
                                      ? Image.network(
                                        pub.media[0],
                                        width: 340,
                                        height: 170,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        height: 170,
                                        width: 340,
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 80,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pubsALaUne.length,
            itemBuilder: (context, index) {
              final pub = pubsALaUne[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          pub.media.isNotEmpty
                              ? Image.network(
                                pub.media[0],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                              : Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 120),
                              ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
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
                  ],
                ),
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
    final isTransitaire = _userService.currentRole == UserRole.transitaire;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche de Honda Pilot 7-Passenger',
                  hintStyle: TextStyle(
                    color: const Color(0xFF8C9199),
                    fontSize: screenWidth * (isPortrait ? 0.035 : 0.025),
                    letterSpacing: 0.1,
                    height: 1.8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEDEEEF),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF8C9199),
                    size: screenWidth * 0.06,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.03,
                  ),
                ),
                onChanged: (text) => _logger.info('Recherche: $text'),
              ),
            ),
            buildPubsALaUneCarousel(),
            // Section filtres/tabbar
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: const BoxDecoration(),
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                ),
                tabs: [
                  if (isTransitaire) _buildTabButton("Activités", 0),
                  _buildTabButton("Marque", _marqueTabIndex),
                  _buildTabButton("Modèles", _modeleTabIndex),
                  _buildTabButton(
                    "Localisation",
                    _localisationTabIndex,
                    isWide: true,
                  ),
                  _buildTabButton("Budget", _budgetTabIndex),
                ],
              ),
            ),
            if (_tabController.index == 0 && isTransitaire)
              _buildActivitesSection(),
            if (_tabController.index == _marqueTabIndex) _buildMarqueSection(),
            if (_tabController.index == _modeleTabIndex) _buildModeleSection(),
            if (_tabController.index == _localisationTabIndex)
              _buildLocalisationSection(),
            if (_tabController.index == _budgetTabIndex) _buildBudgetSection(),
            // Section sponsorisée (UN SEUL APPEL)
            buildPubsSponsoriseesSection(),
            buildVoituresRecommandeesSection(),
            buildPiecesSection(),
            // Add the new sections here
          ],
        ),
      ),
    );
  }

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
    List<Map<String, dynamic>> marques = [
      {
        "name": "Toyota",
        "image": "assets/images/Toyota.png",
        "logoW": 23.0,
        "logoH": 15.0,
        "textW": 45.0,
        "textH": 18.0,
      },
      {
        "name": "Nissan",
        "image": "assets/images/nissan.png",
        "logoW": 30.0,
        "logoH": 25.0,
        "textW": 45.0,
        "textH": 18.0,
      },
      {
        "name": "Ford",
        "image": "assets/images/ford.png",
        "logoW": 40.0,
        "logoH": 21.0,
        "textW": 33.0,
        "textH": 15.0,
      },
      {
        "name": "Hyundai",
        "image": "assets/images/hunydai.png",
        "logoW": 26.0,
        "logoH": 23.0,
        "textW": 54.0,
        "textH": 18.0,
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
              itemCount: marques.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: marques[index]["logoW"],
                        height: marques[index]["logoH"],
                        child: Image.asset(marques[index]["image"]!),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: marques[index]["textW"],
                        height: marques[index]["textH"],
                        child: Center(
                          child: Text(
                            marques[index]["name"]! ?? "No name",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF000000),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeleSection() {
    List<Map<String, dynamic>> modeles = [
      {"name": "Toyota Land cuiser", "logoW": 50.0, "logoH": 30.0},
      {"name": "Nissan Patrol", "logoW": 50.0, "logoH": 30.0},
      {"name": "Nissan Altima", "logoW": 50.0, "logoH": 30.0},
      {"name": "Toyota RAV-4", "logoW": 50.0, "logoH": 30.0},
      {"name": "Toyota Hilux", "logoW": 50.0, "logoH": 30.0},
      {"name": "Jeep Wrangler", "logoW": 50.0, "logoH": 30.0},
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
              itemCount: modeles.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        modeles[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF000000),
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
      ),
    );
  }

  Widget _buildLocalisationSection() {
    List<Map<String, dynamic>> modeles = [
      {
        "name": "Benin",
        "image": "assets/images/benin.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Mali",
        "image": "assets/images/mali.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Niger",
        "image": "assets/images/niger.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Burkina-Faso",
        "image": "assets/images/burkina.png",
        "logoW": 50.0,
        "logoH": 30.0,
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
              itemCount: modeles.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: modeles[index]["logoW"],
                        height: modeles[index]["logoH"],
                        child: Image.asset(modeles[index]["image"]),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        modeles[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF000000),
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
      ),
    );
  }

  Widget _buildBudgetSection() {
    List<Map<String, dynamic>> modeles = [
      {
        "name": "Moins de 5000000 f",
        "image": "assets/images/Vector.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Moins de 10000000 f",
        "image": "assets/images/Vector.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Moins de 1500000 f",
        "image": "assets/images/Vector.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Moins de 20000000 f",
        "image": "assets/images/Vector.png",
        "logoW": 50.0,
        "logoH": 30.0,
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
              itemCount: modeles.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: modeles[index]["logoW"],
                        height: modeles[index]["logoH"],
                        child: Image.asset(modeles[index]["image"]),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        modeles[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF000000),
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
      ),
    );
  }
}
