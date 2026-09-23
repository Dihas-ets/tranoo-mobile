import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/services/user_service.dart';

/// Erreur HTTP / réseau pour le formulaire pub (une.dart).
class UneApiException implements Exception {
  final int? statusCode;
  final String? body;
  final bool isNetwork;

  UneApiException({this.statusCode, this.body, this.isNetwork = false});

  @override
  String toString() =>
      isNetwork ? 'network' : 'http_${statusCode ?? 'unknown'}';
}

/// HTTP du flux création pub / article (une.dart).
/// URLs et payloads inchangés vs l'écran d'origine.
class UneRepository {
  UneRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, String>> _authHeaders() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };
  }

  /// POST `/articles/` — retourne l'id article créé.
  Future<String> createArticle(Map<String, dynamic> articleData) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse('${getBaseUrl()}/articles/'),
        headers: headers,
        body: jsonEncode(articleData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dataResponse = jsonDecode(response.body);
        final id = dataResponse['article']['_id']?.toString();
        if (id == null || id.isEmpty) {
          throw UneApiException(
            statusCode: response.statusCode,
            body: response.body,
          );
        }
        return id;
      }
      throw UneApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    } on UneApiException {
      rethrow;
    } catch (_) {
      throw UneApiException(isNetwork: true);
    }
  }

  /// GET `/articles/:id` — détail article vendeur.
  Future<Map<String, dynamic>> fetchArticle(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.get(
        Uri.parse('${getBaseUrl()}/articles/$id'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        throw UneApiException(
          statusCode: response.statusCode,
          body: response.body,
        );
      }
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } on UneApiException {
      rethrow;
    } catch (_) {
      throw UneApiException(isNetwork: true);
    }
  }

  /// true si GET `/articles/:id` renvoie 200.
  Future<bool> articleExists(String id) async {
    try {
      await fetchArticle(id);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// GET `/admin/pub-pricing` — null si échec (garder defaults UI).
  Future<({double prixSponsoriseeParJour, double prixALaUneParJour})?>
      fetchPubPricing() async {
    try {
      final response = await _client.get(
        Uri.parse('${getBaseUrl()}/admin/pub-pricing'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (
        prixSponsoriseeParJour:
            ((data['prixSponsoriseeParJour'] ?? 1000.0) as num).toDouble(),
        prixALaUneParJour:
            ((data['prixALaUneParJour'] ?? 2000.0) as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  /// POST `/publicites/` — retourne l'id publicité créée.
  Future<String> createPublicite(Map<String, dynamic> pubData) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse('${getBaseUrl()}/publicites/'),
        headers: headers,
        body: jsonEncode(pubData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final id = data['publicite']['_id']?.toString();
        if (id == null || id.isEmpty) {
          throw UneApiException(
            statusCode: response.statusCode,
            body: response.body,
          );
        }
        return id;
      }
      throw UneApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    } on UneApiException {
      rethrow;
    } catch (_) {
      throw UneApiException(isNetwork: true);
    }
  }

  /// PATCH `/publicites/:id` — ex. statut payee.
  Future<bool> updatePubliciteStatut(
    String pubId, {
    required String statut,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.patch(
        Uri.parse('${getBaseUrl()}/publicites/$pubId'),
        headers: headers,
        body: jsonEncode({'statut': statut}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
