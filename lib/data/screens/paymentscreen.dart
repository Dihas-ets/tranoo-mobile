import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:tranoo/services/user_service.dart';
import 'package:random_string/random_string.dart';
import 'package:tranoo/data/screens/payment_success.dart';
import 'package:tranoo/data/screens/payment_error.dart';
import 'package:tranoo/widgets/feexpay_v2_payment_screen.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  final String pubId;
  const PaymentScreen({super.key, required this.pubId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool isLoading = false;
  String? errorMessage;
  final String transKey = randomAlphaNumeric(15);
  Map<String, dynamic>? pubData;

  @override
  void initState() {
    super.initState();
    _loadPubData();
  }

  Future<void> _loadPubData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/publicites/${widget.pubId}'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          pubData = jsonDecode(response.body);
        });
      }
    } catch (e) {
      log('Erreur chargement pub: $e');
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
          '${l10n.orderPayment} ${l10n.advertisingLabel.toLowerCase()}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body:
          pubData == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête avec icône publicité
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.amber, Colors.orange],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.campaign,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    pubData!['typePub'] ?? l10n.advertisingLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    pubData!['description'] ??
                                        l10n.adForYourListing,
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

                            // Détails de la publicité
                            Text(
                              l10n.adDetailsTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildDetailItem(
                              Icons.star,
                              l10n.typeLabel,
                              pubData!['typePub'] ?? l10n.unknown,
                            ),
                            _buildDetailItem(
                              Icons.schedule,
                              l10n.durationLabel,
                              pubData!['duree'] ?? l10n.unknown,
                            ),

                            const SizedBox(height: 24),

                            // Prix
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    l10n.amountToPay,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.valueAmountFcfa(
                                      '${pubData!['prix'] ?? 0}',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Text(
                                    pubData!['duree'] ?? l10n.unknown,
                                    style: TextStyle(
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
                              l10n.afterPaymentAdValidationNote,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bouton de paiement
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                : Text(
                                  '${l10n.pay} ${l10n.valueAmountFcfa('${pubData!['prix'] ?? 0}')}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),

                    if (errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
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
                ),
              ),
              ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.amber, size: 20),
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
                  value,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(l10n.userNotLoggedIn);
      }

      final amountNum = num.tryParse((pubData!['prix'] ?? 0).toString()) ?? 0;
      if (amountNum <= 0) {
        throw Exception(l10n.invalidAmount);
      }

      final result = await openFeexPayV2Payment(
        context,
        amount: amountNum.toDouble(),
        description: l10n.adPaymentMobileDescription(widget.pubId),
        customId: transKey,
        paymentType: 'publicite',
        publiciteId: widget.pubId,
      );

      if (result == null || !result.success) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentErrorPage(
                cancelled: result == null,
              ),
            ),
            (route) => false,
          );
        }
        return;
      }

      await _updatePubStatus();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessPage()),
          (route) => false,
        );
      }
    } catch (e) {
      log('Erreur paiement: $e');
      // En cas d'erreur, rediriger vers la page d'erreur
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentErrorPage(cancelled: false),
          ),
          (route) => false,
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updatePubStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      final response = await http.patch(
        Uri.parse('${getBaseUrl()}/publicites/${widget.pubId}/statut'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'statut': 'payee'}),
      );

      if (response.statusCode != 200) {
        log(
          'Erreur mise à jour statut: ${response.statusCode} - ${response.body}',
        );
      } else {
        log(
          '[PUB_PAYMENT_APP] updateStatut payee ok pubId=${widget.pubId}',
        );
      }
    } catch (e) {
      log('Erreur mise à jour statut: $e');
    }
  }
}
