import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import 'package:feexpay_flutter/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';

final fpToken = dotenv.env['FP_TOKEN_FEEXPAY'] ?? '';
final idUser = dotenv.env['ID_USER_FEEXPAY'] ?? '';

class SubscriptionPaymentScreen extends StatefulWidget {
  const SubscriptionPaymentScreen({super.key});

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  bool isLoading = false;
  String? errorMessage;
  final String transKey = randomAlphaNumeric(15);

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
          'Abonnement Premium',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec icône premium
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFCC00), Colors.black],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Abonnement Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Boostez votre visibilité auprès des clients',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Avantages de l'abonnement
                    const Text(
                      'Avantages Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildAdvantageItem(
                      Icons.star,
                      'Mise en avant prioritaire',
                      'Apparaissez en premier dans les recherches',
                    ),
                    _buildAdvantageItem(
                      Icons.verified,
                      'Badge Premium',
                      'Badge doré visible sur votre profil',
                    ),
                    _buildAdvantageItem(
                      Icons.trending_up,
                      'Visibilité boostée',
                      'Plus de clients vous contactent',
                    ),
                    _buildAdvantageItem(
                      Icons.support_agent,
                      'Support prioritaire',
                      'Assistance dédiée 24h/7j',
                    ),
                    
                    const SizedBox(height: 24),

                    // Prix
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCC00), width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Abonnement Mensuel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '5 FCFA',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFCC00),
                            ),
                          ),
                          const Text(
                            'par mois',
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
                      'Votre abonnement sera automatiquement renouvelé chaque mois. Vous pouvez l\'annuler à tout moment.',
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
                onPressed: isLoading ? null : _processSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      )
                    : const Text(
                        'Souscrire maintenant - 5 FCFA',
                        style: TextStyle(
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

  Widget _buildAdvantageItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC00).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFCC00),
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

  Future<void> _processSubscription() async {
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

      // Navigation vers FeexPay avec le package officiel
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChoicePage(
            token: fpToken,
            id: idUser,
            amount: '5',
            redirecturl: '/subscription-success',
            errorredirecturl: '/subscription-error', 
            trans_key: transKey,
          ),
        ),
      );

      // Le résultat sera géré par les routes de redirection
      if (result != null) {
        await _activateSubscription();
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abonnement activé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
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

  Future<void> _activateSubscription() async {
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
      final response = await dio.post('/subscription/subscribe', data: {
        'plan': 'monthly',
      });
      print('Abonnement activé: ${response.data}');
    } catch (e) {
      print('Erreur activation abonnement: $e');
      if (e is DioException) {
        print('URL appelée: ${e.requestOptions.uri}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }
}