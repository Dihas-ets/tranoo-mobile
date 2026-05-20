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
    String? urgence,
    String? budgetMax,
    int quantity = 1,
    List<String>? photos,
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
        'urgence': (urgence ?? '').trim(),
        'anneeMin': (annee ?? '').trim(),
        'anneeMax': (annee ?? '').trim(),
        'budgetMax': (budgetMax ?? '').trim(),
        'quantity': quantity,
        if (photos != null && photos.isNotEmpty) 'photos': photos,
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      log('[ALERTE] vehicle error ${resp.statusCode}: ${resp.body}');
      throw Exception('Erreur envoi alerte (${resp.statusCode})');
    }
    await _trackDemoAlertCreated(kind: 'vehicle');
  }

  Future<void> createPieceAlert({
    required String marque,
    required String modele,
    required String pieceName,
    String? annee,
    String? urgence,
    int quantity = 1,
    List<String>? photos,
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
        'quantity': quantity,
        if (photos != null && photos.isNotEmpty) 'photos': photos,
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      log('[ALERTE] piece error ${resp.statusCode}: ${resp.body}');
      throw Exception('Erreur envoi alerte (${resp.statusCode})');
    }
    await _trackDemoAlertCreated(kind: 'piece');
  }

  /// KPI agent : action commerciale « création d'alerte » (best-effort).
  Future<void> _trackDemoAlertCreated({required String kind}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;
      await http.post(
        Uri.parse('${getApiBaseUrl()}/demo-events/track'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'eventType': 'alert_created',
          'page': 'alert_service.dart',
          'meta': {'kind': kind},
        }),
      );
    } catch (e) {
      log('[ALERTE] demo track skip: $e');
    }
  }
}

