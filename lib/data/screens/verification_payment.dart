import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/payment_api.dart';

class VerificationPaymentScreen extends StatefulWidget {
  const VerificationPaymentScreen({super.key});

  @override
  State<VerificationPaymentScreen> createState() =>
      _VerificationPaymentScreenState();
}

class _VerificationPaymentScreenState extends State<VerificationPaymentScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  // String? _lastPaymentId; // non utilisé actuellement

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Frais de vérification'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Nous allons vous rediriger vers notre agrégateur de paiement pour régler les frais de vérification.\n\nAprès paiement, vous recevrez un récapitulatif et les vérifications seront effectuées sous 10 jours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Affichage du montant
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00A86B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00A86B)),
              ),
              child: const Text(
                '10 FCFA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A86B),
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Message de succès
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: Colors.green[800]),
                ),
              ),

            // Message d'erreur
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[800]),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text(
                          'Procéder au paiement',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final customId = 'VERIF_${DateTime.now().millisecondsSinceEpoch}';
      final result = await PaymentApi.initFeexPayPayment(
        amount: 100,
        customId: customId,
        description: 'Frais de vérification de pièce',
        method: 'MOBILE',
      );

      if (result['paymentUrl'] != null) {
        setState(() {
          _isLoading = false;
          _successMessage =
              'Paiement initialisé avec succès! Redirection vers la page de paiement...';
        });

        // Attendre un peu pour que l'utilisateur voie le message
        await Future.delayed(const Duration(seconds: 2));

        final paymentUrl = result['paymentUrl'];
        final paymentId = result['paymentId'];
        if (paymentUrl != null) {
          if (!mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => _PaymentWebView(
                    paymentUrl: paymentUrl,
                    onIntercept: (statusUrl) async {
                      // À la première interception, fermer la WebView et montrer l'UI
                      Navigator.of(context).pop();
                      // Optionnel: vérifier le statut côté backend
                      final res = await PaymentApi.getPaymentStatus(paymentId);
                      final status = (res['status'] ?? '').toString();
                      if (!mounted) return;
                      if (status == 'success') {
                        _showResultSheet(success: true);
                      } else {
                        _showResultSheet(success: false);
                      }
                    },
                  ),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur lors de l\'initialisation du paiement';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  // UI résultat (succès/échec) façon FeexPay, en in‑app
  void _showResultSheet({required bool success}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  success ? const Color(0xFF1DBF73) : const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 56,
                ),
                const SizedBox(height: 12),
                Text(
                  success ? 'Paiement réussi' : 'Paiement échoué',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  success
                      ? 'Votre transaction a été effectuée avec succès.'
                      : 'Une erreur s\'est produite durant la transaction.',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!success)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _processPayment();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    if (success)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1DBF73),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Retourner à l\'app'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pollStatus(String? paymentId) async {
    if (paymentId == null) return;
    // plus de stockage local du paymentId
    // Poll 5 fois, toutes les 3s
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final res = await PaymentApi.getPaymentStatus(paymentId);
        final status = (res['status'] ?? '').toString();
        if (status == 'success') {
          if (!mounted) return;
          setState(() {
            _successMessage = 'Paiement réussi';
          });
          return;
        }
        if (status == 'failed' || status == 'cancelled') {
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Paiement ${status}';
          });
          return;
        }
      } catch (_) {}
    }
  }
}

class _PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final Future<void> Function(String interceptedUrl) onIntercept;
  const _PaymentWebView({required this.paymentUrl, required this.onIntercept});

  @override
  State<_PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<_PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) => setState(() => _isLoading = true),
              onPageFinished: (_) => setState(() => _isLoading = false),
              onNavigationRequest: (request) {
                final url = request.url;
                // Interception des redirections succès/erreur
                if (url.contains('success') ||
                    url.contains('payment-success') ||
                    url.contains('status=success')) {
                  widget.onIntercept(url);
                  return NavigationDecision.prevent;
                }
                if (url.contains('error') ||
                    url.contains('failed') ||
                    url.contains('status=failed') ||
                    url.contains('cancelled')) {
                  widget.onIntercept(url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
