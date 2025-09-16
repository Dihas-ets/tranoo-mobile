import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'discussion.dart';
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274

class Transit extends StatefulWidget {
  const Transit({super.key});

  @override
  State<Transit> createState() => _TransitState();
}

class _TransitState extends State<Transit> with SingleTickerProviderStateMixin {
  late TabController _tabController;
<<<<<<< HEAD

  final List<Map<String, dynamic>> inTransit = [
    {
      'title': 'Toyota Corolla',
      'status': 'En Transit',
      'price': '18,000,000 f',
      'image': 'assets/images/car.png',
      'proposedPrice': null, // Prix proposé par l'utilisateur
    },
    {
      'title': 'Honda Civic',
      'status': 'En Transit',
      'price': '20,000,000 f',
      'image': 'assets/images/care.png',
      'proposedPrice': null, // Prix proposé par l'utilisateur
    },
  ];

  final List<Map<String, dynamic>> inConsumption = [
    {
      'title': 'Ford Focus',
      'status': 'En Consommation',
      'price': '22,000,000 f',
      'image': 'assets/images/care.png',
      'proposedPrice': null, // Prix proposé par l'utilisateur
    },
  ];
=======
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  String? currentUserId;
  Map<String, dynamic>? currentUserData;

  List<Map<String, dynamic>> inTransit = [];
  List<Map<String, dynamic>> inConsumption = [];
  bool isLoading = true;
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
<<<<<<< HEAD
=======
    _getCurrentUserId();
    _loadArticles();
  }

  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Récupérer l'ID MongoDB du transitaire connecté
        final response = await _userService.dio.get(
          '/protected/me',
          options: Options(
            headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
          ),
        );
        if (response.statusCode == 200) {
          final userData = response.data['user'];
          setState(() {
            currentUserId = userData['_id'];
            currentUserData = userData;
          });
        }
      } catch (e) {
        print('Erreur lors de la récupération des données utilisateur: $e');
        // Fallback vers Firebase UID si erreur
        setState(() {
          currentUserId = user.uid;
        });
      }
    }
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        isLoading = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final idToken = await user.getIdToken();
      final String baseUrl = getBaseUrl();
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );
      // Articles acceptés par le transitaire (proposition validée), statutVente = en_attente
      final resp = await dio.get('/transit/acceptes');
      final List data = resp.data is List ? resp.data : [];
      final items =
          data.map<Map<String, dynamic>>((a) => _mapArticle(a)).toList();
      // Partition selon type (faute d’un flag dédié achat, on se base sur type)
      final transit =
          items.where((e) => (e['type'] ?? '') == 'voiture').toList();
      final consommation =
          items.where((e) => (e['type'] ?? '') == 'piece').toList();
      if (mounted) {
        setState(() {
          inTransit = transit;
          inConsumption = consommation;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des articles: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _mapArticle(dynamic a) {
    final List photos = (a['photos'] is List) ? a['photos'] : [];
    final String? image = photos.isNotEmpty ? photos.first?.toString() : null;
    final type = (a['type'] ?? '').toString();
    return {
      '_id': a['_id'],
      'id': a['_id'],
      'title': a['titre'] ?? '',
      'description': _buildDescriptionFromArticle(a),
      'price': a['prix'] != null ? '${a['prix']} f' : '',
      'image': image,
      'type': type,
      'vendeur': a['vendeur'],
    };
  }

  String _buildDescriptionFromArticle(dynamic a) {
    final parts = <String>[];
    if (a['annee'] != null) parts.add('${a['annee']}');
    if (a['marque'] != null) parts.add('${a['marque']}');
    if (a['modele'] != null) parts.add('${a['modele']}');
    if (a['lieu'] != null) parts.add('${a['lieu']}');
    return parts.where((e) => e.toString().trim().isNotEmpty).join(', ');
  }

  void _openDiscussion(Map<String, dynamic> article) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Utilisateur non connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('DEBUG: Article data: $article');
      print('DEBUG: Current user ID: $currentUserId');

      // Vérifier que l'article a un ID (peut être 'id' ou '_id')
      final articleId = article['_id'] ?? article['id'];
      print('DEBUG: Article ID found: $articleId');

      if (articleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: Article sans ID'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Récupérer l'ID du vendeur de l'article
      final vendeurId =
          article['vendeur']?['_id'] ??
          article['vendeurId'] ??
          article['vendeur'];
      print('DEBUG: Vendeur ID: $vendeurId');

      if (vendeurId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erreur: Impossible de récupérer les informations du vendeur',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Créer ou récupérer la room de discussion
      final room = await _chatService.createOrGetRoom(
        user1Id: currentUserId!,
        user2Id: vendeurId,
        articleId: articleId,
      );

      if (room != null) {
        // Naviguer vers la discussion
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => Discussion(roomId: room['_id'], roomData: room),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création de la discussion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de la discussion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Mes Transits'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icône de retour
          onPressed: () {
            Navigator.pop(context); // Retour à la page précédente
          },
        ),
        backgroundColor: Colors.amber,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize:
                18, // Augmente la taille du texte des onglets sélectionnés
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize:
                16, // Taille légèrement plus petite pour les onglets non sélectionnés
            fontWeight: FontWeight.normal,
          ),
          labelColor:
              Colors.white, // Couleur du texte pour l'onglet sélectionné
          unselectedLabelColor:
              Colors
                  .black, // Couleur du texte pour les onglets non sélectionnés
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: Colors.black, // Couleur du soulignement
              width: 3, // Épaisseur du soulignement
            ),
            insets: const EdgeInsets.symmetric(
              horizontal: 16,
            ), // Marges du soulignement
          ),
          tabs: const [Tab(text: 'En Transits'), Tab(text: 'En Consommation')],
        ),
      ),
