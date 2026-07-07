import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:tranoo/services/user_service.dart';
import 'package:random_string/random_string.dart';
import 'package:tranoo/data/screens/succes6.dart';
import 'package:tranoo/utils/payment_debug_logger.dart';
import 'package:tranoo/widgets/feexpay_v2_payment_screen.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class MobileMoneyPaymentScreen extends StatefulWidget {
  final String pubId;
  const MobileMoneyPaymentScreen({super.key, required this.pubId});

  @override
  State<MobileMoneyPaymentScreen> createState() => _MobileMoneyPaymentScreenState();
}

class _MobileMoneyPaymentScreenState extends State<MobileMoneyPaymentScreen> {
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
          l10n.mobileMoneyPayment,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: pubData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête avec icône Mobile Money
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00A86B), Color(0xFF4CAF50)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.phone_android,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.mobileMoneyPayment,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pubData!['description'] ?? l10n.adForYourListing,
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
                            pubData!['typePub'] ?? 'N/A',
                          ),
                          _buildDetailItem(
                            Icons.schedule,
                            l10n.durationLabel,
                            pubData!['duree'] ?? 'N/A',
                          ),
                          _buildDetailItem(
                            Icons.payment,
                            l10n.paymentMethod,
                            l10n.mobileMoney,
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
                                  l10n.amountToPay,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${pubData!['prix'] ?? 0} FCFA',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00A86B),
                                  ),
                                ),
                                Text(
                                  l10n.viaMobileMoney,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Opérateurs supportés
                          Text(
                            l10n.supportedOperators,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildOperatorChip('MTN', Colors.yellow),
                              _buildOperatorChip('Moov', Colors.blue),
                              _buildOperatorChip('Orange', Colors.orange),
                            ],
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
                              l10n.payAmountFcfa('${pubData!['prix'] ?? 0}'),
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
                  value,
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

  Widget _buildOperatorChip(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
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
      final l10n = AppLocalizations.of(context)!;
      if (user == null) {
        throw Exception(l10n.userNotConnected);
      }

      final amountNum = num.tryParse(pubData!['prix']?.toString() ?? '0') ?? 0;
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
        PaymentDebugLogger.blocked(
          'MOBILE_MONEY_PUB',
          'Paiement pub non confirmé',
          result?.errorMessage,
        );
        if (mounted) {
          setState(() {
            errorMessage = result?.errorMessage ?? l10n.paymentFailed;
          });
        }
        return;
      }

      await _updatePubStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentSuccessUpdatingStatus),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adPaidSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccesScreen6()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.errorGeneric('$e');
      });
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
        log('Erreur mise à jour statut: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Erreur mise à jour statut: $e');
    }
  }
}