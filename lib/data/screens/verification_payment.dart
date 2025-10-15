// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../../services/payment_api.dart';

// class VerificationPaymentScreen extends StatefulWidget {
//   const VerificationPaymentScreen({super.key});

//   @override
//   State<VerificationPaymentScreen> createState() =>
//       _VerificationPaymentScreenState();
// }

// class _VerificationPaymentScreenState extends State<VerificationPaymentScreen> {
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _successMessage;
//   // String? _lastPaymentId; // non utilisé actuellement

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Frais de vérification'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 12),
//             const Text(
//               'Nous allons vous rediriger vers notre agrégateur de paiement pour régler les frais de vérification.\n\nAprès paiement, vous recevrez un récapitulatif et les vérifications seront effectuées sous 10 jours.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, height: 1.5),
//             ),
//             const SizedBox(height: 24),

//             // Affichage du montant
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF00A86B).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: const Color(0xFF00A86B)),
//               ),
//               child: const Text(
//                 '100 FCFA',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF00A86B),
//                   fontSize: 18,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Message de succès
//             if (_successMessage != null)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.green[100],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green),
//                 ),
//                 child: Text(
//                   _successMessage!,
//                   style: TextStyle(color: Colors.green[800]),
//                 ),
//               ),

//             // Message d'erreur
//             if (_errorMessage != null)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.red[100],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red),
//                 ),
//                 child: Text(
//                   _errorMessage!,
//                   style: TextStyle(color: Colors.red[800]),
//                 ),
//               ),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _processPayment,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFFCC00),
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child:
//                     _isLoading
//                         ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text(
//                           'Procéder au paiement',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _processPayment() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _successMessage = null;
//     });

//     try {
//       final customId = 'VERIF_${DateTime.now().millisecondsSinceEpoch}';
//       final result = await PaymentApi.initFeexPayPayment(
//         amount: 5,
//         customId: customId,
//         description: 'Frais de vérification de pièce',
//         method: 'MOBILE',
//       );

//       if (result['paymentUrl'] != null) {
//         setState(() {
//           _isLoading = false;
//           _successMessage =
//               'Paiement initialisé avec succès! Redirection vers la page de paiement...';
//         });

//         // Attendre un peu pour que l'utilisateur voie le message
//         await Future.delayed(const Duration(seconds: 2));

//         final paymentUrl = result['paymentUrl'];
//         final paymentId = result['paymentId'];
//         if (paymentUrl != null) {
//           if (!mounted) return;
//           await Navigator.of(context).push(
//             MaterialPageRoute(
//               builder:
//                   (_) => _PaymentWebView(
//                     paymentUrl: paymentUrl,
//                     paymentId: paymentId,
//                     onIntercept: (statusUrl) async {
//                       // Gestion des pages de redirection
//                       if (statusUrl == 'success://payment-success') {
//                         if (!mounted) return;
//                         Navigator.of(context).pop();
//                         _showResultSheet(success: true);
//                         return;
//                       }
//                       if (statusUrl == 'error://payment-error') {
//                         if (!mounted) return;
//                         Navigator.of(context).pop();
//                         _showResultSheet(success: false);
//                         return;
//                       }

//                       // Gestion du bouton "Terminer" manuel
//                       if (statusUrl.startsWith('manual://status?')) {
//                         debugPrint(
//                           '[VerificationPayment] Manual status: $statusUrl',
//                         );
//                         final uri = Uri.parse(statusUrl);
//                         final successParam = uri.queryParameters['success'];
//                         bool? success;
//                         if (successParam == 'true') {
//                           success = true;
//                         } else if (successParam == 'false') {
//                           success = false;
//                         } else {
//                           success = null; // Statut inconnu
//                         }
//                         debugPrint(
//                           '[VerificationPayment] Success value: $success',
//                         );
//                         if (!mounted) return;
//                         Navigator.of(context).pop();
//                         debugPrint(
//                           '[VerificationPayment] Showing result sheet...',
//                         );
//                         _showResultSheet(success: success ?? false);
//                         return;
//                       }