=======
        automaticallyImplyLeading: false,
        title: const Text('Mes Transits'),
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.black,
          tabs: const [Tab(text: 'En Transit'), Tab(text: 'En Consommation')],
        ),
      ),
      backgroundColor: Colors.white,
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransitList(inTransit),
          _buildTransitList(inConsumption),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildTransitList(List<Map<String, dynamic>> transits) {
    if (transits.isEmpty) {
      return const Center(
        child: Text(
          'Aucun transit disponible',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: transits.length,
      itemBuilder: (context, index) {
        final transit = transits[index];
        return _buildTransitCard(transit);
      },
    );
  }

  Widget _buildTransitCard(Map<String, dynamic> transit) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false; // Variable pour suivre l'état du survol

        return MouseRegion(
          onEnter: (_) {
            setState(() {
              isHovered = true; // Active l'effet de survol
            });
          },
          onExit: (_) {
            setState(() {
              isHovered = false; // Désactive l'effet de survol
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isHovered
                        ? Colors.amber
                        : Colors.transparent, // Bordure amber au survol
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 77),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image miniature
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    transit['image']!, // Image associée au transit
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 16,
                ), // Espacement entre l'image et le texte
                // Texte descriptif
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transit['title']!, // Titre du transit
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transit['status']!, // Statut du transit
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transit['price']!, // Prix du transit
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      if (transit['proposedPrice'] !=
                          null) // Affiche le prix proposé s'il existe
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Proposé: ${transit['proposedPrice']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
=======
  Widget _buildTransitList(List<Map<String, dynamic>> list) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(child: Text('Aucun article dans cette catégorie'));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading:
                item['image'] != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    )
                    : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            title: Text(
              item['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['description'] ?? ''),
                const SizedBox(height: 4),
                Text(
                  'Prix: ${item['price'] ?? 'Non spécifié'}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
=======
            trailing: ElevatedButton(
              onPressed: () => _openDiscussion(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Discuter',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            isThreeLine: true,
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
          ),
        );
      },
    );
  }
}
