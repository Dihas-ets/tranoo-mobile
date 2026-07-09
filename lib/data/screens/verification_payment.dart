import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'avant_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart' show UserService;
import 'package:random_string/random_string.dart';
import 'package:tranoo/utils/payment_debug_logger.dart';
import 'package:tranoo/widgets/feexpay_v2_payment_screen.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class VerificationPaymentScreen extends StatefulWidget {
  final String? articleId; // Optionnel: pour lier le paiement à un article
  const VerificationPaymentScreen({super.key, this.articleId});

  @override
  State<VerificationPaymentScreen> createState() =>
      _VerificationPaymentScreenState();
}

class _VerificationPaymentScreenState extends State<VerificationPaymentScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool isLoading = false;
  String? errorMessage;
  late final String transKey;
  int _verificationPrice = 20000;

  String _formatFcfa(int value) {
    final priceStr = value.toString();
    final reversed = priceStr.split('').reversed.join('');
    final withDots = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (Match m) => '${m[0]}.',
    );
    return withDots.split('').reversed.join('');
  }

  Future<void> _loadVerificationPrice() async {
    try {
      final url =
          '${UserService().dio.options.baseUrl}/admin/verification-pricing';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = data['prixVerification'] ??
            (data['pricing'] is Map
                ? data['pricing']['prixVerification']
                : null);
        final parsed = int.tryParse('$raw');
        if (parsed != null && parsed >= 0 && mounted) {
          setState(() => _verificationPrice = parsed);
        }
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _loadVerificationPrice();
    // Trans key encodant l'articleId si fourni pour usage côté web (paiements-details)
    // Format attendu côté web: VERIFICATION_<ObjectId>_...
    if ((widget.articleId ?? '').isNotEmpty) {
      transKey =
          'VERIFICATION_${widget.articleId!}_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      transKey = randomAlphaNumeric(15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.verificationFeesTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône vérification
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A86B), Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.documentVerification,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.verifyDocumentsAuthenticity,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Avantages de la vérification
              Text(
                l10n.includedServices,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildAdvantageItem(
                Icons.security,
                l10n.fullVerification,
                l10n.fullVerificationDesc,
              ),
              _buildAdvantageItem(
                Icons.schedule,
                l10n.fastProcessing,
                l10n.fastProcessingDesc,
              ),

              const SizedBox(height: 24),

              // Prix
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00A86B), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.verificationFeesTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatFcfa(_verificationPrice)} FCFA',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A86B),
                      ),
                    ),
                    Text(
                      l10n.oneTimePayment,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Note
              Text(
                l10n.verificationPaymentNote,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Bouton de paiement (un peu plus haut et scrollable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _processVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          l10n.proceedToPayment(
                              _formatFcfa(_verificationPrice)),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvantageItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00A86B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00A86B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processVerification() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(l10n.userNotLoggedIn);
      }

      final result = await openFeexPayV2Payment(
        context,
        amount: _verificationPrice.toDouble(),
        description: 'Frais vérification documents',
        customId: transKey,
        paymentType: 'verification',
      );

      if (!mounted) return;

      if (result == null || !result.success) {
        PaymentDebugLogger.blocked(
          'VERIFICATION_PAYMENT',
          'Paiement vérification non confirmé',
          result?.errorMessage,
        );
        setState(() {
          errorMessage =
              result?.errorMessage ?? l10n.paymentCancelledNotConfirmed;
        });
        return;
      }

      // Enregistre le paiement côté backend (dashboard + historique)
      try {
        await _recordVerificationFeexPayFlutter(result.transactionId);
      } catch (e) {
        debugPrint('[VerificationPayment] record (non bloquant): $e');
      }

      try {
        await _processVerificationRequest();
      } catch (e) {
        debugPrint('[VerificationPayment] verification/request: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.paymentSuccessful),
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AvantHome()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('[VerificationPayment] erreur flux: $e');
      if (mounted) {
        setState(() {
          errorMessage = l10n.errorGeneric(e.toString());
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _processVerificationRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    final dio = Dio(
      BaseOptions(
        baseUrl: UserService().dio.options.baseUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    try {
      final response = await dio.post('/verification/request', data: {
        'type': 'document_verification',
        'amount': _verificationPrice,
        if ((widget.articleId ?? '').isNotEmpty) 'articleId': widget.articleId,
        'transKey': transKey, // utile pour traçabilité
      });
      print('Demande de vérification créée: ${response.data}');
    } catch (e) {
      print('Erreur création demande: $e');
      if (e is DioException) {
        print('URL appelée: ${e.requestOptions.uri}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<void> _recordVerificationFeexPayFlutter(String? txId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: UserService().dio.options.baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final body = <String, dynamic>{
        'transKey': transKey,
        'amount': _verificationPrice,
        'description': 'Frais vérification documents',
        'type': 'verification',
        'status': 'success',
      };
      final tid = txId?.trim();
      if (tid != null && tid.isNotEmpty) {
        body['id_transaction'] = tid;
        body['ref'] = tid;
        body['reference'] = tid;
      }
      await dio.post('/payments/feexpay/flutter/record', data: body);
    } catch (e) {
      debugPrint('[VerificationPayment] recordFeexPayFlutter error: $e');
    }
  }
}
