import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:feexpay_flutter/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/config/backend_config.dart';
import 'package:tranoo/utils/feexpay_callback_state.dart';

class OrderPaymentScreen extends StatefulWidget {
  final double amount;
  final String description;

  const OrderPaymentScreen({
    super.key,
    required this.amount,
    required this.description,
  });

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  bool _looksLikeFeexPayId(String value) {
    final v = value.trim();
    final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    if (uuid.hasMatch(v)) return true;
    // Some providers can return numeric references
    final numericRef = RegExp(r'^\d{10,}$');
    return numericRef.hasMatch(v);
  }

  bool _isLoading = false;
  String? _transKey;

  Future<void> _recordPayment({required bool success}) async {
    if (!success) {
      developer.log(
        '[OrderPayment] skip failed record to avoid false-negative overwrite',
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    final transKey = _transKey;
    if (user == null || transKey == null || transKey.isEmpty) {
      developer.log('[OrderPayment] skip record: missing user or transKey');
      return;
    }
    try {
      final token = await user.getIdToken();
      await Dio().post(
        '${getApiBaseUrl()}/payments/feexpay/flutter/record',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'transKey': transKey,
          'amount': widget.amount,
          'description': widget.description,
          'type': 'achat',
          'status': success ? 'success' : 'failed',
        },
      );
      developer.log(
        '[OrderPayment] payment recorded for dashboard transKey=$transKey status=${success ? 'success' : 'failed'}',
      );
    } catch (e) {
      developer.log('[OrderPayment] record failed (non blocking): $e');
    }
  }

  bool _statusToSuccess(String status) {
    final s = status.toLowerCase().trim();
    if (s.isEmpty) return false;
    if (s.contains('fail') ||
        s.contains('error') ||
        s.contains('cancel') ||
        s.contains('annul') ||
        s.contains('declin') ||
        s.contains('expired')) {
      return false;
    }
    if (s.contains('success') ||
        s.contains('successful') ||
        s.contains('paid') ||
        s.contains('ok') ||
        s.contains('completed') ||
        s.contains('approved')) {
      return true;
    }
    return false;
  }

  bool _isFeexPaySuccess(dynamic result) {
    if (result == null) return false;
    if (result is bool) return result;
    if (result is Map) {
      final successHint = result['successHint'];
      if (successHint is bool) {
        return successHint;
      }
      final status = (result['status'] ??
              result['state'] ??
              result['result'] ??
              result['paymentStatus'] ??
              '')
          .toString()
          .toLowerCase();
      final successFlag = result['success'];
      if (successFlag is bool) return successFlag;
      return _statusToSuccess(status);
    }
    // Certains SDK renvoient un JSON en string.
    if (result is String) {
      try {
        final parsed = result.trim();
        if (parsed.startsWith('{') && parsed.endsWith('}')) {
          final map = Map<String, dynamic>.from(
            (parsed.isNotEmpty ? (jsonDecode(parsed) as Map) : const {}),
          );
          return _isFeexPaySuccess(map);
        }
        if (_looksLikeFeexPayId(parsed)) {
          // FeexPay may return transaction UUID directly on success callback.
          return true;
        }
      } catch (_) {}
    }
    final payload = result.toString().toLowerCase();
    if (payload == 'true') {
      return true;
    }
    return _statusToSuccess(payload);
  }

  String? _extractTransactionRef(dynamic result) {
    if (result is Map) {
      final candidates = [
        result['id_transaction'],
        result['transactionId'],
        result['transaction_id'],
        result['reference'],
        result['id'],
        result['trans_key'],
        result['callbackArgs'],
      ];
      for (final c in candidates) {
        final v = c?.toString().trim();
        if (v != null && v.isNotEmpty) {
          // Try to extract UUID embedded in callback args first.
          final uuidReg = RegExp(
            r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}',
          );
          final match = uuidReg.firstMatch(v);
          if (match != null) return match.group(0);
          return v;
        }
      }
    }
    if (result is String) {
      try {
        final parsed = result.trim();
        if (parsed.startsWith('{') && parsed.endsWith('}')) {
          final map = Map<String, dynamic>.from(jsonDecode(parsed) as Map);
          return _extractTransactionRef(map);
        }
        if (_looksLikeFeexPayId(parsed)) {
          return parsed;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<bool> _verifyPaymentWithBackend(String transactionRef) async {
    try {
      final response = await Dio().get(
        '${getApiBaseUrl()}/payments/feexpay/public/status/$transactionRef',
      );
      developer.log('[OrderPayment] backend verify raw response=${response.data}');
      final status = (response.data['status'] ?? '').toString().toLowerCase();
      final verified = _statusToSuccess(status);
      developer.log(
        '[OrderPayment] backend verify ref=$transactionRef status=$status verified=$verified',
      );
      return verified;
    } catch (e) {
      developer.log('[OrderPayment] backend verify failed ref=$transactionRef err=$e');
      return false;
    }
  }

  Future<void> _startPayment() async {
    setState(() => _isLoading = true);
    try {
      // Compat: anciennes + nouvelles clés .env
      final token = (dotenv.env['FP_TOKEN_FEEXPAY'] ?? '').trim().isNotEmpty
          ? (dotenv.env['FP_TOKEN_FEEXPAY'] ?? '').trim()
          : (dotenv.env['FEEXPAY_API_TOKEN'] ?? '').trim();
      final idUser = (dotenv.env['ID_USER_FEEXPAY'] ?? '').trim().isNotEmpty
          ? (dotenv.env['ID_USER_FEEXPAY'] ?? '').trim()
          : (dotenv.env['FEEXPAY_SHOP_ID'] ?? '').trim();

      developer.log(
        '[OrderPayment] init payment amount=${widget.amount.toStringAsFixed(0)} '
        'desc="${widget.description}" '
        'tokenSet=${token.isNotEmpty} idUserSet=${idUser.isNotEmpty}',
      );
      if (token.isEmpty || idUser.isEmpty) {
        developer.log(
          '[OrderPayment] Missing FeexPay config '
          '(FP_TOKEN_FEEXPAY/FEEXPAY_API_TOKEN or '
          'ID_USER_FEEXPAY/FEEXPAY_SHOP_ID)',
        );
        throw Exception(
          'Configuration FeexPay manquante: '
          'FP_TOKEN_FEEXPAY|FEEXPAY_API_TOKEN et '
          'ID_USER_FEEXPAY|FEEXPAY_SHOP_ID',
        );
      }

      final txKey = 'ORDER_${randomAlphaNumeric(15)}';
      _transKey = txKey;
      developer.log('[OrderPayment] opening ChoicePage trans_key=$txKey');
      FeexPayCallbackState.clearPendingAtNewCheckout();
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChoicePage(
            token: token,
            id: idUser,
            amount: widget.amount.toStringAsFixed(0),
            redirecturl: '/cart-payment-success',
            errorredirecturl: '/cart-payment-error',
            trans_key: txKey,
          ),
        ),
      );

      // Keep a plain print to make sure we see it in noisy logcat.
      print('[OrderPayment] result runtimeType=${result.runtimeType} raw=$result');
      final callbackPayload = FeexPayCallbackState.takeLatest();
      final localPaid = _isFeexPaySuccess(result);
      final transactionRef = _extractTransactionRef(result) ??
          callbackPayload.transactionId ??
          txKey;
      bool paid = localPaid;
      if (callbackPayload.success == true) {
        paid = true;
      }
      final callbackSuccessHint =
          result is Map ? (result['successHint'] == true) : null;
      if (callbackSuccessHint == true) {
        paid = true;
      }
      final canVerifyRemotely = _looksLikeFeexPayId(transactionRef);
      if (canVerifyRemotely) {
        final verified = await _verifyPaymentWithBackend(transactionRef);
        // Si vérification backend réussit, c'est la source de vérité.
        if (verified || !localPaid) {
          paid = verified;
        }
      }
      print(
        '[OrderPayment] decision localPaid=$localPaid callbackState=${callbackPayload.success} callbackHint=$callbackSuccessHint canVerifyRemotely=$canVerifyRemotely transactionRef=$transactionRef finalPaid=$paid',
      );
      await _recordPayment(success: paid);
      if (!mounted) return;
      Navigator.pop(context, {
        'paid': paid,
        'transactionRef': transactionRef,
      });
    } catch (e) {
      developer.log('[OrderPayment] payment error=$e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de paiement: $e')),
      );
      Navigator.pop(context, false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement commande'),
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Préparation du paiement...'),
      ),
    );
  }
}

