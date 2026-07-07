import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/feexpay_config.dart';
import '../utils/payment_debug_logger.dart';

class FeexPayService {
  static const _transactionsPath = '/api/transactions';
  static const _statusPath = '/api/transactions/public/single/status';
  static const _feexLinkInitPath = '/api/feexlink/api-create';

  /// Headers pour les requêtes API
  static Map<String, String> get _headers => FeexPayConfig.defaultHeaders;

  /// Initialise le service FeexPay
  static Future<void> initialize() async {
    if (!_hasCredentials()) {
      throw Exception(FeexPayConfig.errorMessages['invalid_credentials']!);
    }
    try {
      final response = await http.get(
        Uri.parse('${FeexPayConfig.baseUrl}$_transactionsPath?page=1&limit=1'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('FeexPay service initialisé avec succès');
      } else {
        debugPrint(
          'Erreur lors de l\'initialisation de FeexPay: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de FeexPay: $e');
    }
  }

  /// Lance un paiement avec FeexPay
  static Future<Map<String, dynamic>> startPayment({
    required double amount,
    required String customId,
    required String description,
    String? callbackUrl,
    String? errorCallbackUrl,
    String? paymentType, // "MOBILE", "CARD", "WALLET"
    Map<String, String>? customFields,
  }) async {
    if (!_hasCredentials()) {
      return {
        'status': 'error',
        'message': FeexPayConfig.errorMessages['invalid_credentials']!,
      };
    }
    try {
      // Validation des paramètres
      if (!FeexPayConfig.isValidAmount(amount)) {
        return {
          'status': 'error',
          'message': FeexPayConfig.errorMessages['invalid_amount']!,
        };
      }

      if (paymentType != null &&
          !FeexPayConfig.isValidPaymentType(paymentType)) {
        return {
          'status': 'error',
          'message': FeexPayConfig.errorMessages['invalid_payment_type']!,
        };
      }

      final payload = {
        'shop': FeexPayConfig.shopId,
        'amount': amount.round(),
        'description': description,
        'paymentMethod': paymentType?.toUpperCase() ?? 'ALL',
        'success_redirect_url':
            callbackUrl ?? FeexPayConfig.successCallbackUrl,
        'error_redirect_url':
            errorCallbackUrl ?? FeexPayConfig.errorCallbackUrl,
        'callback_info': customId,
        'custom_fields': customFields,
        'range': 1,
        'expireIn': 15,
        'mode': FeexPayConfig.mode,
        'currency': FeexPayConfig.defaultCurrency,
      };

      PaymentDebugLogger.step('FEEXPAY_SERVICE', 'startPayment', {
        'amount': amount,
        'customId': customId,
        'paymentType': paymentType,
        'baseUrl': FeexPayConfig.baseUrl,
      });

      final response = await http.post(
        Uri.parse('${FeexPayConfig.baseUrl}$_feexLinkInitPath'),
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        PaymentDebugLogger.api(
          'POST',
          _feexLinkInitPath,
          status: response.statusCode,
          body: data,
        );
        return {
          'status': 'success',
          'data': data,
          'payment_url': data['urlPay'] ?? data['payment_url'] ?? data['url'],
          'transaction_id':
              data['reference'] ??
              data['id'] ??
              data['order_id'] ??
              data['short_code'],
        };
      } else {
        return {
          'status': 'error',
          'message': _extractErrorMessage(response),
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erreur lors du paiement: $e'};
    }
  }

  /// Vérifie le statut d'une transaction
  static Future<Map<String, dynamic>> checkTransactionStatus(
    String transactionId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${FeexPayConfig.baseUrl}$_statusPath/$transactionId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'data': data};
      } else {
        return {
          'status': 'error',
          'message': _extractErrorMessage(response),
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur lors de la vérification: $e',
      };
    }
  }

  /// Effectue un reversement
  static Future<Map<String, dynamic>> refund({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    return {
      'status': 'error',
      'message':
          'Le reversement direct n\'est pas expose par cette integration FeexPay v2.',
    };
  }

  /// Obtient l'historique des transactions
  static Future<List<Map<String, dynamic>>> getTransactionHistory({
    int? limit,
    int? offset,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse(
        '${FeexPayConfig.baseUrl}$_transactionsPath',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawList =
            (data is Map<String, dynamic> ? data['data'] : null) ??
            (data is Map<String, dynamic> ? data['transactions'] : null) ??
            [];
        return List<Map<String, dynamic>>.from(
          (rawList as List).map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return {
              ...map,
              'transaction_id':
                  map['id'] ??
                  map['reference'] ??
                  map['transaction_id'] ??
                  map['short_code'],
              'payment_method':
                  map['payment_method'] ?? map['paymentMethod'] ?? map['method'],
              'created_at':
                  map['created_at'] ?? map['createdAt'] ?? map['date'],
            };
          }),
        );
      } else {
        debugPrint(
          'Erreur lors de la récupération de l\'historique: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  /// Obtient le solde du compte
  static Future<Map<String, dynamic>> getAccountBalance() async {
    return {
      'status': 'error',
      'message':
          'Le solde FeexPay n\'est pas expose par cette integration FeexPay v2.',
    };
  }

  /// Envoie de l'argent à un autre compte FeexPay
  static Future<Map<String, dynamic>> sendMoney({
    required String recipientEmail,
    required double amount,
    String? description,
  }) async {
    return {
      'status': 'error',
      'message':
          'Le transfert direct n\'est pas expose par cette integration FeexPay v2.',
    };
  }

  /// Ouvre la page de paiement dans un navigateur
  static Future<void> openPaymentPage(String paymentUrl) async {
    try {
      // Utiliser url_launcher pour ouvrir la page de paiement
      // Cette méthode sera implémentée avec le package url_launcher
      debugPrint('Ouverture de la page de paiement: $paymentUrl');
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture de la page de paiement: $e');
    }
  }

  static bool _hasCredentials() {
    return FeexPayConfig.apiToken.isNotEmpty && FeexPayConfig.shopId.isNotEmpty;
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message =
            decoded['message'] ??
            decoded['error'] ??
            decoded['details'] ??
            decoded['status'];
        if (message != null) return message.toString();
      }
    } catch (_) {}
    return 'Erreur FeexPay: ${response.statusCode}';
  }
}
