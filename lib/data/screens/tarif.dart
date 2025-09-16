import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274

class Tarif extends StatefulWidget {
  const Tarif({super.key});

  @override
  State<Tarif> createState() => _TarifState();
}

class _TarifState extends State<Tarif> {
<<<<<<< HEAD
  // Liste des annonces de voitures
  final List<Map<String, dynamic>> carAds = [
=======
  // Données dynamiques
  List<Map<String, dynamic>> carAds = [
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
    {
      'title': 'Toyota Corolla',
      'description': '2018, 50,000 km, Blanc',
      'company': 'Tranoo',
      'price': '18,000,000 f',
      'specs': {
        'Cylindre': '4',
        'Boîte À Vitesses': 'Automate',
        'Carburant': 'Essence',
        'Climatiseur': 'Oui',
        'Distance': '500 km',
        'Sièges': '5',
        'Portes': '4',
      },
      'images': ['assets/images/Audi.png', 'assets/images/car.png'],
      'proposed': false,
      'proposedAmount': null,
    },
    {
      'title': 'Honda Civic',
      'description': '2020, 30,000 km, Noir',
      'company': 'Tranoo',
      'price': '20,000,000 f',
      'specs': {
        'Cylindre': '4',
        'Boîte À Vitesses': 'Manuelle',
        'Carburant': 'Diesel',
        'Climatiseur': 'Oui',
        'Distance': '600 km',
        'Sièges': '5',
        'Portes': '4',
      },
      'images': ['assets/images/care.png', 'assets/images/groupe2.png'],
      'proposed': true,
      'proposedAmount': '19,500,000',
    },
    {
      'title': 'Ford Focus',
      'description': '2019, 40,000 km, Bleu',
      'company': 'Tranoo',
      'price': '22,000,000 f',
      'specs': {
        'Cylindre': '4',
        'Boîte À Vitesses': 'Automate',
        'Carburant': 'Essence',
        'Climatiseur': 'Oui',
        'Distance': '550 km',
        'Sièges': '5',
        'Portes': '4',
      },
      'images': ['assets/images/groupe3.png', 'assets/images/groupe2.png'],
      'proposed': false,
      'proposedAmount': null,
    },
  ];

<<<<<<< HEAD
  // Filtre actif : "Souscrire" ou "Soumis"
  String activeFilter = 'Souscrire';

  // Met à jour l'état d'une annonce après une proposition de tarif
  void updateProposalStatus(int index, String amount) {
    setState(() {
      carAds[index]['proposed'] = true;
      carAds[index]['proposedAmount'] = amount;
    });
=======
  // Ajout pour les nouveaux filtres
  int _selectedFilter = 0; // 0: Soumis, 1: Soumettre, 2: Validés, 3: Archivés
  final List<String> _filters = ['Soumis', 'Soumettre', 'Validés', 'Archivés'];
  List<Map<String, dynamic>> archives = [];
  List<Map<String, dynamic>> valides = [];
  bool loading = false;
  String? errorMsg;

  // Filtre actif : "Souscrire" ou "Soumis"
  String activeFilter = 'Souscrire';

  // Met à jour l'état d'une annonce après une proposition de tarif (et envoie au backend)
  Future<void> updateProposalStatus(int index, String amount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final idToken = await user.getIdToken();
      final String baseUrl = getBaseUrl();
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );
      final articleId = carAds[index]['id'];
      if (articleId != null) {
        await dio.post(
          '/transit/upsert',
          data: {
            'articleId': articleId,
            'montant': double.tryParse(amount) ?? amount,
          },
        );
      }
      setState(() {
        carAds[index]['proposed'] = true;
        carAds[index]['proposedAmount'] = amount;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la soumission du tarif.'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadForTab(0);
  }

  Future<void> _loadForTab(int tabIndex) async {
    setState(() {
      loading = true;
      errorMsg = null;
    });
    try {
      if (tabIndex == 0) {
        carAds = await _fetchSoumis();
      } else if (tabIndex == 1) {
        carAds = await _fetchSoumettre();
      } else if (tabIndex == 2) {
        valides = await _fetchValides();
      } else {
        // Archivés laissé local pour le moment
      }
    } catch (e) {
      errorMsg = 'Impossible de charger les données';
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSoumis() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final idToken = await user.getIdToken();
    final String baseUrl = getBaseUrl();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );
    final resp = await dio.get('/transit/soumis');
    return _mapArticlesToCards(resp.data, proposed: false);
  }

  Future<List<Map<String, dynamic>>> _fetchSoumettre() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final idToken = await user.getIdToken();
    final String baseUrl = getBaseUrl();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );
    final resp = await dio.get('/transit/soumettre');
    return _mapArticlesToCards(resp.data, proposed: true);
  }

  Future<List<Map<String, dynamic>>> _fetchValides() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final idToken = await user.getIdToken();
    final String baseUrl = getBaseUrl();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );
    final resp = await dio.get('/transit/valides');
    return _mapArticlesToCards(resp.data, proposed: true);
  }

  List<Map<String, dynamic>> _mapArticlesToCards(
    dynamic data, {
    required bool proposed,
  }) {
    if (data is! List) return [];
    return data.map<Map<String, dynamic>>((a) {
      final photos =
          (a['photos'] is List && a['photos'].isNotEmpty)
              ? List<String>.from(
                (a['photos'] as List).map((p) => p.toString()),
              )
              : <String>[];
      final description = _buildDescriptionFromArticle(a);
      final type = (a['type'] ?? '').toString();
      final Map<String, dynamic> specs =
          type == 'piece'
              ? <String, dynamic>{
                'Catégorie': a['categorie'] ?? '',
                'Type moteur': a['typeMoteur'] ?? '',
                'Lieu': a['lieu'] ?? '',
                'Condition': a['condition'] ?? '',
              }
              : <String, dynamic>{
                'Cylindre': a['cylindre'] ?? '',
                'Boîte À Vitesses': a['boiteVitesse'] ?? '',
                'Carburant': a['carburant'] ?? '',
                'Climatiseur': a['climatiseur'] ?? '',
                'Distance': a['distance'] ?? '',
                'Sièges': a['sieges'] ?? '',
                'Portes': a['portes'] ?? '',
              };
      return {
        'id': a['_id'],
        'title': a['titre'] ?? '',
        'description': description,
        'company':
            a['entreprise'] ??
            (a['vendeur'] != null ? (a['vendeur']['nom'] ?? '') : ''),
        'price': a['prix'] != null ? '${a['prix']} f' : '',
        'specs': specs,
        'type': type,
        'images': photos,
        'proposed': proposed,
        'proposedAmount': proposed ? (a['montant'] ?? null) : null,
      };
    }).toList();
  }

  String _buildDescriptionFromArticle(dynamic a) {
    final parts = <String>[];
    if (a['annee'] != null) parts.add('${a['annee']}');
    if (a['marque'] != null) parts.add('${a['marque']}');
    if (a['modele'] != null) parts.add('${a['modele']}');
    if (a['lieu'] != null) parts.add('${a['lieu']}');
    return parts.where((e) => e.toString().trim().isNotEmpty).join(', ');
  }

  // Helpers d'image pour la liste
  Widget _buildImageThumb(
    Map<String, dynamic> item, {
    required double height,
    required double width,
  }) {
    final List images = item['images'] ?? [];
    if (images.isNotEmpty) {
      final first = images.first.toString();
      final isNetwork =
          first.startsWith('http://') || first.startsWith('https://');
      if (isNetwork) {
        return Image.network(
          first,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _imageFallback(height, width),
        );
      } else {
        return Image.asset(
          first,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _imageFallback(height, width),
        );
      }
    }
    return _imageFallback(height, width);
  }

  Widget _imageFallback(double h, double w) {
    return Container(
      height: h,
      width: w,
      color: Colors.grey[300],
      child: const Icon(Icons.directions_car, color: Colors.grey),
    );
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final filteredAds =
        activeFilter == 'Souscrire'
            ? carAds.where((ad) => !ad['proposed']).toList()
            : carAds.where((ad) => ad['proposed']).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouton "Souscrire" avec style amélioré
            TextButton(
              onPressed: () => setState(() => activeFilter = 'Souscrire'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                'Souscrire',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      activeFilter == 'Souscrire'
                          ? Colors.white
                          : Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Bouton "Soumis" avec style amélioré
            TextButton(
              onPressed: () => setState(() => activeFilter = 'Soumis'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                'Soumis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      activeFilter == 'Soumis' ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment:
                activeFilter == 'Souscrire'
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 3.0,
              color: Colors.black, // Soulignement noir animé
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredAds.length,
        itemBuilder: (context, index) {
          final car = filteredAds[index];
          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CarDetailsPage(
                          car: car,
                          onProposalSubmitted:
                              (amount) => updateProposalStatus(
                                carAds.indexOf(car),
                                amount,
                              ),
                        ),
                  ),
                ),
            child: _buildCarAdCard(
              car,
            ), // Utilise le même effet hover que Transit
          );
        },
=======
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tarif'),
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _filters.length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: ChoiceChip(
                    label: Text(
                      _filters[i],
                      style: TextStyle(
                        color:
                            _selectedFilter == i
                                ? Colors.black
                                : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: _selectedFilter == i,
                    selectedColor: const Color(0xFFF8BF13),
                    backgroundColor: Colors.grey[200],
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = i;
                      });
                      _loadForTab(i);
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildFilteredList()),
        ],
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
      ),
    );
  }

