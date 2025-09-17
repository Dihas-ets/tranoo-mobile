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
    String? otp, // requis par certains réseaux (ex: Coris)
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final idToken = await user.getIdToken();
    final dio = _dioWithAuth(idToken);
    final response = await dio.post(
      '/payments/feexpay/requesttopay/$network',
      data: {
        'amount': amount,
        'currency': currency,
        'customId': customId,
        'phoneNumber': phoneNumber,
        if (description != null) 'description': description,
        if (achatId != null) 'achatId': achatId,
        if (otp != null) 'otp': otp,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  // Initialiser un paiement par carte (peut renvoyer une URL à ouvrir si nécessaire)
  static Future<Map<String, dynamic>> initCardPayment({
    required double amount,
    required String customId,
    String? description,
    String currency = 'XOF',
    String? achatId,
    String? cardHolderName,
    String? email,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    final idToken = await user.getIdToken();
    final dio = _dioWithAuth(idToken);
    final response = await dio.post(
      '/payments/feexpay/initcard',
      data: {
        'amount': amount,
        'currency': currency,
        'customId': customId,
        if (description != null) 'description': description,
        if (achatId != null) 'achatId': achatId,
        if (cardHolderName != null) 'cardHolderName': cardHolderName,
        if (email != null) 'email': email,
      },
    );
    return Map<String, dynamic>.from(response.data);
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