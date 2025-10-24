import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:tranoo/services/user_service.dart';
import 'package:feexpay_flutter/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';
import 'package:tranoo/data/screens/succes6.dart';
import 'package:tranoo/data/screens/payment_success.dart';
import 'package:tranoo/data/screens/payment_error.dart';

final fpToken = dotenv.env['FP_TOKEN_FEEXPAY'] ?? '';
final idUser = dotenv.env['ID_USER_FEEXPAY'] ?? '';

class PaymentScreen extends StatefulWidget {
  final String pubId;
  const PaymentScreen({super.key, required this.pubId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;
  String? errorMessage;
  final String transKey = randomAlphaNumeric(15);
  Map<String, dynamic>? pubData;
  String? _selectedPaymentMethod;

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

  Widget _buildPaymentMethodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Moyen de paiement',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPaymentMethod,
                hint: const Text('À sélectionner'),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Paiement bancaire',
                    child: Text('Paiement bancaire'),
                  ),
                  DropdownMenuItem(
                    value: 'Mobile Money',
                    child: Text('Mobile Money'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Paiement publicité',
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
                                    pubData!['typePub'] ?? 'Publicité',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    pubData!['description'] ??
                                        'Publicité pour votre article',
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
                            const Text(
                              'Détails de votre publicité',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildDetailItem(
                              Icons.star,
                              'Type',
                              pubData!['typePub'] ?? 'N/A',
                            ),
                            _buildDetailItem(
                              Icons.schedule,
                              'Durée',
                              pubData!['duree'] ?? 'N/A',
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
                                  const Text(
                                    'Montant à payer',
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
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const Text(
                                    'pour la durée sélectionnée',
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
                            const Text(
                              'Après paiement, votre publicité sera soumise à validation admin avant publication.',
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
                                  'Payer ${pubData!['prix'] ?? 0} FCFA',
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
        throw Exception('Utilisateur non connecté');
      }

      if (fpToken.isEmpty || idUser.isEmpty) {
        throw Exception('Configuration FeexPay manquante');
      }

      final amount = pubData!['prix']?.toString() ?? '0';

      // Navigation vers FeexPay avec le package officiel
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChoicePage(
                token: fpToken,
                id: idUser,
                amount: amount,
                redirecturl: '/payment-success',
                errorredirecturl: '/payment-error',
                trans_key: transKey,
              ),
        ),
      );

      // Le résultat sera géré par les routes de redirection
      if (result != null) {
        // Mettre à jour le statut en arrière-plan
        await _updatePubStatus();

        // Naviguer vers la page de succès
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PaymentSuccessPage()),
            (route) => false,
          );
        }
      } else {
        // Paiement échoué ou annulé
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PaymentErrorPage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      log('Erreur paiement: $e');
      // En cas d'erreur, rediriger vers la page d'erreur
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PaymentErrorPage()),
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
      }
    } catch (e) {
      log('Erreur mise à jour statut: $e');
    }
  }
}