<<<<<<< HEAD
  // Widget _buildCarAdCard identique à celui de Transit (avec hover et animation)
  Widget _buildCarAdCard(Map<String, dynamic> car) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHovered ? Colors.amber : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(
                    Colors.grey.r.toInt(),
                    Colors.grey.g.toInt(),
                    Colors.grey.b.toInt(),
                    0.3,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
=======
  Widget _buildFilteredList() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMsg != null) {
      return Center(child: Text(errorMsg!));
    }
    if (_selectedFilter == 0) {
      // Soumis
      final filteredAds = carAds.where((ad) => !ad['proposed']).toList();
      return _buildCarList(filteredAds);
    } else if (_selectedFilter == 1) {
      // Soumettre: éléments non cliquables et affichage du montant proposé
      final filteredAds = carAds.where((ad) => ad['proposed']).toList();
      return _buildSoumettreList(filteredAds);
    } else if (_selectedFilter == 2) {
      // Validés
      return _buildValidesList();
    } else {
      // Archivés
      return _buildArchivesList();
    }
  }

  Widget _buildCarList(List<Map<String, dynamic>> ads) {
    return ListView.builder(
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final car = ads[index];
        return GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CarDetailsPage(
                        car: car,
                        onProposalSubmitted:
                            (amount) => updateProposalStatus(
                              carAds.indexOf(car),
                              amount,
                            ),
                      ),
                ),
              ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
<<<<<<< HEAD
                  child: Image.asset(
                    car['images'][0],
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
=======
                  child: _buildImageThumb(car, height: 80, width: 80),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car['description'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        if (car['proposed'] == true &&
                            car['proposedAmount'] != null)
                          Text(
                            'Proposé : ${car['proposedAmount']} f',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            car['price'] ?? '',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
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
    );
  }

  // Liste Soumettre: non cliquable + montant proposé visible
  Widget _buildSoumettreList(List<Map<String, dynamic>> ads) {
    return ListView.builder(
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final car = ads[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageThumb(car, height: 80, width: 80),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
<<<<<<< HEAD
                        car['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${car['price']} f",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
=======
                        car['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car['description'] ?? '',
                        style: const TextStyle(color: Colors.grey),
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD
                if (activeFilter == 'Soumis' && car['proposedAmount'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 16.0),
                    child: Text(
                      '${car['prColors.amberoposedAmount']} f',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
=======
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  (car['proposedAmount'] ?? car['montant'] ?? '') != ''
                      ? 'Proposé: ${(car['proposedAmount'] ?? car['montant']).toString()} f'
                      : '',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValidesList() {
    if (valides.isEmpty) {
      return const Center(child: Text('Aucune proposition validée.'));
    }
    return ListView.builder(
      itemCount: valides.length,
      itemBuilder: (context, index) {
        final item = valides[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading:
                item['images'] != null && item['images'].isNotEmpty
                    ? _buildImageThumb(item, height: 48, width: 48)
                    : null,
            title: Text(
              item['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['description'] ?? ''),
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Validé',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  tooltip: 'Je ne suis pas disponible',
                  onPressed: () {
                    setState(() {
                      archives.add(item);
                      valides.remove(item);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.amber),
                  tooltip: 'J\'accepte',
                  onPressed: () {
                    setState(() {
                      // Passe dans transit.dart (enTransit ou enConsumption selon le détail)
                      // Ici, on simule juste le retrait de la liste
                      valides.remove(item);
                    });
                  },
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildArchivesList() {
    if (archives.isEmpty) {
      return const Center(child: Text('Aucune proposition archivée.'));
    }
    return ListView.builder(
      itemCount: archives.length,
      itemBuilder: (context, index) {
        final item = archives[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading:
                item['images'] != null && item['images'].isNotEmpty
                    ? _buildImageThumb(item, height: 48, width: 48)
                    : null,
            title: Text(
              item['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item['description'] ?? ''),
            isThreeLine: true,
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
          ),
        );
      },
    );
  }
}

// Classe pour afficher les détails d'une voiture
class CarDetailsPage extends StatefulWidget {
  final Map<String, dynamic> car; // Détails de la voiture
  final Function(String)
  onProposalSubmitted; // Callback pour soumettre un tarif

  const CarDetailsPage({
    super.key,
    required this.car,
    required this.onProposalSubmitted,
  });

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  final TextEditingController _tarifController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        // title: Text(widget.car['title']!),
        // backgroundColor: Colors.amber,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildImageSection(), // Affiche une image d'exemple
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 24),
          _buildSpecifications(),
          const SizedBox(height: 24),
<<<<<<< HEAD
          _buildProposalSection(),
=======
          // Section de proposition déplacée sous le prix, on la supprime ici
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
        ],
      ),
    );
  }

  Widget _buildImageSection() {
<<<<<<< HEAD
    // Utilisation d'une image d'exemple pour le front-end
=======
    final List images = widget.car['images'] ?? [];
    final String? first = images.isNotEmpty ? images.first.toString() : null;
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
<<<<<<< HEAD
          child: Image.asset(
            'assets/images/car.png', // Image d'exemple
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(child: Text('Image non disponible')),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Description de l\'image',
          style: TextStyle(fontSize: 14, color: Colors.grey),
=======
          child:
              first == null
                  ? Container(
                    color: Colors.grey[300],
                    child: const Center(child: Text('Image non disponible')),
                  )
                  : (first.startsWith('http://') ||
                      first.startsWith('https://'))
                  ? Image.network(
                    first,
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
                  : Image.asset(
                    first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Image non disponible'),
                        ),
                      );
                    },
                  ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.car['description']?.toString() ?? '',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
<<<<<<< HEAD
    final specs = widget.car['specs'] as Map<String, String>;
=======
    final Map specsRaw =
        (widget.car['specs'] is Map) ? (widget.car['specs'] as Map) : {};
    // Utiliser des types dynamiques pour éviter les casts stricts
    final Map<String, dynamic> specs = {
      for (final entry in specsRaw.entries) entry.key.toString(): entry.value,
    };
    // Ne rien afficher si aucune spec utile
    final hasValue = specs.values.any(
      (v) => (v?.toString().trim().isNotEmpty ?? false),
    );
    if (!hasValue) {
      return const SizedBox.shrink();
    }
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isSmallScreen ? 2 : 3,
      childAspectRatio: isSmallScreen ? 2.0 : 2.5, // Réduit pour petits écrans
      mainAxisSpacing:
          isSmallScreen ? 8 : 16, // Réduit l'espacement pour petits écrans
      crossAxisSpacing: isSmallScreen ? 8 : 16,
      children:
          specs.entries.map((entry) {
            return Container(
              padding: EdgeInsets.all(
                isSmallScreen ? 8 : 12,
              ), // Padding réduit pour petits écrans
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize:
                          isSmallScreen ? 12 : 14, // Taille de police réduite
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
<<<<<<< HEAD
                    entry.value,
=======
                    entry.value?.toString() ?? '',
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
                    style: TextStyle(
                      fontSize:
                          isSmallScreen ? 11 : 12, // Taille de police réduite
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

<<<<<<< HEAD
=======
  Widget _buildImageThumb(
    Map<String, dynamic> item, {
    required double height,
    required double width,
  }) {
    final List images = item['images'] ?? [];
    if (images.isNotEmpty) {
      final first = images.first.toString();
      final isNetwork =
          first.startsWith('http://') || first.startsWith('https://');
      if (isNetwork) {
        return Image.network(
          first,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _imageFallback(height, width),
        );
      } else {
        return Image.asset(
          first,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _imageFallback(height, width),
        );
      }
    }
    return _imageFallback(height, width);
  }

  Widget _imageFallback(double h, double w) {
    return Container(
      height: h,
      width: w,
      color: Colors.grey[300],
      child: const Icon(Icons.directions_car, color: Colors.grey),
    );
  }

>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.car['title']!,
          style: TextStyle(
            fontSize: screenWidth > 600 ? 24 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.car['company']!,
          style: TextStyle(
            fontSize: screenWidth > 600 ? 20 : 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.car['price']!,
          style: TextStyle(
            fontSize: screenWidth > 600 ? 22 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
<<<<<<< HEAD
=======
        const SizedBox(height: 12),
        _buildInlineProposal(),
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.car['description']!,
      style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
    );
  }

  Widget _buildProposalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proposez votre tarif pour le transit :',
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _tarifController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Entrez votre tarif',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // Aligne le bouton sur la droite
          children: [
            ElevatedButton(
              onPressed: () {
                final tarif = _tarifController.text;
                if (tarif.isNotEmpty) {
                  widget.onProposalSubmitted(tarif);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tarif proposé: $tarif f'),
                      backgroundColor: Colors.amber,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Soumettre'),
            ),
          ],
        ),
      ],
    );
  }
<<<<<<< HEAD
=======

  // Section de soumission de tarif (inline sous le prix)
  Widget _buildInlineProposal() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _tarifController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.local_shipping,
                  color: Colors.amber,
                ),
                hintText: 'Proposez votre tarif de transit',
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.amber, width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final tarif = _tarifController.text.trim();
              if (tarif.isNotEmpty) {
                widget.onProposalSubmitted(tarif);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tarif proposé: $tarif f')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8BF13),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );
  }
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
}
