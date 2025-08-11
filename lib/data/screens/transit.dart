import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/article_service.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'discussion.dart';

class Transit extends StatefulWidget {
  const Transit({super.key});

  @override
  State<Transit> createState() => _TransitState();
}

class _TransitState extends State<Transit> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ArticleService _articleService = ArticleService();
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  String? currentUserId;
  Map<String, dynamic>? currentUserData;

  List<Map<String, dynamic>> inTransit = [];
  List<Map<String, dynamic>> inConsumption = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

      // Charger les articles en transit
      final transitArticles = await _articleService.getArticlesByStatus(
        'en_transit',
      );
      final consumptionArticles = await _articleService.getArticlesByStatus(
        'en_consommation',
      );

      if (mounted) {
        setState(() {
          inTransit =
              transitArticles
                  .map(
                    (article) =>
                        _articleService.formatArticleForDisplay(article),
                  )
                  .toList();
          inConsumption =
              consumptionArticles
                  .map(
                    (article) =>
                        _articleService.formatArticleForDisplay(article),
                  )
                  .toList();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransitList(inTransit),
          _buildTransitList(inConsumption),
        ],
      ),
    );
  }

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
                  ),
                ),
              ],
            ),
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
          ),
        );
      },
    );
  }
}
