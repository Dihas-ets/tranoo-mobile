import 'package:tranoo/services/payment_api.dart';
import 'package:tranoo/utils/feexpay_error_messages.dart';
import 'package:tranoo/utils/payment_debug_logger.dart';
import 'package:tranoo/widgets/feexpay_v2_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class FeexPayV2PaymentResult {
  final bool success;
  final String customId;
  final String? transactionId;
  final String? paymentId;
  final String? errorMessage;
  final bool cancelled;

  const FeexPayV2PaymentResult({
    required this.success,
    required this.customId,
    this.transactionId,
    this.paymentId,
    this.errorMessage,
    this.cancelled = false,
  });
}

class FeexPayV2PaymentService {
  static const _pollInterval = Duration(seconds: 3);
  static const _maxAttempts = 40;

  static int _sessionSeq = 0;
  static int? _activeSessionId;

  /// Démarre une session ; invalide toute session de polling encore en cours.
  static int beginPaymentSession() {
    _activeSessionId = ++_sessionSeq;
    return _activeSessionId!;
  }

  static void cancelPaymentSession([int? sessionId]) {
    if (sessionId == null || sessionId == _activeSessionId) {
      _activeSessionId = null;
    }
  }

  static bool _isSessionActive(int sessionId) =>
      _activeSessionId != null && _activeSessionId == sessionId;

  static String normalizePhone(String raw, FeexPayCountry country) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    final dial = country.dialCode;

    if (digits.startsWith(dial)) return digits;

    if (country.code == 'BJ') {
      if (digits.length == 8) digits = '01$digits';
      if (digits.length == 10 && digits.startsWith('01')) return '$dial$digits';
      if (digits.length == 13 && digits.startsWith('${dial}01')) return digits;
    }

