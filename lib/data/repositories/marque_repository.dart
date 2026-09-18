import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/data/models/article.dart';
import 'package:tranoo/data/models/article_voiture.dart';
import 'package:tranoo/data/models/pub.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/local_data_cache.dart';
import 'package:tranoo/utils/pub_validity.dart';

/// Erreur réseau / API pour l'accueil Marque (messages UI inchangés).
class MarqueFetchException implements Exception {
  final String message;
  MarqueFetchException(this.message);

  @override
  String toString() => message;
}

/// HTTP + cache local du catalogue accueil (pièces, véhicules, pubs, stats).
class MarqueRepository {
  MarqueRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String cacheKey(String name, {required bool isVendeur}) =>
      'marque_${name}_${isVendeur ? 'vendeur' : 'acheteur'}';

  Future<Map<String, String>> _authHeaders() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };
  }

  List<Article> _piecesFromJson(List<dynamic> data) => data
      .map((e) => Article.fromJson(Map<String, dynamic>.from(e as Map)))
      .where((p) => (p.statut ?? 'en_ligne') != 'vendu')
      .toList();

  List<ArticleVoiture> _vehiclesFromJson(List<dynamic> data) => data
      .map((e) => ArticleVoiture.fromJson(Map<String, dynamic>.from(e as Map)))
      .where((v) => (v.statut ?? 'en_ligne') != 'vendu')
      .toList();

  List<Pub> _pubsFromJson(List<dynamic> data) => data
      .map((e) => Pub.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  Future<List<dynamic>> _getJsonList(
    String url, {
    Duration? timeout,
  }) async {
    final headers = await _authHeaders();
    Future<http.Response> request =
        _client.get(Uri.parse(url), headers: headers);
    if (timeout != null) {
      request = request.timeout(timeout);
    }
    final response = await request;
    if (response.statusCode != 200) {
      throw MarqueFetchException('http_${response.statusCode}');
    }
    try {
      final decoded = json.decode(response.body);
      if (decoded is! List) {
        throw MarqueFetchException('format');
      }
      return decoded;
    } catch (e) {
      if (e is MarqueFetchException) rethrow;
      throw MarqueFetchException('format');
    }
  }

  Future<List<Article>?> readStalePieces({required bool isVendeur}) async {
    final stale = await LocalDataCache.readJsonListStale(
      cacheKey('pieces', isVendeur: isVendeur),
    );
    if (stale == null) return null;
    return _piecesFromJson(stale);
  }

  Future<List<Article>> fetchPieces({required bool isVendeur}) async {
    const path = '/public/articles?type=piece&statut=en_ligne&vendu=false';
    try {
      final data = await _getJsonList(
        '${getBaseUrl()}$path',
        timeout: const Duration(seconds: 8),
      );
      await LocalDataCache.writeJsonList(
        cacheKey('pieces', isVendeur: isVendeur),
        data,
      );
      return _piecesFromJson(data);
    } on MarqueFetchException catch (e) {
      if (e.message == 'format') {
        throw MarqueFetchException('Erreur de format de données');
      }
      throw MarqueFetchException('Erreur lors du chargement des pièces');
    } catch (e) {
      if (e is MarqueFetchException) rethrow;
      throw MarqueFetchException('Erreur réseau');
    }
  }

  Future<List<ArticleVoiture>?> readStaleVoitures({
    required bool isVendeur,
  }) async {
    final stale = await LocalDataCache.readJsonListStale(
      cacheKey('voitures', isVendeur: isVendeur),
    );
    if (stale == null) return null;
    return _vehiclesFromJson(stale);
  }

  Future<List<ArticleVoiture>> fetchVoitures({required bool isVendeur}) async {
    final path = isVendeur
        ? '/articles?type=voiture&statut=en_ligne&vendu=false'
        : '/public/articles?type=voiture&statut=en_ligne&vendu=false';
    try {
      final data = await _getJsonList(
        '${getBaseUrl()}$path',
        timeout: const Duration(seconds: 8),
      );
      await LocalDataCache.writeJsonList(
        cacheKey('voitures', isVendeur: isVendeur),
        data,
      );
      return _vehiclesFromJson(data);
    } on MarqueFetchException catch (e) {
      if (e.message.startsWith('http_')) {
        throw MarqueFetchException('Erreur lors du chargement des voitures');
      }
      rethrow;
    } catch (e) {
      if (e is MarqueFetchException) rethrow;
      throw MarqueFetchException('Erreur réseau');
    }
  }

  Future<List<ArticleVoiture>?> readStaleMotos({
    required bool isVendeur,
  }) async {
    final stale = await LocalDataCache.readJsonListStale(
      cacheKey('motos', isVendeur: isVendeur),
    );
    if (stale == null) return null;
    return _vehiclesFromJson(stale);
  }

  Future<List<ArticleVoiture>> fetchMotos({required bool isVendeur}) async {
    final path = isVendeur
        ? '/articles?type=moto&statut=en_ligne&vendu=false'
        : '/public/articles?type=moto&statut=en_ligne&vendu=false';
    try {
      final data = await _getJsonList(
        '${getBaseUrl()}$path',
        timeout: const Duration(seconds: 8),
      );
      await LocalDataCache.writeJsonList(
        cacheKey('motos', isVendeur: isVendeur),
        data,
      );
      return _vehiclesFromJson(data);
    } on MarqueFetchException catch (e) {
      if (e.message.startsWith('http_')) {
        throw MarqueFetchException('Erreur lors du chargement des motos');
      }
      rethrow;
    } catch (e) {
      if (e is MarqueFetchException) rethrow;
      throw MarqueFetchException('Erreur réseau');
    }
  }

  Future<List<Pub>?> readStalePubsALaUne({required bool isVendeur}) async {
    final stale = await LocalDataCache.readJsonListStale(
      cacheKey('pubs', isVendeur: isVendeur),
    );
    if (stale == null) return null;
    return _pubsFromJson(stale)
        .where((p) => p.typePub == 'À la une' && isPubValid(p))
        .toList();
  }

  Future<List<Pub>> fetchPubsALaUne({required bool isVendeur}) async {
    try {
      final data = await _getJsonList(
        '${getBaseUrl()}/public/publicites?statut=valide',
      );
      await LocalDataCache.writeJsonList(
        cacheKey('pubs', isVendeur: isVendeur),
        data,
      );
      return _pubsFromJson(data)
          .where((p) => p.typePub == 'À la une' && isPubValid(p))
          .toList();
    } on MarqueFetchException catch (e) {
      if (e.message.startsWith('http_') || e.message == 'format') {
        throw MarqueFetchException('Erreur lors du chargement des publicités');
      }
      rethrow;
    } catch (e) {
      if (e is MarqueFetchException) rethrow;
      throw MarqueFetchException('Erreur réseau');
    }
  }

  Future<List<Pub>?> readStalePubsSponsorisees({
    required bool isVendeur,
  }) async {
    final stale = await LocalDataCache.readJsonListStale(
      cacheKey('pubs_sponsor', isVendeur: isVendeur),
    );
    if (stale == null) return null;
    return _pubsFromJson(stale).where(isPubValid).toList();
  }

  Future<List<Pub>> fetchPubsSponsorisees({required bool isVendeur}) async {
    try {
      final data = await _getJsonList(
        '${getBaseUrl()}/public/publicites?typePub=Sponsorisée&statut=valide',
      );
      await LocalDataCache.writeJsonList(
        cacheKey('pubs_sponsor', isVendeur: isVendeur),
        data,
      );
      return _pubsFromJson(data).where(isPubValid).toList();
    } on MarqueFetchException catch (e) {
      if (e.message.startsWith('http_') || e.message == 'format') {
        throw MarqueFetchException('Erreur lors du chargement des publicités');
      }
      rethrow;
    } catch (e) {
      if (e is MarqueFetchException) rethrow;
      throw MarqueFetchException('Erreur réseau');
    }
  }

  Future<Map<String, dynamic>?> fetchSellerMarqueStats() async {
    final headers = await _authHeaders();
    final response = await _client
        .get(
          Uri.parse('${getBaseUrl()}/protected/stats/seller-marque'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<ArticleVoiture>> fetchVoituresEnAttente({
    required String type,
  }) async {
    try {
      final data = await _getJsonList(
        '${getBaseUrl()}/articles?type=$type&statut=en_attente&vendu=false',
        timeout: const Duration(seconds: 8),
      );
      return data
          .map((e) =>
              ArticleVoiture.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on MarqueFetchException catch (e) {
      if (e.message.startsWith('http_')) {
        final code = e.message.replaceFirst('http_', '');
        throw MarqueFetchException('Erreur chargement (code $code)');
      }
      rethrow;
    } catch (e) {
      if (e is MarqueFetchException) rethrow;
      throw MarqueFetchException('Erreur réseau');
    }
  }
}
