import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/backend_config.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return await user?.getIdToken(true);
    } catch (e) {
      log('[ALERTE] token error: $e');
      return null;
    }
  }

  Future<void> createVehicleAlert({
    required String marque,
    required String modele,
    String? annee,
    String? etat,
    String? budgetMax,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Token manquant. Veuillez vous reconnecter.');
    }

    final url = '${getApiBaseUrl()}/notifications/search-request';
    log('[ALERTE] POST $url (vehicle)');

    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'marque': marque.trim(),
        'modele': modele.trim(),
        'etat': (etat ?? '').trim(),
        'anneeMin': (annee ?? '').trim(),
        'anneeMax': (annee ?? '').trim(),
        'budgetMax': (budgetMax ?? '').trim(),
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      log('[ALERTE] vehicle error ${resp.statusCode}: ${resp.body}');
      throw Exception('Erreur envoi alerte (${resp.statusCode})');
    }
  }

  Future<void> createPieceAlert({
    required String marque,
    required String modele,
    required String pieceName,
    String? annee,
    String? urgence,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Token manquant. Veuillez vous reconnecter.');
    }

    final url = '${getApiBaseUrl()}/notifications/piece-search-request';
    log('[ALERTE] POST $url (piece)');

    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'marque': marque.trim(),
        'modele': modele.trim(),
        'annee': (annee ?? '').trim(),
        'pieceName': pieceName.trim(),
        'urgence': (urgence ?? '').trim(),
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      log('[ALERTE] piece error ${resp.statusCode}: ${resp.body}');
      throw Exception('Erreur envoi alerte (${resp.statusCode})');
    }
  }
}

