import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class ArticleService {
  static final ArticleService _instance = ArticleService._internal();
  factory ArticleService() => _instance;
  ArticleService._internal();

  final String _baseUrl = getBaseUrl();

  // Récupérer le token d'authentification
  Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  // Récupérer tous les articles
  Future<List<Map<String, dynamic>>> getAllArticles() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse('$_baseUrl/articles'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
          'Erreur lors de la récupération des articles: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des articles: $e');
      return [];
    }
  }

  // Récupérer les articles par statut (en transit, en consommation, etc.)
  Future<List<Map<String, dynamic>>> getArticlesByStatus(String status) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse('$_baseUrl/articles?status=$status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
          'Erreur lors de la récupération des articles par statut: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des articles par statut: $e');
      return [];
    }
  }

  // Récupérer un article par ID
  Future<Map<String, dynamic>?> getArticleById(String articleId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse('$_baseUrl/articles/$articleId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Erreur lors de la récupération de l\'article: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'article: $e');
      return null;
    }
  }

  // Récupérer les articles d'un vendeur
  Future<List<Map<String, dynamic>>> getArticlesByVendeur(
    String vendeurId,
  ) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Token d\'authentification manquant');

      final response = await http.get(
        Uri.parse('$_baseUrl/articles?vendeur=$vendeurId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
          'Erreur lors de la récupération des articles du vendeur: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Erreur lors de la récupération des articles du vendeur: $e');
      return [];
    }
  }

  // Formater les données d'article pour l'affichage
  Map<String, dynamic> formatArticleForDisplay(Map<String, dynamic> article) {
    return {
      'id': article['_id'] ?? '',
      'title': article['titre'] ?? 'Sans titre',
      'status': article['statut'] ?? 'En attente',
      'price':
          article['prix'] != null ? '${article['prix']} f' : 'Prix non défini',
      'image':
          article['photos'] != null && (article['photos'] as List).isNotEmpty
              ? article['photos'][0]
              : 'assets/images/car.png',
      'proposedPrice':
          article['prixPropose'] != null ? '${article['prixPropose']} f' : null,
      'vendeurId': article['vendeur']?['_id'] ?? '',
      'vendeurNom':
          article['vendeur'] != null
              ? '${article['vendeur']['prenoms'] ?? ''} ${article['vendeur']['nom'] ?? ''}'
                  .trim()
              : 'Vendeur inconnu',
      'description': article['description'] ?? '',
      'categorie': article['categorie'] ?? '',
      'dateCreation': article['createdAt'] ?? '',
    };
  }
}