//                       // Extraire id_transaction depuis l'URL
//                       String? idTxn;
//                       try {
//                         final uri = Uri.parse(statusUrl);
//                         idTxn =
//                             uri.queryParameters['id_transaction'] ??
//                             uri.queryParameters['id'] ??
//                             uri.queryParameters['transaction_id'];
//                       } catch (_) {}

//                       bool? success;
//                       // Si on a un id_transaction, interroger le statut public
//                       if (idTxn != null && idTxn.isNotEmpty) {
//                         try {
//                           final res = await PaymentApi.getFeexPublicStatus(
//                             idTxn,
//                             paymentId: paymentId,
//                           );
//                           final s =
//                               (res['status'] ?? '').toString().toLowerCase();
//                           success = s == 'success' || s == 'successful';
//                           debugPrint(
//                             '[PaymentWebView] Status from API: $s for ID: $idTxn',
//                           );
//                         } catch (e) {
//                           debugPrint(
//                             '[PaymentWebView] API error for ID $idTxn: $e',
//                           );
//                         }
//                       }

//                       // Afficher le résultat
//                       _showResultSheet(success: success ?? false);
//                     },
//                   ),
//             ),
//           );
//         }
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Erreur lors de l\'initialisation du paiement';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Erreur: $e';
//       });
//     }
//   }

