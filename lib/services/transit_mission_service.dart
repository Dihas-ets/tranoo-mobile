import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/services/user_service.dart';

class TransitSelectResult {
  final bool ok;
  final Map<String, dynamic>? mission;
  final String? error;

  const TransitSelectResult({required this.ok, this.mission, this.error});
}

class TransitMissionService {
  TransitMissionService._();
  static final TransitMissionService instance = TransitMissionService._();

  Dio get _dio => UserService().dio;

  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>?> getParcours(String articleId) async {
    try {
      final resp = await _dio.get(
        '/transit-missions/parcours/$articleId',
        options: Options(headers: await _headers()),
      );
      if (resp.data is Map) {
        return Map<String, dynamic>.from(resp.data as Map);
      }
    } catch (_) {}
    return null;
  }

  Future<void> startParcours({
    required String articleId,
    String? articleTitre,
    String? modeLivraison,
    String? paysDestination,
    String? detailsSupplementaires,
  }) async {
    try {
      await _dio.post(
        '/transit-missions/start',
        data: {
          'articleId': articleId,
          if (articleTitre != null && articleTitre.trim().isNotEmpty)
            'articleTitre': articleTitre.trim(),
          if (modeLivraison != null) 'modeLivraison': modeLivraison,
          if (paysDestination != null) 'paysDestination': paysDestination,
          if (detailsSupplementaires != null)
            'detailsSupplementaires': detailsSupplementaires,
        },
        options: Options(headers: await _headers()),
      );
    } catch (_) {}
  }

  Future<TransitSelectResult> selectTransitaire({
    required String articleId,
    required String transitaireId,
  }) async {
    try {
      final resp = await _dio.post(
        '/transit-missions/select-transitaire',
        data: {'articleId': articleId, 'transitaireId': transitaireId},
        options: Options(headers: await _headers()),
      );
      if (resp.data is Map) {
        return TransitSelectResult(
          ok: true,
          mission: Map<String, dynamic>.from(resp.data as Map),
        );
      }
      return const TransitSelectResult(ok: false, error: 'Réponse invalide');
    } on DioException catch (e) {
      final msg = e.response?.data;
      if (msg is Map && msg['message'] != null) {
        return TransitSelectResult(ok: false, error: msg['message'].toString());
      }
      return TransitSelectResult(
        ok: false,
        error: 'Impossible de sélectionner ce transitaire',
      );
    } catch (_) {
      return const TransitSelectResult(
        ok: false,
        error: 'Impossible de sélectionner ce transitaire',
      );
    }
  }

  Future<List<Map<String, dynamic>>> listMissions(String statut) async {
    try {
      final resp = await _dio.get(
        '/transit-missions/mes-missions',
        queryParameters: {'statut': statut},
        options: Options(headers: await _headers()),
      );
      final data = resp.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> marquerTraite(String missionId) async {
    try {
      final resp = await _dio.patch(
        '/transit-missions/$missionId/marquer-traite',
        options: Options(headers: await _headers()),
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
