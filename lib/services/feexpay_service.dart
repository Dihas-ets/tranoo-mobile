import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/feexpay_config.dart';

class FeexPayService {
  /// Headers pour les requêtes API
  static Map<String, String> get _headers => FeexPayConfig.defaultHeaders;

  /// Initialise le service FeexPay
  static Future<void> initialize() async {
    try {
      // Vérifier la connexion avec l'API
      final response = await http.get(
        Uri.parse('${FeexPayConfig.baseUrl}/status'),
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
        'amount': amount,
        'custom_id': customId,
        'description': description,
        'callback_url': callbackUrl ?? FeexPayConfig.successCallbackUrl,
        'error_callback_url':
            errorCallbackUrl ?? FeexPayConfig.errorCallbackUrl,
        'case': paymentType,
        'custom_fields': customFields,
        'mode': FeexPayConfig.mode,
        'currency': FeexPayConfig.defaultCurrency,
      };

      final response = await http.post(
        Uri.parse('${FeexPayConfig.baseUrl}/payment/init'),
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'data': data,
          'payment_url': data['payment_url'],
          'transaction_id': data['transaction_id'],
        };
      } else {
        return {
          'status': 'error',
          'message':
              'Erreur lors de l\'initialisation du paiement: ${response.statusCode}',
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
        Uri.parse('${FeexPayConfig.baseUrl}/transaction/$transactionId/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'data': data};
      } else {
        return {
          'status': 'error',
          'message': 'Erreur lors de la vérification: ${response.statusCode}',
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
    try {
      if (!FeexPayConfig.isValidAmount(amount)) {
        return {
          'status': 'error',
          'message': FeexPayConfig.errorMessages['invalid_amount']!,
        };
      }

      final payload = {
        'transaction_id': transactionId,
        'amount': amount,
        'reason': reason,
      };

      final response = await http.post(
        Uri.parse('${FeexPayConfig.baseUrl}/transaction/refund'),
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'data': data};
      } else {
        return {
          'status': 'error',
          'message': 'Erreur lors du reversement: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erreur lors du reversement: $e'};
    }
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
        '${FeexPayConfig.baseUrl}/transactions',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions'] ?? []);
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
    try {
      final response = await http.get(
        Uri.parse('${FeexPayConfig.baseUrl}/account/balance'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'data': data};
      } else {
        return {
          'status': 'error',
          'message':
              'Erreur lors de la récupération du solde: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur lors de la récupération du solde: $e',
      };
    }
  }

  /// Envoie de l'argent à un autre compte FeexPay
  static Future<Map<String, dynamic>> sendMoney({
    required String recipientEmail,
    required double amount,
    String? description,
  }) async {
    try {
      if (!FeexPayConfig.isValidAmount(amount)) {
        return {
          'status': 'error',
          'message': FeexPayConfig.errorMessages['invalid_amount']!,
        };
      }

      final payload = {
        'recipient_email': recipientEmail,
        'amount': amount,
        'description': description,
      };

      final response = await http.post(
        Uri.parse('${FeexPayConfig.baseUrl}/money/send'),
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'data': data};
      } else {
        return {
          'status': 'error',
          'message': 'Erreur lors de l\'envoi: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Erreur lors de l\'envoi: $e'};
    }
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
}
