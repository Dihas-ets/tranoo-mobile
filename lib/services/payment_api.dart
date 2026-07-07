import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/feexpay_error_messages.dart';
import 'package:tranoo/utils/payment_debug_logger.dart';

class PaymentApi {
  static String _extractApiError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      final fromPayload = FeexPayErrorMessages.fromApiPayload(data);
      if (fromPayload != 'Paiement impossible pour le moment.') {
        return fromPayload;
      }
      if (status != null) {
        return FeexPayErrorMessages.fromHttpStatus(status, fallback: error.message);
      }
      if (data is Map) {
        final nested = data['error'];
        if (nested is Map) {
          final nestedMsg = nested['message'] ?? nested['error'];
          if (nestedMsg != null && nestedMsg.toString().trim().isNotEmpty) {
            return nestedMsg.toString();
          }
        } else if (nested is String && nested.trim().isNotEmpty) {
          return nested.trim();
        }
        final details = data['details'];
        if (details is Map) {
          final detailMsg = details['message'] ?? details['error'];
          if (detailMsg != null && detailMsg.toString().trim().isNotEmpty) {
            return detailMsg.toString();
          }
        }
        final message = data['message'] ?? data['reason'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
      return error.message ?? 'Erreur réseau pendant le paiement';
    }
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  static Dio _dioWithAuth(String? token) {
    if (token == null || token.isEmpty) {
      throw Exception('Token d\'authentification indisponible');
    }
    return Dio(
      BaseOptions(
        baseUrl: getBaseUrl(),
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  // Initialiser un paiement RequestToPay dédié (sans WebView)
  static Future<Map<String, dynamic>> initRequestToPay({
    required String
    network, // ex: mtn, moov, celtiis_bj, coris, orange_sn, free_sn, wave_sn, togocom
    required double amount,
    required String customId,
    required String phoneNumber,
    String? description,
    String currency = 'XOF',
    String? achatId,
    String? publiciteId,
    String? type,
    String? duree,
    String? otp, // requis par certains réseaux (ex: Coris)
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final idToken = await user.getIdToken();
    final dio = _dioWithAuth(idToken);
    try {
      final response = await dio.post(
        '/payments/feexpay/requesttopay/$network',
        data: {
          'amount': amount,
          'currency': currency,
          'customId': customId,
          'phoneNumber': int.tryParse(phoneNumber) ?? phoneNumber,
          if (description != null) 'description': description,
          if (achatId != null) 'achatId': achatId,
          if (publiciteId != null) 'publiciteId': publiciteId,
          if (type != null) 'type': type,
          if (duree != null) 'duree': duree,
          if (otp != null) 'otp': otp,
        },
      );
      PaymentDebugLogger.api(
        'POST',
        '/payments/feexpay/requesttopay/$network',
        status: response.statusCode,
        body: response.data,
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      PaymentDebugLogger.api(
        'POST',
        '/payments/feexpay/requesttopay/$network',
        error: e,
      );
      throw Exception(_extractApiError(e));
    }
  }

  // Initialiser un paiement par carte (redirection vers page FeexPay)
  static Future<Map<String, dynamic>> initCardPayment({
    required double amount,
    required String customId,
    required String phone,
    required String firstName,
    required String lastName,
    required String email,
    required String typeCard,
    String? description,
    String currency = 'XOF',
    String? achatId,
    String? publiciteId,
    String? type,
    String? duree,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final idToken = await user.getIdToken();
    final dio = _dioWithAuth(idToken);
    try {
      final response = await dio.post(
        '/payments/feexpay/initcard',
        data: {
          'amount': amount,
          'currency': currency,
          'customId': customId,
          'phone': int.tryParse(phone) ?? phone,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'type_card': typeCard,
          if (description != null) 'description': description,
          if (achatId != null) 'achatId': achatId,
          if (publiciteId != null) 'publiciteId': publiciteId,
          if (type != null) 'type': type,
          if (duree != null) 'duree': duree,
        },
      );
      PaymentDebugLogger.api(
        'POST',
        '/payments/feexpay/initcard',
        status: response.statusCode,
        body: response.data,
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      PaymentDebugLogger.api('POST', '/payments/feexpay/initcard', error: e);
      throw Exception(_extractApiError(e));
    }
  }

  static Future<Map<String, dynamic>> initFeexPayPayment({
    required double amount,
    required String description,
    required String customId,
    String? achatId,
    String? method, // MOBILE, CARD, WALLET
    String currency = 'XOF',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final idToken = await user.getIdToken();
    final dio = _dioWithAuth(idToken);
    final response = await dio.post(
      '/payments/feexpay/init',
      data: {
        'amount': amount,
        'description': description,
        'customId': customId,
        if (achatId != null) 'achatId': achatId,
        if (method != null) 'method': method,
        'currency': currency,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  static Future<Map<String, dynamic>> getPaymentStatus(String idOrTxn) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final idToken = await user.getIdToken();
    final dio = _dioWithAuth(idToken);
    final response = await dio.get('/payments/$idOrTxn');
    return Map<String, dynamic>.from(response.data);
  }

  // Statut public FeexPay via id_transaction (pas lié à notre paymentId interne)
  static Future<Map<String, dynamic>> getFeexPublicStatus(
    String idTransaction, {
    String? paymentId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final idToken = await user.getIdToken();
    final dio = _dioWithAuth(idToken);
    final response = await dio.get(
      '/payments/feexpay/public/status/$idTransaction',
      queryParameters: paymentId != null ? {'paymentId': paymentId} : null,
    );
    return Map<String, dynamic>.from(response.data);
  }

  // Envoyer des logs/hints pour aider le backend à extraire l'id_transaction
  static Future<Map<String, dynamic>> traceFromClient({
    required String paymentId,
    String? url,
    String? text,
    String? html,
    String? message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final idToken = await user.getIdToken();
    final dio = _dioWithAuth(idToken);
    final response = await dio.post(
      '/payments/feexpay/trace',
      data: {
        'paymentId': paymentId,
        if (url != null) 'url': url,
        if (text != null) 'text': text,
        if (html != null) 'html': html,
        if (message != null) 'message': message,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }
}