//   // UI résultat (succès/échec) façon FeexPay, en in‑app
//   void _showResultSheet({required bool success, String? message}) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (_) {
//         return Center(
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.8,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color:
//                   success ? const Color(0xFF1DBF73) : const Color(0xFFE53935),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 12,
//                   offset: Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   success ? Icons.check_circle : Icons.cancel,
//                   color: Colors.white,
//                   size: 56,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   success ? 'Paiement réussi' : 'Paiement échoué',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   message ??
//                       (success
//                           ? 'Votre transaction a été effectuée avec succès.'
//                           : 'Une erreur s\'est produite durant la transaction.'),
//                   style: const TextStyle(color: Colors.white70, fontSize: 14),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (!success)
//                       ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: const Color(0xFFE53935),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           _processPayment();
//                         },
//                         icon: const Icon(Icons.refresh),
//                         label: const Text('Réessayer'),
//                       ),
//                     if (success)
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: const Color(0xFF1DBF73),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                         ),
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('Retourner à l\'app'),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _pollStatus(String? paymentId) async {
//     if (paymentId == null) return;
//     // plus de stockage local du paymentId
//     // Poll 5 fois, toutes les 3s
//     for (int i = 0; i < 5; i++) {
//       await Future.delayed(const Duration(seconds: 3));
//       try {
//         final res = await PaymentApi.getPaymentStatus(paymentId);
//         final status = (res['status'] ?? '').toString();
//         if (status == 'success') {
//           if (!mounted) return;
//           setState(() {
//             _successMessage = 'Paiement réussi';
//           });
//           return;
//         }
//         if (status == 'failed' || status == 'cancelled') {
//           if (!mounted) return;
//           setState(() {
//             _errorMessage = 'Paiement ${status}';
//           });
//           return;
//         }
//       } catch (_) {}
//     }
//   }
// }

// class _PaymentWebView extends StatefulWidget {
//   final String paymentUrl;
//   final Future<void> Function(String interceptedUrl) onIntercept;
//   final String paymentId;
//   const _PaymentWebView({
//     required this.paymentUrl,
//     required this.onIntercept,
//     required this.paymentId,
//   });

//   @override
//   State<_PaymentWebView> createState() => _PaymentWebViewState();
// }

// class _PaymentWebViewState extends State<_PaymentWebView> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   bool _overlayShown = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..addJavaScriptChannel(
//             'TranooBridge',
//             onMessageReceived: (JavaScriptMessage message) async {
//               final msg =
//                   message.message; // format: id_transaction=...;status=...
//               debugPrint('[PaymentWebView][JS] $msg');

//               final idMatch = RegExp(r'id_transaction=([^;]+)').firstMatch(msg);
//               final statusMatch = RegExp(r'status=([^;]+)').firstMatch(msg);
//               final id = (idMatch?.group(1) ?? '').trim();
//               final status = (statusMatch?.group(1) ?? '').trim();

//               // Valider UUID
//               final isUuid = RegExp(
//                 r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
//               ).hasMatch(id);

//               if (isUuid && status.isNotEmpty) {
//                 final interceptUrl = 'feexpay://result?id_transaction=$id&status=$status';
//                 await widget.onIntercept(interceptUrl);
//               }
//             },
//           )
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onPageStarted: (String url) {
//                 setState(() {
//                   _isLoading = true;
//                 });
//               },
//               onPageFinished: (String url) async {
//                 setState(() {
//                   _isLoading = false;
//                 });

//                 // Injection du script pour capturer les données FeexPay
//                 await _controller.runJavaScript('''
//                   (function() {
//                     function extractAndSend() {
//                       var idElement = document.querySelector('[data-id-transaction], #id_transaction, .id_transaction');
//                       var statusElement = document.querySelector('[data-status], #status, .status');
                      
//                       var id = idElement ? idElement.textContent || idElement.value || idElement.getAttribute('data-id-transaction') : '';
//                       var status = statusElement ? statusElement.textContent || statusElement.value || statusElement.getAttribute('data-status') : '';
                      
//                       if (!id || !status) {
//                         var allText = document.body.innerText || '';
//                         var idMatch = allText.match(/id[_-]?transaction[:\s]*([a-f0-9-]{36})/i);
//                         var statusMatch = allText.match(/status[:\s]*(success|failed|pending|error)/i);
                        
//                         if (idMatch) id = idMatch[1];
//                         if (statusMatch) status = statusMatch[1];
//                       }
                      
//                       if (id && status) {
//                         TranooBridge.postMessage('id_transaction=' + id + ';status=' + status);
//                       }
//                     }
                    
//                     extractAndSend();
//                     setTimeout(extractAndSend, 2000);
//                     setTimeout(extractAndSend, 5000);
//                   })();
//                 ''');

//                 // Vérifier les URLs de redirection
//                 if (url.contains('success') || url.contains('completed')) {
//                   await widget.onIntercept('success://payment-success');
//                 } else if (url.contains('cancel') || url.contains('failed') || url.contains('error')) {
//                   await widget.onIntercept('error://payment-error');
//                 }
//               },
//             ),
//           )
//           ..loadRequest(Uri.parse(widget.paymentUrl));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Paiement Vérification'),
//         backgroundColor: const Color(0xFF00A86B),
//         foregroundColor: Colors.white,
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) async {
//               if (value == 'success') {
//                 await widget.onIntercept('manual://status?success=true');
//               } else if (value == 'failed') {
//                 await widget.onIntercept('manual://status?success=false');
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'success',
//                 child: Text('✅ Marquer comme réussi'),
//               ),
//               const PopupMenuItem(
//                 value: 'failed',
//                 child: Text('❌ Marquer comme échoué'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (_isLoading)
//             const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF00A86B),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import 'package:feexpay_flutter/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';

final fpToken = dotenv.env['FP_TOKEN_FEEXPAY'] ?? '';
final idUser = dotenv.env['ID_USER_FEEXPAY'] ?? '';

class VerificationPaymentScreen extends StatefulWidget {
  const VerificationPaymentScreen({super.key});

  @override
  State<VerificationPaymentScreen> createState() => _VerificationPaymentScreenState();
}

class _VerificationPaymentScreenState extends State<VerificationPaymentScreen> {
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
          'Frais de vérification',
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
                            '5 FCFA',
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
                  ],
                ),
              ),
            ),
            
            // Bouton de paiement
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
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
                        'Procéder au paiement - 5 FCFA',
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
            amount: '5',
            redirecturl: '/verification-success',
            errorredirecturl: '/verification-error', 
            trans_key: transKey,
          ),
        ),
      );

      // Le résultat sera géré par les routes de redirection
      if (result != null) {
        // Afficher d'abord le message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paiement réussi ! Traitement de votre demande...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        
        // Attendre un peu pour que l'utilisateur voie le message
        await Future.delayed(Duration(seconds: 2));
        
        await _processVerificationRequest();
        
        if (mounted) {
          // Afficher le message final
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande de vérification envoyée avec succès !'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Attendre encore un peu avant de fermer
          await Future.delayed(Duration(seconds: 2));
          Navigator.pop(context, true);
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
        'amount': 50000,
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
}