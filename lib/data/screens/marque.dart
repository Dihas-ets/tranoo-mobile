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

  // Favoris
  Set<String> _favoriteArticleIds = <String>{};

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
    _loadFavorites();
  }

  void _reloadAll() {
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
      final role = _userService.currentRole;
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final userId = user?.uid;
      String url =
          getBaseUrl() + '/articles?type=piece&statut=en_ligne&vendu=false';
      if (role == UserRole.vendeur && userId != null) {
        url += '&vendeur=$userId';
      }
      _logger.info('[DEBUG] URL pièces: $url');
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
          final allPieces = data.map((e) => Article.fromJson(e)).toList();
          final piecesFiltered =
              allPieces
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

  Future<void> _loadFavorites() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) return;
      final response = await http.get(
        Uri.parse(getBaseUrl() + '/users/me/favoris'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List favoris = data['favoris'] ?? [];
        setState(() {
          _favoriteArticleIds =
              favoris
                  .map(
                    (e) =>
                        (e is Map && e['_id'] != null)
                            ? e['_id'].toString()
                            : e.toString(),
                  )
                  .toSet();
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite(String articleId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) return;
      final isFav = _favoriteArticleIds.contains(articleId);
      final uri = Uri.parse(getBaseUrl() + '/users/me/favoris');
      final response =
          await (isFav
              ? http.delete(
                uri,
                headers: {
                  'Authorization': 'Bearer $idToken',
                  'Content-Type': 'application/json',
                },
                body: json.encode({'articleId': articleId}),
              )
              : http.post(
                uri,
                headers: {
                  'Authorization': 'Bearer $idToken',
                  'Content-Type': 'application/json',
                },
                body: json.encode({'articleId': articleId}),
              ));
      if (response.statusCode == 200) {
        setState(() {
          if (isFav) {
            _favoriteArticleIds.remove(articleId);
          } else {
            _favoriteArticleIds.add(articleId);
          }
        });
      }
    } catch (e) {
      _logger.info('toggle favorite error: $e');
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

  Future<Map<String, String?>> _fetchArticleMetaFromPub(String pubId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final pubRes = await http.get(
        Uri.parse(getBaseUrl() + '/publicites/$pubId'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );
      if (pubRes.statusCode == 200) {
        final pubData = jsonDecode(pubRes.body);
        final articleId = pubData['articleId']?.toString();
        if (articleId != null && articleId.isNotEmpty) {
          final artRes = await http.get(
            Uri.parse(getBaseUrl() + '/articles/$articleId'),
            headers: {
              'Content-Type': 'application/json',
              if (idToken != null) 'Authorization': 'Bearer $idToken',
            },
          );
          if (artRes.statusCode == 200) {
            final art = jsonDecode(artRes.body);
            final cond = (art['condition'] ?? art['pieceType'])?.toString();
            return {'articleId': articleId, 'condition': cond};
          }
          return {'articleId': articleId, 'condition': null};
        }
      }
    } catch (_) {}
    return {'articleId': null, 'condition': null};
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
          getBaseUrl() + '/articles?type=voiture&statut=en_ligne&vendu=false';
      _logger.info('[DEBUG] URL voitures: $url');
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
        final allVoitures =
            data.map((e) => ArticleVoiture.fromJson(e)).toList();
        final voituresFiltered =
            allVoitures
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
      String url = getBaseUrl() + '/publicites?statut=valide';
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
          pubsALaUne =
              pubs
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

  @override
  void dispose() {
    _carouselTimer?.cancel();
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
    // Filtrer les voitures avec statut 'en_ligne' et non vendues
    final userService = _userService;
    final isVendeur = userService.currentRole == UserRole.vendeur;
    final voituresEnLigne =
        voituresRecommandees
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
    final filtered =
        _applyFilters(voituresEnLigne).where((v) {
          if (_searchGlobalText.isEmpty) return true;
          final hay =
              (v.marque +
                      ' ' +
                      v.modele +
                      ' ' +
                      v.titre +
                      ' ' +
                      (v.entreprise ?? ''))
                  .toLowerCase();
          return hay.contains(_searchGlobalText.toLowerCase());
        }).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.52,
        ),
        itemCount: filtered.length > 8 ? 8 : filtered.length,
        itemBuilder: (context, index) {
          final voiture = filtered[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CarsInfo(
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
                          child:
                              voiture.images.isNotEmpty
                                  ? Image.network(
                                    voiture.images.first,
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
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
                        // Coeur (favoris)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _toggleFavorite(voiture.id.toString()),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                _favoriteArticleIds.contains(
                                      voiture.id.toString(),
                                    )
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 18,
                              ),
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
                              color:
                                  (voiture.condition?.toLowerCase() ==
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
                          SizedBox(
                            height: 80,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Ligne 1: Boite vitesse + Année
                                  if (voiture.boiteVitesse != null ||
                                      voiture.annee != null)
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
                                            voiture.annee ?? '',
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
    final userService = _userService;
    final isVendeur = userService.currentRole == UserRole.vendeur;
    final piecesEnLigne =
        articlesPieces
            .where(
              (p) =>
                  (p.statut ?? 'en_ligne') == 'en_ligne' &&
                  (p.statut ?? '') != 'vendu',
            )
            .toList();
    // Filtrage recherche
    final filteredPieces =
        piecesEnLigne.where((p) {
          final q1 = _searchPieceText.trim().toLowerCase();
          final q2 = _searchGlobalText.trim().toLowerCase();
          final hay =
              (p.title +
                      ' ' +
                      p.description +
                      ' ' +
                      p.company +
                      ' ' +
                      p.location)
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
                      child: Stack(
                        children: [
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
                                final isNew =
                                    rawCond == 'nouveau' ||
                                    rawCond == 'neuf' ||
                                    rawCond == 'new';
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isNew
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
                            child: GestureDetector(
                              onTap: () => _toggleFavorite(piece.id),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  _favoriteArticleIds.contains(piece.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                  size: 12,
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.68, // RÉDUIT pour moins d'espace
                  ),
                  itemCount:
                      _applyFilters(voituresEnLigne).length > 8
                          ? 8
                          : _applyFilters(voituresEnLigne).length,
                  itemBuilder: (context, index) {
                    final list = _applyFilters(voituresEnLigne);
                    final voiture = list[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CarsInfo(
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
                                    child:
                                        voiture.images.isNotEmpty
                                            ? Image.network(
                                              voiture.images.first,
                                              height: double.infinity,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
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
                                  // Coeur (favoris)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap:
                                          () => _toggleFavorite(
                                            voiture.id.toString(),
                                          ),
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          _favoriteArticleIds.contains(
                                                voiture.id.toString(),
                                              )
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                          size: 18,
                                        ),
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
                                        color:
                                            (voiture.condition?.toLowerCase() ==
                                                        'nouveau' ||
                                                    voiture.condition
                                                            ?.toLowerCase() ==
                                                        'neuf')
                                                ? Colors.purple
                                                : const Color(0xFFF8BF13),
                                        borderRadius: BorderRadius.circular(50),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                voiture.modele,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[500],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceAround, // RÉDUIT l'espacement
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
                                                  voiture.annee ?? '',
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
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    final piecesEnLigne =
        articlesPieces
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
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 sur une ligne
                    crossAxisSpacing: 4, // RÉDUIT de 8 à 4
                    mainAxisSpacing: 4, // RÉDUIT de 8 à 4
                    childAspectRatio: 0.65, // LÉGÈREMENT RÉDUIT
                  ),
                  itemCount:
                      piecesEnLigne.length > 6 ? 6 : piecesEnLigne.length,
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
                        children: [
                          // CARD IMAGE AVEC BADGE
                          Container(
                            height: 70, // LÉGÈREMENT RÉDUIT
                            width: 70, // LARGEUR FIXE pour uniformité
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8), // RÉDUIT
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3, // RÉDUIT
                                  offset: const Offset(0, 1), // RÉDUIT
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      piece.images.isNotEmpty
                                          ? Image.network(
                                            piece.images.first,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 25,
                                            ),
                                          ),
                                ),
                                // Badge condition (nouveau/occasion)
                                Positioned(
                                  top: 2, // RAPPROCHÉ du bord
                                  left: 2, // RAPPROCHÉ du bord
                                  child: Builder(
                                    builder: (context) {
                                      final rawCond =
                                          (piece.condition ??
                                                  piece.pieceType ??
                                                  '')
                                              .toString()
                                              .toLowerCase();
                                      final isNew =
                                          rawCond == 'nouveau' ||
                                          rawCond == 'neuf' ||
                                          rawCond == 'new' ||
                                          piece.pieceType?.toLowerCase() ==
                                              'nouveau';
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4, // RÉDUIT
                                          vertical: 1, // RÉDUIT
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isNew
                                                  ? Colors.purple
                                                  : const Color(0xFFF8BF13),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ), // RÉDUIT
                                        ),
                                        child: Text(
                                          isNew
                                              ? 'Nouv.'
                                              : 'Occas.', // TEXTE RACCOURCI
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 7, // RÉDUIT
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4), // RÉDUIT
                          // NOM EN DESSOUS
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                            ), // RÉDUIT
                            child: Text(
                              piece.title,
                              style: const TextStyle(
                                fontSize: 9, // LÉGÈREMENT RÉDUIT
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                                  builder:
                                      (context) => CarsInfo(
                                        titre: article['titre'] ?? '',
                                        description:
                                            article['description'] ?? '',
                                        marque: article['marque'] ?? '',
                                        modele: article['modele'] ?? '',
                                        annee: article['annee'] ?? '',
                                        prix: article['prix']?.toString() ?? '',
                                        condition: article['condition'] ?? '',
                                        boiteVitesse:
                                            article['boiteVitesse'] ?? '',
                                        carburant: article['carburant'] ?? '',
                                        climatiseur:
                                            article['climatiseur'] ?? '',
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
                                        description:
                                            article['description'] ?? '',
                                        company: article['entreprise'] ?? '',
                                        location: article['localisation'] ?? '',
                                        price:
                                            article['prix']?.toString() ?? '',
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
                                  child:
                                      pub.media.isNotEmpty
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
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
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
                                height: 260,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 260,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                    ),
                                  );
                                },
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
            // Logo supprimé (demandé par le client)
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TextField(
                controller: _searchGlobalController,
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
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.02,
                      right: screenWidth * 0.01,
                    ),
                    child: Icon(
                      Icons.search,
                      color: const Color(0xFF8C9199),
                      size: screenWidth * 0.06,
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: screenWidth * 0.1,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF8C9199)),
                    onPressed: _reloadAll,
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
                onChanged: (text) => setState(() {}),
              ),
            ),
            buildPubsALaUneCarousel(),
            // Section filtres/tabbar (centrée, scrollable)
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Center(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  // Centrage visuel même avec 5+ onglets
                  tabAlignment: TabAlignment.center,
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
            ),
            if (_tabController.index == 0 && isTransitaire)
              _buildActivitesSection(),
            if (_tabController.index == _marqueTabIndex) _buildMarqueSection(),
            if (_tabController.index == _modeleTabIndex) _buildModeleSection(),
            if (_tabController.index == _localisationTabIndex)
              _buildLocalisationSection(),
            if (_tabController.index == _budgetTabIndex) _buildBudgetSection(),
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
      {
        "name": "Côte d'Ivoire",
        "image": "assets/images/ci.webp",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Sénégal",
        "image": "assets/images/senegal.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Togo",
        "image": "assets/images/togo.webp",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Ghana",
        "image": "assets/images/ghana.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Nigéria",
        "image": "assets/images/nigeria.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Maroc",
        "image": "assets/images/maroc.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
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
            final item = modeles[index];
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

  Widget _buildBudgetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A66FF),
            foregroundColor: Colors.white,
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
    final prices =
        voituresRecommandees
            .map(
              (v) => double.tryParse(v.prix.replaceAll(RegExp(r'[^0-9.]'), '')),
            )
            .whereType<double>()
            .toList()
          ..sort();
    final double minPrice = prices.isNotEmpty ? prices.first : 0;
    final double maxPrice = prices.isNotEmpty ? prices.last : 200000;
    double currentMin = minPrice;
    double currentMax = maxPrice;
    final minCtl = TextEditingController(text: currentMin.toStringAsFixed(0));
    final maxCtl = TextEditingController(text: currentMax.toStringAsFixed(0));

    int countInRange(double a, double b) {
      return voituresRecommandees.where((v) {
        final p = double.tryParse(v.prix.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (p == null) return false;
        return p >= a && p <= b && (v.statut ?? 'en_ligne') == 'en_ligne';
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
            final available = countInRange(currentMin, currentMax);
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
                    'Price (USD)',
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
                          child: const Text('Reset'),
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
                            backgroundColor: const Color(0xFF0A66FF),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Show $available cars'),
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
