import 'package:flutter/material.dart';
import 'package:feexpay_flutter/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';
import 'dart:developer' as developer;

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
  bool _isLoading = false;

  bool _isFeexPaySuccess(dynamic result) {
    if (result == null) return false;
    if (result is bool) return result;
    final payload = result.toString().toLowerCase();
    return payload.contains('success') ||
        payload.contains('successful') ||
        payload.contains('paid') ||
        payload.contains('ok');
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
      developer.log('[OrderPayment] opening ChoicePage trans_key=$txKey');
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

      developer.log('[OrderPayment] result=$result');
      if (!mounted) return;
      Navigator.pop(context, _isFeexPaySuccess(result));
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

