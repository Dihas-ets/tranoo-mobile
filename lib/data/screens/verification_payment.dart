import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'marque.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import 'package:feexpay_flutter/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';

final fpToken = dotenv.env['FP_TOKEN_FEEXPAY'] ?? '';
final idUser = dotenv.env['ID_USER_FEEXPAY'] ?? '';
final successUrl = dotenv.env['FEEXPAY_SUCCESS_URL'] ?? '';
final errorUrl = dotenv.env['FEEXPAY_ERROR_URL'] ?? '';

class VerificationPaymentScreen extends StatefulWidget {
  final String? articleId; // Optionnel: pour lier le paiement à un article
  const VerificationPaymentScreen({super.key, this.articleId});

  @override
  State<VerificationPaymentScreen> createState() =>
      _VerificationPaymentScreenState();
}

class _VerificationPaymentScreenState extends State<VerificationPaymentScreen> {
  bool isLoading = false;
  String? errorMessage;
  late final String transKey;

  @override
  void initState() {
    super.initState();
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
          'Frais de vérification',
          style: TextStyle(
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
                    const Text(
                      'Vérification de documents',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vérifiez l\'authenticité de vos documents',
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

              // Avantages de la vérification
              const Text(
                'Services inclus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildAdvantageItem(
                Icons.security,
                'Vérification complète',
                'Contrôle de tous vos documents officiels',
              ),
              _buildAdvantageItem(
                Icons.schedule,
                'Traitement rapide',
                'Résultats sous 10 jours ouvrables',
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
                      'Frais de vérification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '50 FCFA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A86B),
                      ),
                    ),
                    const Text(
                      'paiement unique',
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
                'Après paiement, vous recevrez un récapitulatif et les vérifications seront effectuées sous 10 jours ouvrables.',
                style: TextStyle(
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
                      : const Text(
                          'Procéder au paiement - 50 FCFA',
                          style: TextStyle(
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
            amount: '50', // Montant test 50 FCFA
            redirecturl:
                (successUrl.isNotEmpty ? successUrl : '/verification-success'),
            errorredirecturl:
                (errorUrl.isNotEmpty ? errorUrl : '/verification-error'),
            trans_key: transKey,
          ),
        ),
      );

      // Le résultat sera géré par les routes de redirection
      if (result != null) {
        // Traiter la demande serveur puis afficher HTML succès et rediriger vers Marque
        await _processVerificationRequest();
        if (!mounted) return;
        await _showHtmlResultAndRedirect(success: true);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur: $e';
      });
      // Affichage page d'échec puis redirection
      if (mounted) {
        await _showHtmlResultAndRedirect(success: false);
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
        'amount': 50, // Montant test 50 FCFA
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

  Future<void> _showHtmlResultAndRedirect({required bool success}) async {
    final String assetPath = success
        ? 'assets/html/verification_success.html'
        : 'assets/html/verification_error.html';
    String? htmlContent;
    try {
      htmlContent = await DefaultAssetBundle.of(context).loadString(assetPath);
    } catch (_) {
      htmlContent = null;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ResultHtmlPage(
          success: success,
          htmlContent: htmlContent,
        ),
      ),
    );

    // Redirection finale vers Marque
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Marque()),
      (route) => false,
    );
  }
}

class _ResultHtmlPage extends StatelessWidget {
  final bool success;
  final String? htmlContent;
  const _ResultHtmlPage({required this.success, this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
        title: Text(
          success ? 'Paiement réussi' : 'Paiement échoué',
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: htmlContent != null
              ? SingleChildScrollView(child: Html(data: htmlContent))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(success ? Icons.check_circle : Icons.cancel,
                        size: 72,
                        color: success ? const Color(0xFF00A86B) : Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      success ? 'Paiement réussi' : 'Paiement échoué',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Redirection en cours...',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }
}
