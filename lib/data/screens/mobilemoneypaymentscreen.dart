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
import 'package:tranoo/utils/feexpay_result_utils.dart';
import 'package:tranoo/utils/feexpay_callback_state.dart';

final fpToken = dotenv.env['FP_TOKEN_FEEXPAY'] ?? '';
final idUser = dotenv.env['ID_USER_FEEXPAY'] ?? '';

class MobileMoneyPaymentScreen extends StatefulWidget {
  final String pubId;
  const MobileMoneyPaymentScreen({super.key, required this.pubId});

  @override
  State<MobileMoneyPaymentScreen> createState() => _MobileMoneyPaymentScreenState();
}

class _MobileMoneyPaymentScreenState extends State<MobileMoneyPaymentScreen> {
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
          'Paiement Mobile Money',
          style: TextStyle(
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
                                const Text(
                                  'Paiement Mobile Money',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pubData!['description'] ?? 'Publicité pour votre article',
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
                          _buildDetailItem(
                            Icons.payment,
                            'Moyen de paiement',
                            'Mobile Money',
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
                                    color: Color(0xFF00A86B),
                                  ),
                                ),
                                const Text(
                                  'via Mobile Money',
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
                          const Text(
                            'Opérateurs supportés',
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
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      if (fpToken.isEmpty || idUser.isEmpty) {
        throw Exception('Configuration FeexPay manquante');
      }

      final amount = pubData!['prix']?.toString() ?? '0';

      FeexPayCallbackState.clearPendingAtNewCheckout();
      // Navigation vers FeexPay avec le package officiel
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChoicePage(
            token: fpToken,
            id: idUser,
            amount: amount,
            redirecturl: '/payment-success',
            errorredirecturl: '/payment-error',
            trans_key: transKey,
          ),
        ),
      );

      final cb = FeexPayCallbackState.takeLatest();
      final callbackHint = result is Map && result['successHint'] == true;
      String? txId = extractFeexPayTransactionId(result) ?? cb.transactionId;
      var success = feexPayReturnIndicatesSuccess(result) ||
          cb.success == true ||
          callbackHint;
      if (txId != null && txId.isNotEmpty) {
        try {
          final st = await http.get(
            Uri.parse('${getBaseUrl()}/payments/feexpay/public/status/$txId'),
          );
          if (st.statusCode == 200) {
            final body = jsonDecode(st.body) as Map<String, dynamic>;
            final s = (body['status'] ?? '').toString().toLowerCase();
            success = success ||
                s.contains('success') ||
                s.contains('successful') ||
                s.contains('paid') ||
                s.contains('ok') ||
                s.contains('completed') ||
                s.contains('approved');
          }
        } catch (e) {
          log('[MobileMoneyPayment] public/status: $e');
        }
      }

      log(
        '[MobileMoneyPayment] ChoicePage result=$result txId=$txId success=$success transKey=$transKey pubId=${widget.pubId}',
      );

      if (!success) {
        return;
      }

      final amountNum = num.tryParse(amount) ?? 0;
      await _recordPubFeexPay(amountNum, idTransaction: txId);
      await _updatePubStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement réussi ! Mise à jour du statut...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicité payée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
        errorMessage = 'Erreur: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _recordPubFeexPay(num amount, {String? idTransaction}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final payload = <String, dynamic>{
        'transKey': transKey,
        'amount': amount,
        'description': 'Paiement publicité (mobile money) ${widget.pubId}',
        'type': 'publicite',
        'status': 'success',
        'publiciteId': widget.pubId,
      };
      final tid = idTransaction?.trim();
      if (tid != null && tid.isNotEmpty) {
        payload['id_transaction'] = tid;
        payload['ref'] = tid;
        payload['reference'] = tid;
      }
      final res = await http.post(
        Uri.parse('${getBaseUrl()}/payments/feexpay/flutter/record'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(payload),
      );
      log(
        '[MobileMoneyPayment] recordFeexPayFlutter status=${res.statusCode} body=${res.body}',
      );
    } catch (e) {
      log('[MobileMoneyPayment] recordFeexPayFlutter error: $e');
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