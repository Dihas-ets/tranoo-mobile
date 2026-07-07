import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/config/backend_config.dart';
import 'package:tranoo/widgets/feexpay_v2_payment_screen.dart';
import 'package:tranoo/l10n/app_localizations.dart';

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
  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
          'status': 'success',
        },
      );
      developer.log(
        '[OrderPayment] payment recorded for dashboard transKey=$transKey',
      );
    } catch (e) {
      developer.log('[OrderPayment] record failed (non blocking): $e');
    }
  }

  Future<void> _startPayment() async {
    setState(() => _isLoading = true);
    try {
      final txKey = 'ORDER_${randomAlphaNumeric(15)}';
      _transKey = txKey;
      developer.log(
        '[OrderPayment] opening FeexPay v2 trans_key=$txKey amount=${widget.amount.toStringAsFixed(0)}',
      );

      final result = await openFeexPayV2Payment(
        context,
        amount: widget.amount,
        description: widget.description,
        customId: txKey,
        paymentType: 'achat',
      );

      final paid = result?.success == true;
      final transactionRef = result?.transactionId ?? txKey;
      developer.log(
        '[OrderPayment] v2 result paid=$paid transactionRef=$transactionRef',
      );

      if (paid) {
        await _recordPayment(success: true);
      }
      if (!mounted) return;
      Navigator.pop(context, {
        'paid': paid,
        'transactionRef': transactionRef,
      });
    } catch (e) {
      developer.log('[OrderPayment] payment error=$e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorPayment(e.toString()))),
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
        title: Text(l10n.mobileMoneyPayment),
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Préparation du paiement...'),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
