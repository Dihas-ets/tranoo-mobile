import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'discussion.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';

class Transit extends StatefulWidget {
  const Transit({super.key});

  @override
  State<Transit> createState() => _TransitState();
}

class _TransitState extends State<Transit> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
      final resp = await dio.get('/transit/acceptes');
      final List data = resp.data is List ? resp.data : [];
      final items =
          data.map<Map<String, dynamic>>((a) => _mapArticle(a)).toList();
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
    final l10n = AppLocalizations.of(context)!;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorUserNotConnected),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final articleId = article['_id'] ?? article['id'];
    if (articleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.articleWithoutId),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vendeurId =
        article['vendeur']?['_id'] ??
        article['vendeurId'] ??
        article['vendeur'];

    if (vendeurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sellerInfoError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final room = await _chatService.createOrGetRoom(
        user1Id: currentUserId!,
        user2Id: vendeurId,
        articleId: articleId,
      );

      if (room != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => Discussion(roomId: room['_id'], roomData: room),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.discussionCreationError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneric(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.myTransits),
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.black,
          tabs: [
            Tab(text: l10n.inTransit),
            Tab(text: l10n.inConsumption),
          ],
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
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return Center(child: Text(l10n.noArticlesInCategory));
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
                      child: TranooNetworkImage(
                        url: item['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        cloudinaryWidthPx: cloudinaryWidthPx(
                          context,
                          logicalWidth: 60,
                        ),
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
                  l10n.priceWithValue(
                    item['price']?.toString().isNotEmpty == true
                        ? item['price'].toString()
                        : l10n.priceNotSpecified,
                  ),
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
              child: Text(
                l10n.discuss,
                style: const TextStyle(
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