    return '$dial$digits';
  }

  /// Rétrocompatibilité Bénin.
  static String normalizeBeninPhone(String raw) =>
      normalizePhone(raw, feexPayCountryByCode('BJ'));

  static String? validatePhoneForNetwork(
    String network,
    String raw, {
    FeexPayCountry? country,
  }) {
    final c = country ?? feexPayCountryByCode('BJ');
    final normalized = normalizePhone(raw, c);

    if (c.code == 'BJ') {
      if (!RegExp(r'^22901\d{8}$').hasMatch(normalized)) {
        return 'Format Bénin : 01 + 8 chiffres (ex : 0166000000).';
      }
      return null;
    }

    if (normalized.length < c.dialCode.length + 8) {
      return 'Numéro trop court pour ${c.name}.';
    }
    if (!normalized.startsWith(c.dialCode)) {
      return 'Le numéro doit inclure l\'indicatif ${c.dialCode}.';
    }
    return null;
  }

  static bool statusIndicatesSuccess(String status) {
    final s = status.toLowerCase().trim();
    if (s.isEmpty) return false;
    if (_statusIndicatesFailure(s)) return false;
    return s.contains('success') ||
        s.contains('successful') ||
        s.contains('paid') ||
        s.contains('completed') ||
        s.contains('approved') ||
        s == 'ok';
  }

  static bool statusIndicatesFailure(String status) {
    return _statusIndicatesFailure(status.toLowerCase().trim());
  }

  static bool _statusIndicatesFailure(String s) {
    if (s.isEmpty) return false;
    return s.contains('fail') ||
        s.contains('error') ||
        s.contains('cancel') ||
        s.contains('annul') ||
        s.contains('declin') ||
        s.contains('rejected') ||
        s.contains('expired');
  }

  static String? _extractTransactionId(Map<String, dynamic> init) {
    final direct = init['transactionId']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final raw = init['raw'];
    if (raw is Map) {
      for (final key in [
        'reference',
        'id',
        'transref',
        'transRef',
        'order_id',
      ]) {
        final v = raw[key]?.toString().trim();
        if (v != null && v.isNotEmpty) return v;
      }
    }
    return null;
  }

  static String? _extractPaymentUrl(Map<String, dynamic> init) {
    final direct = init['paymentUrl']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final raw = init['raw'];
    if (raw is Map) {
      for (final key in ['url', 'payment_url', 'paymentUrl']) {
        final v = raw[key]?.toString().trim();
        if (v != null && v.isNotEmpty) return v;
      }
    }
    return null;
  }

  /// Coris étape 1 — envoi du code OTP par SMS (doc FeexPay v2).
  static Future<void> sendCorisOtp({
    required double amount,
    required String phoneNumber,
    required String description,
    required String customId,
    String paymentType = 'achat',
    String? duree,
    String? publiciteId,
    String? achatId,
  }) async {
    await PaymentApi.initRequestToPay(
      network: 'coris',
      amount: amount,
      customId: customId,
      phoneNumber: phoneNumber,
      description: description,
      type: paymentType,
      duree: duree,
      publiciteId: publiciteId,
      achatId: achatId,
      otp: '',
    );
  }

  static Future<FeexPayV2PaymentResult> _pollUntilSettled({
    required int session,
    required String localCustomId,
    required String transactionId,
    String? paymentId,
  }) async {
    FeexPayV2PaymentResult cancelledResult() => FeexPayV2PaymentResult(
          success: false,
          customId: localCustomId,
          cancelled: true,
          errorMessage: 'Paiement annulé.',
        );

    Map<String, dynamic>? lastStatusData;
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      if (!_isSessionActive(session)) return cancelledResult();

      await Future.delayed(_pollInterval);
      if (!_isSessionActive(session)) return cancelledResult();

      final statusData = await PaymentApi.getFeexPublicStatus(
        transactionId,
        paymentId: paymentId,
      );
      lastStatusData = statusData;
      final status = (statusData['status'] ?? '').toString();
      final raw = statusData['raw'];
      final operatorId = raw is Map ? raw['operator_id']?.toString() : null;
      final responsemsg = raw is Map ? raw['responsemsg']?.toString() : null;
      PaymentDebugLogger.step('FEEXPAY_V2', 'Poll #$attempt', {
        'status': status,
        'transactionId': transactionId,
        'session': session,
        'operator_id': operatorId ?? '',
        'responsemsg': responsemsg ?? '',
      });

      if (statusIndicatesSuccess(status)) {
        return FeexPayV2PaymentResult(
          success: true,
          customId: localCustomId,
          transactionId:
              statusData['id_transaction']?.toString() ?? transactionId,
          paymentId: paymentId,
        );
      }
        if (statusIndicatesFailure(status)) {
          final detail = FeexPayErrorMessages.fromPollStatus(statusData);
          return FeexPayV2PaymentResult(
            success: false,
            customId: localCustomId,
            transactionId: transactionId,
            paymentId: paymentId,
            errorMessage: detail.isNotEmpty
                ? detail
                : 'Paiement refusé ou annulé.',
          );
        }
    }

    return FeexPayV2PaymentResult(
      success: false,
      customId: localCustomId,
      transactionId: transactionId,
      paymentId: paymentId,
      errorMessage: lastStatusData != null
          ? FeexPayErrorMessages.pendingDiagnosis(lastStatusData)
          : 'Délai dépassé. Si vous avez validé sur votre téléphone, réessayez.',
    );
  }

  static Future<FeexPayV2PaymentResult> payWithMobileMoney({
    required String network,
    required double amount,
    required String phoneNumber,
    required String description,
    String? customId,
    String paymentType = 'achat',
    String? duree,
    String? publiciteId,
    String? achatId,
    String? otp,
    int? sessionId,
  }) async {
    final localCustomId =
        customId ?? 'TX_${DateTime.now().millisecondsSinceEpoch}';
    final session = sessionId ?? beginPaymentSession();

    FeexPayV2PaymentResult cancelledResult() => FeexPayV2PaymentResult(
          success: false,
          customId: localCustomId,
          cancelled: true,
          errorMessage: 'Paiement annulé.',
        );

    try {
      PaymentDebugLogger.step('FEEXPAY_V2', 'initRequestToPay', {
        'network': network,
        'amount': amount,
        'customId': localCustomId,
        'paymentType': paymentType,
        'session': session,
      });

      final init = await PaymentApi.initRequestToPay(
        network: network,
        amount: amount,
        customId: localCustomId,
        phoneNumber: phoneNumber,
        description: description,
        type: paymentType,
        duree: duree,
        publiciteId: publiciteId,
        achatId: achatId,
        otp: otp,
      );

      if (!_isSessionActive(session)) return cancelledResult();

      final paymentId = init['paymentId']?.toString();
      final transactionId = _extractTransactionId(init);
      final paymentUrl = _extractPaymentUrl(init);

      if (transactionId == null || transactionId.isEmpty) {
        return FeexPayV2PaymentResult(
          success: false,
          customId: localCustomId,
          paymentId: paymentId,
          errorMessage: 'Réponse FeexPay sans identifiant de transaction.',
        );
      }

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        final uri = Uri.parse(paymentUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          return FeexPayV2PaymentResult(
            success: false,
            customId: localCustomId,
            paymentId: paymentId,
            errorMessage: 'Impossible d\'ouvrir la page de paiement.',
          );
        }
      }

      PaymentDebugLogger.step('FEEXPAY_V2', 'Polling statut', {
        'transactionId': transactionId,
        'paymentId': paymentId,
        'session': session,
      });

      return _pollUntilSettled(
        session: session,
        localCustomId: localCustomId,
        transactionId: transactionId,
        paymentId: paymentId,
      );
    } catch (e) {
      if (!_isSessionActive(session)) return cancelledResult();
      PaymentDebugLogger.blocked('FEEXPAY_V2', 'Exception paiement mobile', e);
      final msg = FeexPayErrorMessages.fromApiPayload(
        e is Exception ? e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '') : e,
      );
      return FeexPayV2PaymentResult(
        success: false,
        customId: localCustomId,
        errorMessage: msg,
      );
    }
  }

  /// Carte bancaire — initcard FeexPay v2 puis ouverture de la page de paiement.
  static Future<FeexPayV2PaymentResult> payWithCard({
    required double amount,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String typeCard,
    required String description,
    String? customId,
    String paymentType = 'achat',
    String? duree,
    String? publiciteId,
    String? achatId,
    int? sessionId,
  }) async {
    final localCustomId =
        customId ?? 'TX_${DateTime.now().millisecondsSinceEpoch}';
    final session = sessionId ?? beginPaymentSession();

    FeexPayV2PaymentResult cancelledResult() => FeexPayV2PaymentResult(
          success: false,
          customId: localCustomId,
          cancelled: true,
          errorMessage: 'Paiement annulé.',
        );

    if (amount < FeexPayV2Constants.minCardAmount) {
      return FeexPayV2PaymentResult(
        success: false,
        customId: localCustomId,
        errorMessage:
            'Montant minimum carte : ${FeexPayV2Constants.minCardAmount.toStringAsFixed(0)} FCFA.',
      );
    }

    try {
      final init = await PaymentApi.initCardPayment(
        amount: amount,
        customId: localCustomId,
        phone: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
        typeCard: typeCard,
        description: description,
        type: paymentType,
        duree: duree,
        publiciteId: publiciteId,
        achatId: achatId,
      );

      if (!_isSessionActive(session)) return cancelledResult();

      final paymentId = init['paymentId']?.toString();
      final transactionId = _extractTransactionId(init);
      final paymentUrl = _extractPaymentUrl(init);

      if (paymentUrl == null || paymentUrl.isEmpty) {
        return FeexPayV2PaymentResult(
          success: false,
          customId: localCustomId,
          paymentId: paymentId,
          errorMessage: 'Page de paiement carte indisponible. Réessayez.',
        );
      }

      final uri = Uri.parse(paymentUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return FeexPayV2PaymentResult(
          success: false,
          customId: localCustomId,
          paymentId: paymentId,
          errorMessage: 'Impossible d\'ouvrir la page de paiement.',
        );
      }

      if (transactionId == null || transactionId.isEmpty) {
        return FeexPayV2PaymentResult(
          success: false,
          customId: localCustomId,
          paymentId: paymentId,
          errorMessage: 'Transaction carte non initialisée.',
        );
      }

      return _pollUntilSettled(
        session: session,
        localCustomId: localCustomId,
        transactionId: transactionId,
        paymentId: paymentId,
      );
    } catch (e) {
      if (!_isSessionActive(session)) return cancelledResult();
      PaymentDebugLogger.blocked('FEEXPAY_V2', 'Exception paiement carte', e);
      final msg = FeexPayErrorMessages.fromApiPayload(
        e is Exception ? e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '') : e,
      );
      return FeexPayV2PaymentResult(
        success: false,
        customId: localCustomId,
        errorMessage: msg,
      );
    }
  }
}
