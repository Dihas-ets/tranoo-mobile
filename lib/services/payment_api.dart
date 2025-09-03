import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/services/user_service.dart';

class PaymentApi {
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
}
