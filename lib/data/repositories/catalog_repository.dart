import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/local_data_cache.dart';

/// Erreur réseau / API pour les listes catalogue (messages UI côté écran).
class CatalogFetchException implements Exception {
  final int? statusCode;
  final bool isNetwork;

  CatalogFetchException({this.statusCode, this.isNetwork = false});

  @override
  String toString() =>
      isNetwork ? 'network' : 'http_${statusCode ?? 'unknown'}';
}

/// HTTP + cache local des listes catalogue (voitures / motos / pièces).
/// URLs et clés de cache inchangées vs les écrans d'origine.
class CatalogRepository {
  CatalogRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const cacheVoitures = 'catalog_voitures';
  static const cacheMotos = 'catalog_motos';
  static const cachePieces = 'catalog_pieces';

  Future<Map<String, String>> _optionalAuthHeaders() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };
  }

  Future<List<dynamic>?> readStale(String cacheKey) =>
      LocalDataCache.readJsonListStale(cacheKey);

  /// GET `/public/articles?type=…` — même URL / timeout / cache qu'avant.
  Future<List<dynamic>> fetchPublicArticles({
    required String type,
    required String cacheKey,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final headers = await _optionalAuthHeaders();
      final response = await _client
          .get(
            Uri.parse('${getBaseUrl()}/public/articles?type=$type'),
            headers: headers,
          )
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw CatalogFetchException(statusCode: response.statusCode);
      }
      final data = jsonDecode(response.body) as List<dynamic>;
      await LocalDataCache.writeJsonList(cacheKey, data);
      return data;
    } on CatalogFetchException {
      rethrow;
    } catch (_) {
      throw CatalogFetchException(isNetwork: true);
    }
  }

  /// Motos pour filtres vendeur moto-only (écran voitures) — URL inchangée.
  Future<List<dynamic>> fetchMotosForFilters() async {
    try {
      final headers = await _optionalAuthHeaders();
      final response = await _client.get(
        Uri.parse(
          '${getBaseUrl()}/public/articles?type=moto&statut=en_ligne&vendu=false',
        ),
        headers: headers,
      );
      if (response.statusCode != 200) {
        throw CatalogFetchException(statusCode: response.statusCode);
      }
      return jsonDecode(response.body) as List<dynamic>;
    } on CatalogFetchException {
      rethrow;
    } catch (_) {
      throw CatalogFetchException(isNetwork: true);
    }
  }

  /// DELETE `/articles/:id` — même URL / headers qu'avant.
  Future<void> deleteArticle(String articleId) async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await _client.delete(
        Uri.parse('${getBaseUrl()}/articles/$articleId'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw CatalogFetchException(statusCode: response.statusCode);
      }
    } on CatalogFetchException {
      rethrow;
    } catch (_) {
      throw CatalogFetchException(isNetwork: true);
    }
  }

  /// GET `/public/articles/:id` — détail article (phone vendeur, etc.).
  Future<Map<String, dynamic>?> fetchPublicArticle(String id) async {
    if (id.isEmpty) return null;
    try {
      final headers = await _optionalAuthHeaders();
      final res = await _client.get(
        Uri.parse('${getBaseUrl()}/public/articles/$id'),
        headers: headers,
      );
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// GET `/admin/verification-pricing` — prix vérification véhicule.
  /// Retourne null si échec (l'écran garde son défaut).
  Future<int?> fetchVerificationPricing() async {
    try {
      final res = await _client.get(
        Uri.parse(
          '${UserService().dio.options.baseUrl}/admin/verification-pricing',
        ),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final raw = data['prixVerification'] ??
          (data['pricing'] is Map
              ? data['pricing']['prixVerification']
              : null);
      final parsed = int.tryParse('$raw');
      if (parsed == null || parsed < 0) return null;
      return parsed;
    } catch (_) {
      return null;
    }
  }

  /// POST/DELETE `/users/me/favoris` — même base URL dio / body qu'avant.
  /// [isFavorite] = déjà en favoris (DELETE si true, POST sinon).
  /// Retourne true si status 200.
  Future<bool> toggleFavorite({
    required String articleId,
    required bool isFavorite,
  }) async {
    if (articleId.isEmpty) return false;
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) return false;
      final uri = Uri.parse(
        '${UserService().dio.options.baseUrl}/users/me/favoris',
      );
      final headers = {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({'articleId': articleId});
      final response = isFavorite
          ? await _client.delete(uri, headers: headers, body: body)
          : await _client.post(uri, headers: headers, body: body);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
