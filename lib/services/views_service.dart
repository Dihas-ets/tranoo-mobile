import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:logging/logging.dart';

class ViewsService {
  static final ViewsService _instance = ViewsService._internal();
  factory ViewsService() => _instance;
  ViewsService._internal() {
    _dio.options.baseUrl = UserService().dio.options.baseUrl;
  }

  final Dio _dio = Dio();
  final Logger _logger = Logger('ViewsService');

  // Enregistrer une vue pour un article
  Future<bool> recordView(String articleId) async {
    try {
      if (articleId.isEmpty) return false;

      // Préparer les headers avec authentification si disponible
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        '/views/articles/$articleId/view',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        _logger.info('Vue enregistrée pour l\'article: $articleId');
        return true;
      }
      return false;
    } catch (e) {
      _logger.warning('Erreur enregistrement vue: $e');
      return false;
    }
  }

  // Obtenir les statistiques de vues pour un article
  Future<Map<String, dynamic>?> getArticleViews(String articleId) async {
    try {
      if (articleId.isEmpty) return null;

      final response = await _dio.get('/views/articles/$articleId/views');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.warning('Erreur récupération vues: $e');
      return null;
    }
  }

  // Obtenir les articles les plus vus
  Future<List<Map<String, dynamic>>> getMostViewedArticles({
    int limit = 10,
    String? type,
  }) async {
    try {
      Map<String, dynamic> queryParams = {'limit': limit.toString()};
      if (type != null && (type == 'voiture' || type == 'piece')) {
        queryParams['type'] = type;
      }

      final response = await _dio.get(
        '/views/articles/most-viewed',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> articles = response.data['articles'] ?? [];
        return articles.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      _logger.warning('Erreur articles les plus vus: $e');
      return [];
    }
  }

  // Mettre à jour les vues en lot (admin seulement)
  Future<bool> batchUpdateViews(List<Map<String, dynamic>> updates) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken();
      
      final response = await _dio.post(
        '/views/batch-update',
        data: {'updates': updates},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.info('Mise à jour lot vues réussie');
        return true;
      }
      return false;
    } catch (e) {
      _logger.warning('Erreur mise à jour lot vues: $e');
      return false;
    }
  }
}
