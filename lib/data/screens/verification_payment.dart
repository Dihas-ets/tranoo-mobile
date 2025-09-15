// // import 'package:flutter/material.dart';
// // import 'package:webview_flutter/webview_flutter.dart';
// // import '../../services/payment_api.dart';

// // class VerificationPaymentScreen extends StatefulWidget {
// //   const VerificationPaymentScreen({super.key});

// //   @override
// //   State<VerificationPaymentScreen> createState() =>
// //       _VerificationPaymentScreenState();
// // }

// // class _VerificationPaymentScreenState extends State<VerificationPaymentScreen> {
// //   bool _isLoading = false;
// //   String? _errorMessage;
// //   String? _successMessage;
// //   // String? _lastPaymentId; // non utilisé actuellement

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         title: const Text('Frais de vérification'),
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         foregroundColor: Colors.black,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const SizedBox(height: 12),
// //             const Text(
// //               'Nous allons vous rediriger vers notre agrégateur de paiement pour régler les frais de vérification.\n\nAprès paiement, vous recevrez un récapitulatif et les vérifications seront effectuées sous 10 jours.',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(fontSize: 14, height: 1.5),
// //             ),
// //             const SizedBox(height: 24),

// //             // Affichage du montant
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFF00A86B).withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: const Color(0xFF00A86B)),
// //               ),
// //               child: const Text(
// //                 '100 FCFA',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF00A86B),
// //                   fontSize: 18,
// //                 ),
// //               ),
// //             ),

// //             const SizedBox(height: 24),

// //             // Message de succès
// //             if (_successMessage != null)
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 margin: const EdgeInsets.only(bottom: 16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.green[100],
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(color: Colors.green),
// //                 ),
// //                 child: Text(
// //                   _successMessage!,
// //                   style: TextStyle(color: Colors.green[800]),
// //                 ),
// //               ),

// //             // Message d'erreur
// //             if (_errorMessage != null)
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 margin: const EdgeInsets.only(bottom: 16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.red[100],
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(color: Colors.red),
// //                 ),
// //                 child: Text(
// //                   _errorMessage!,
// //                   style: TextStyle(color: Colors.red[800]),
// //                 ),
// //               ),

// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: _isLoading ? null : _processPayment,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFFFFCC00),
// //                   foregroundColor: Colors.black,
// //                   padding: const EdgeInsets.symmetric(vertical: 14),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                 ),
// //                 child:
// //                     _isLoading
// //                         ? const SizedBox(
// //                           width: 20,
// //                           height: 20,
// //                           child: CircularProgressIndicator(strokeWidth: 2),
// //                         )
// //                         : const Text(
// //                           'Procéder au paiement',
// //                           style: TextStyle(fontWeight: FontWeight.w600),
// //                         ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> _processPayment() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = null;
// //       _successMessage = null;
// //     });

// //     try {
// //       final customId = 'VERIF_${DateTime.now().millisecondsSinceEpoch}';
// //       final result = await PaymentApi.initFeexPayPayment(
// //         amount: 5,
// //         customId: customId,
// //         description: 'Frais de vérification de pièce',
// //         method: 'MOBILE',
// //       );

// //       if (result['paymentUrl'] != null) {
// //         setState(() {
// //           _isLoading = false;
// //           _successMessage =
// //               'Paiement initialisé avec succès! Redirection vers la page de paiement...';
// //         });

// //         // Attendre un peu pour que l'utilisateur voie le message
// //         await Future.delayed(const Duration(seconds: 2));

// //         final paymentUrl = result['paymentUrl'];
// //         final paymentId = result['paymentId'];
// //         if (paymentUrl != null) {
// //           if (!mounted) return;
// //           await Navigator.of(context).push(
// //             MaterialPageRoute(
// //               builder:
// //                   (_) => _PaymentWebView(
// //                     paymentUrl: paymentUrl,
// //                     paymentId: paymentId,
// //                     onIntercept: (statusUrl) async {
// //                       // Gestion des pages de redirection
// //                       if (statusUrl == 'success://payment-success') {
// //                         if (!mounted) return;
// //                         Navigator.of(context).pop();
// //                         _showResultSheet(success: true);
// //                         return;
// //                       }
// //                       if (statusUrl == 'error://payment-error') {
// //                         if (!mounted) return;
// //                         Navigator.of(context).pop();
// //                         _showResultSheet(success: false);
// //                         return;
// //                       }

// //                       // Gestion du bouton "Terminer" manuel
// //                       if (statusUrl.startsWith('manual://status?')) {
// //                         debugPrint(
// //                           '[VerificationPayment] Manual status: $statusUrl',
// //                         );
// //                         final uri = Uri.parse(statusUrl);
// //                         final successParam = uri.queryParameters['success'];
// //                         bool? success;
// //                         if (successParam == 'true') {
// //                           success = true;
// //                         } else if (successParam == 'false') {
// //                           success = false;
// //                         } else {
// //                           success = null; // Statut inconnu
// //                         }
// //                         debugPrint(
// //                           '[VerificationPayment] Success value: $success',
// //                         );
// //                         if (!mounted) return;
// //                         Navigator.of(context).pop();
// //                         debugPrint(
// //                           '[VerificationPayment] Showing result sheet...',
// //                         );
// //                         _showResultSheet(success: success ?? false);
// //                         return;
// //                       }

// //                       // Extraire id_transaction depuis l'URL
// //                       String? idTxn;
// //                       try {
// //                         final uri = Uri.parse(statusUrl);
// //                         idTxn =
// //                             uri.queryParameters['id_transaction'] ??
// //                             uri.queryParameters['id'] ??
// //                             uri.queryParameters['transaction_id'];
// //                       } catch (_) {}

// //                       bool? success;
// //                       // Si on a un id_transaction, interroger le statut public
// //                       if (idTxn != null && idTxn.isNotEmpty) {
// //                         try {
// //                           final res = await PaymentApi.getFeexPublicStatus(
// //                             idTxn,
// //                             paymentId: paymentId,
// //                           );
// //                           final s =
// //                               (res['status'] ?? '').toString().toLowerCase();
// //                           success = s == 'success' || s == 'successful';
// //                           debugPrint(
// //                             '[PaymentWebView] Status from API: $s for ID: $idTxn',
// //                           );
// //                         } catch (e) {
// //                           debugPrint(
// //                             '[PaymentWebView] API error for ID $idTxn: $e',
// //                           );
// //                         }
// //                       }

// //                       // Afficher le résultat
// //                       _showResultSheet(success: success ?? false);
// //                     },
// //                   ),
// //             ),
// //           );
// //         }
// //       } else {
// //         setState(() {
// //           _isLoading = false;
// //           _errorMessage = 'Erreur lors de l\'initialisation du paiement';
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _isLoading = false;
// //         _errorMessage = 'Erreur: $e';
// //       });
// //     }
// //   }

// //   // UI résultat (succès/échec) façon FeexPay, en in‑app
// //   void _showResultSheet({required bool success, String? message}) {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: true,
// //       builder: (_) {
// //         return Center(
// //           child: Container(
// //             width: MediaQuery.of(context).size.width * 0.8,
// //             padding: const EdgeInsets.all(20),
// //             decoration: BoxDecoration(
// //               color:
// //                   success ? const Color(0xFF1DBF73) : const Color(0xFFE53935),
// //               borderRadius: BorderRadius.circular(16),
// //               boxShadow: const [
// //                 BoxShadow(
// //                   color: Colors.black26,
// //                   blurRadius: 12,
// //                   offset: Offset(0, 6),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   success ? Icons.check_circle : Icons.cancel,
// //                   color: Colors.white,
// //                   size: 56,
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   success ? 'Paiement réussi' : 'Paiement échoué',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 18,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 6),
// //                 Text(
// //                   message ??
// //                       (success
// //                           ? 'Votre transaction a été effectuée avec succès.'
// //                           : 'Une erreur s\'est produite durant la transaction.'),
// //                   style: const TextStyle(color: Colors.white70, fontSize: 14),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     if (!success)
// //                       ElevatedButton.icon(
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.white,
// //                           foregroundColor: const Color(0xFFE53935),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(24),
// //                           ),
// //                         ),
// //                         onPressed: () {
// //                           Navigator.of(context).pop();
// //                           _processPayment();
// //                         },
// //                         icon: const Icon(Icons.refresh),
// //                         label: const Text('Réessayer'),
// //                       ),
// //                     if (success)
// //                       ElevatedButton(
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.white,
// //                           foregroundColor: const Color(0xFF1DBF73),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(24),
// //                           ),
// //                         ),
// //                         onPressed: () => Navigator.of(context).pop(),
// //                         child: const Text('Retourner à l\'app'),
// //                       ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _pollStatus(String? paymentId) async {
// //     if (paymentId == null) return;
// //     // plus de stockage local du paymentId
// //     // Poll 5 fois, toutes les 3s
// //     for (int i = 0; i < 5; i++) {
// //       await Future.delayed(const Duration(seconds: 3));
// //       try {
// //         final res = await PaymentApi.getPaymentStatus(paymentId);
// //         final status = (res['status'] ?? '').toString();
// //         if (status == 'success') {
// //           if (!mounted) return;
// //           setState(() {
// //             _successMessage = 'Paiement réussi';
// //           });
// //           return;
// //         }
// //         if (status == 'failed' || status == 'cancelled') {
// //           if (!mounted) return;
// //           setState(() {
// //             _errorMessage = 'Paiement ${status}';
// //           });
// //           return;
// //         }
// //       } catch (_) {}
// //     }
// //   }
// // }

// // class _PaymentWebView extends StatefulWidget {
// //   final String paymentUrl;
// //   final Future<void> Function(String interceptedUrl) onIntercept;
// //   final String paymentId;
// //   const _PaymentWebView({
// //     required this.paymentUrl,
// //     required this.onIntercept,
// //     required this.paymentId,
// //   });

// //   @override
// //   State<_PaymentWebView> createState() => _PaymentWebViewState();
// // }

// // class _PaymentWebViewState extends State<_PaymentWebView> {
// //   late final WebViewController _controller;
// //   bool _isLoading = true;
// //   bool _overlayShown = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller =
// //         WebViewController()
// //           ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //           ..addJavaScriptChannel(
// //             'TranooBridge',
// //             onMessageReceived: (JavaScriptMessage message) async {
// //               final msg =
// //                   message.message; // format: id_transaction=...;status=...
// //               debugPrint('[PaymentWebView][JS] $msg');

// //               final idMatch = RegExp(r'id_transaction=([^;]+)').firstMatch(msg);
// //               final statusMatch = RegExp(r'status=([^;]+)').firstMatch(msg);
// //               final id = (idMatch?.group(1) ?? '').trim();
// //               final status = (statusMatch?.group(1) ?? '').trim();

// //               // Valider UUID
// //               final isUuid = RegExp(
// //                 r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12} ?$',
// //               ).hasMatch(id);

// //               // Ne réagir automatiquement que si ID valide ET statut connu
// //               if (isUuid && (status == 'SUCCESSFUL' || status == 'FAILED')) {
// //                 _overlayShown = true;
// //                 final success = status == 'SUCCESSFUL';
// //                 debugPrint(
// //                   '[PaymentWebView] Auto-detected status with UUID: $status',
// //                 );
// //                 Navigator.of(context).pop();
// //                 _showResultSheetDirect(success: success);
// //                 return;
// //               }

// //               // Si UUID présent mais pas de statut, interroger l'API publique
// //               if (isUuid && status.isEmpty) {
// //                 try {
// //                   final res = await PaymentApi.getFeexPublicStatus(
// //                     id,
// //                     paymentId: widget.paymentId,
// //                   );
// //                   final s = (res['status'] ?? '').toString().toLowerCase();
// //                   final success = s == 'success' || s == 'successful';
// //                   debugPrint(
// //                     '[PaymentWebView] Resolved via public status: ' + s,
// //                   );
// //                   Navigator.of(context).pop();
// //                   _showResultSheetDirect(success: success);
// //                   return;
// //                 } catch (e) {
// //                   debugPrint(
// //                     '[PaymentWebView] Public status error: ' + e.toString(),
// //                   );
// //                 }
// //               }

// //               // Sinon, juste tracer pour aider le backend et laisser l'UX continuer
// //               _overlayShown = true;
// //               try {
// //                 final url = await _controller.currentUrl();
// //                 final innerText = await _controller.runJavaScriptReturningResult(
// //                   'JSON.stringify((document.body && document.body.innerText) ? document.body.innerText.substring(0,1200) : "")',
// //                 );
// //                 final innerHtml = await _controller.runJavaScriptReturningResult(
// //                   'JSON.stringify((document.documentElement && document.documentElement.innerHTML) ? document.documentElement.innerHTML.substring(0,1200) : "")',
// //                 );
// //                 String _unwrap(dynamic v) {
// //                   final s = v?.toString() ?? '';
// //                   return s.startsWith('"') && s.endsWith('"')
// //                       ? s.substring(1, s.length - 1)
// //                       : s;
// //                 }

// //                 await PaymentApi.traceFromClient(
// //                   paymentId: widget.paymentId,
// //                   url: url,
// //                   text: _unwrap(innerText),
// //                   html: _unwrap(innerHtml),
// //                   message: msg,
// //                 );
// //               } catch (_) {}
// //               // Ne pas fermer, juste forward si besoin
// //               // widget.onIntercept('js://status?$msg');
// //             },
// //           )
// //           ..setNavigationDelegate(
// //             NavigationDelegate(
// //               onPageStarted: (_) => setState(() => _isLoading = true),
// //               onPageFinished: (_) async {
// //                 setState(() => _isLoading = false);
// //                 // Injecte un script pour tenter d'extraire id_transaction et status depuis la page
// //                 await _controller.runJavaScript('''(function(){
// //               try{
// //                 var t = document.body ? document.body.innerText : '';
// //                 var html = document.documentElement ? document.documentElement.innerHTML : '';

// //                 // Chercher l'ID dans le texte et HTML
// //                 var m = t.match(/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}/);
// //                 var id = m ? m[0] : '';

// //                 // Si pas trouvé dans le texte, chercher dans l'HTML
// //                 if(!id) {
// //                   var htmlMatch = html.match(/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}/);
// //                   id = htmlMatch ? htmlMatch[0] : '';
// //                 }

// //                 var st = '';
// //                 var low = t.toLowerCase();
// //                 if(low.indexOf('successful')>=0 || low.indexOf('success')>=0 || low.indexOf('paid')>=0){ st='SUCCESSFUL'; }
// //                 if(low.indexOf('failed')>=0 || low.indexOf('échec')>=0 || low.indexOf('insufficient')>=0 || low.indexOf('insuffisant')>=0 || low.indexOf('error')>=0){ st='FAILED'; }

// //                 // N'envoyer un message que si on a un UUID valide
// //                 if(id){
// //                   TranooBridge.postMessage('id_transaction='+id+';status='+st);
// //                 }
// //               }catch(e){}
// //             })();''');

// //                 // Script qui s'exécute toutes les 2 secondes pour détecter les changements
// //                 await _controller.runJavaScript('''
// //                   setInterval(function(){
// //                     try{
// //                       var t = document.body ? document.body.innerText : '';
// //                       var html = document.documentElement ? document.documentElement.innerHTML : '';

// //                       // Chercher l'ID
// //                       var m = t.match(/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}/);
// //                       var id = m ? m[0] : '';

// //                       if(!id) {
// //                         var htmlMatch = html.match(/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}/);
// //                         id = htmlMatch ? htmlMatch[0] : '';
// //                       }

// //                       var st = '';
// //                       var low = t.toLowerCase();
// //                       if(low.indexOf('successful')>=0 || low.indexOf('success')>=0 || low.indexOf('paid')>=0 || low.indexOf('réussi')>=0 || low.indexOf('validé')>=0){ st='SUCCESSFUL'; }
// //                       if(low.indexOf('failed')>=0 || low.indexOf('échec')>=0 || low.indexOf('insufficient')>=0 || low.indexOf('insuffisant')>=0 || low.indexOf('error')>=0 || low.indexOf('erreur')>=0){ st='FAILED'; }

// //                       if(id){
// //                         TranooBridge.postMessage('id_transaction='+id+';status='+st);
// //                       }
// //                     }catch(e){}
// //                   }, 2000);
// //                 ''');
// //               },
// //               onNavigationRequest: (request) {
// //                 final url = request.url;
// //                 debugPrint('[PaymentWebView][NAV] $url');

// //                 // Intercepter nos pages de redirection
// //                 if (url.contains('/payment-success.html')) {
// //                   _overlayShown = true;
// //                   widget.onIntercept('success://payment-success');
// //                   return NavigationDecision.prevent;
// //                 }
// //                 if (url.contains('/payment-error.html')) {
// //                   _overlayShown = true;
// //                   widget.onIntercept('error://payment-error');
// //                   return NavigationDecision.prevent;
// //                 }

// //                 // Intercepter les URLs avec id_transaction
// //                 if (url.contains('id_transaction=')) {
// //                   _overlayShown = true;
// //                   widget.onIntercept(url);
// //                   return NavigationDecision.prevent;
// //                 }

// //                 return NavigationDecision.navigate;
// //               },
// //             ),
// //           )
// //           ..loadRequest(Uri.parse(widget.paymentUrl));
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Paiement'),
// //         leading: IconButton(
// //           icon: const Icon(Icons.close),
// //           onPressed: () async {
// //             // Vérifier le statut avant de fermer
// //             try {
// //               final res = await PaymentApi.getPaymentStatus(widget.paymentId);
// //               final status = (res['status'] ?? '').toString().toLowerCase();
// //               final success = status == 'success' || status == 'successful';

// //               debugPrint('[PaymentWebView] Status fermeture: $status');

// //               // Fermer la WebView
// //               Navigator.of(context).pop();

// //               // Afficher directement l'UI de résultat
// //               _showResultSheetDirect(success: success);
// //             } catch (e) {
// //               debugPrint('[PaymentWebView] Erreur vérification: $e');
// //               // Fermer quand même
// //               Navigator.of(context).pop();
// //               _showResultSheetDirect(success: false);
// //             }
// //           },
// //         ),
// //       ),
// //       body: Stack(
// //         children: [
// //           WebViewWidget(controller: _controller),
// //           if (_isLoading) const Center(child: CircularProgressIndicator()),
// //         ],
// //       ),
// //     );
// //   }

// //   void _showResultSheetDirect({required bool success}) {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: true,
// //       builder: (_) {
// //         return Center(
// //           child: Container(
// //             width: MediaQuery.of(context).size.width * 0.8,
// //             padding: const EdgeInsets.all(20),
// //             decoration: BoxDecoration(
// //               color:
// //                   success ? const Color(0xFF1DBF73) : const Color(0xFFE53935),
// //               borderRadius: BorderRadius.circular(16),
// //               boxShadow: const [
// //                 BoxShadow(
// //                   color: Colors.black26,
// //                   blurRadius: 12,
// //                   offset: Offset(0, 6),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   success ? Icons.check_circle : Icons.cancel,
// //                   color: Colors.white,
// //                   size: 56,
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   success ? 'Paiement réussi' : 'Paiement échoué',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 18,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 6),
// //                 Text(
// //                   success
// //                       ? 'Votre transaction a été effectuée avec succès.'
// //                       : 'Une erreur s\'est produite durant la transaction.',
// //                   style: const TextStyle(color: Colors.white70, fontSize: 14),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 16),
// //                 ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.white,
// //                     foregroundColor:
// //                         success
// //                             ? const Color(0xFF1DBF73)
// //                             : const Color(0xFFE53935),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(24),
// //                     ),
// //                   ),
// //                   onPressed: () => Navigator.of(context).pop(),
// //                   child: Text(success ? 'Retourner à l\'app' : 'Fermer'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //   }
// // }







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
//                 child: _isLoading
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text(
//                         'Procéder au paiement',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
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
//               builder: (_) => _PaymentWebView(
//                 paymentUrl: paymentUrl,
//                 paymentId: paymentId,
//                 onIntercept: (statusUrl) async {
//                   // Gestion des pages de redirection
//                   if (statusUrl == 'success://payment-success') {
//                     if (!mounted) return;
//                     Navigator.of(context).pop();
//                     _showResultSheet(success: true);
//                     return;
//                   }
//                   if (statusUrl == 'error://payment-error') {
//                     if (!mounted) return;
//                     Navigator.of(context).pop();
//                     _showResultSheet(success: false);
//                     return;
//                   }

//                   // Gestion du bouton "Terminer" manuel
//                   if (statusUrl.startsWith('manual://status?')) {
//                     debugPrint(
//                       '[VerificationPayment] Manual status: $statusUrl',
//                     );
//                     final uri = Uri.parse(statusUrl);
//                     final successParam = uri.queryParameters['success'];
//                     bool? success;
//                     if (successParam == 'true') {
//                       success = true;
//                     } else if (successParam == 'false') {
//                       success = false;
//                     } else {
//                       success = null; // Statut inconnu
//                     }
//                     debugPrint(
//                       '[VerificationPayment] Success value: $success',
//                     );
//                     if (!mounted) return;
//                     Navigator.of(context).pop();
//                     debugPrint(
//                       '[VerificationPayment] Showing result sheet...',
//                     );
//                     _showResultSheet(success: success ?? false);
//                     return;
//                   }

//                   // Extraire id_transaction depuis l'URL
//                   String? idTxn;
//                   try {
//                     final uri = Uri.parse(statusUrl);
//                     idTxn = uri.queryParameters['id_transaction'] ??
//                         uri.queryParameters['id'] ??
//                         uri.queryParameters['transaction_id'];
//                   } catch (_) {}

//                   bool? success;
//                   // Si on a un id_transaction, interroger le statut public
//                   if (idTxn != null && idTxn.isNotEmpty) {
//                     try {
//                       final res = await PaymentApi.getFeexPublicStatus(
//                         idTxn,
//                         paymentId: paymentId,
//                       );
//                       final s = (res['status'] ?? '').toString().toLowerCase();
//                       success = s == 'success' || s == 'successful';
//                       debugPrint(
//                         '[PaymentWebView] Status from API: $s for ID: $idTxn',
//                       );
//                     } catch (e) {
//                       debugPrint(
//                         '[PaymentWebView] API error for ID $idTxn: $e',
//                       );
//                     }
//                   }

//                   // Afficher le résultat
//                   _showResultSheet(success: success ?? false);
//                 },
//               ),
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
//               color: success ? const Color(0xFF1DBF73) : const Color(0xFFE53935),
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
//             _errorMessage = 'Paiement $status';
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
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..addJavaScriptChannel(
//         'TranooBridge',
//         onMessageReceived: (JavaScriptMessage message) async {
//           final msg = message.message;
//           debugPrint('[PaymentWebView][JS] $msg');

//           final idMatch = RegExp(r'id_transaction=([^;]+)').firstMatch(msg);
//           final statusMatch = RegExp(r'status=([^;]+)').firstMatch(msg);
//           final id = (idMatch?.group(1) ?? '').trim();
//           final status = (statusMatch?.group(1) ?? '').trim();

//           // Valider UUID
//           final isUuid = RegExp(
//             r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
//           ).hasMatch(id);

//           if (isUuid && status.isNotEmpty) {
//             debugPrint('[PaymentWebView] Extracted transactionId: $id, status: $status');
//             await widget.onIntercept('manual://status?success=${status == 'success'}');
//           }
//         },
//       )
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             debugPrint('WebView loading: $progress%');
//           },
//           onPageStarted: (String url) {
//             setState(() {
//               _isLoading = true;
//             });
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               _isLoading = false;
//             });
//           },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('''
// Page resource error:
//   code: ${error.errorCode}
//   description: ${error.description}
//   errorType: ${error.errorType}
//   url: ${error.url}
//             ''');
//           },
//           onUrlChange: (UrlChange change) {
//             debugPrint('url change to ${change.url}');
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             debugPrint('navigation request: ${request.url}');
//             if (request.url.startsWith('success://') ||
//                 request.url.startsWith('error://') ||
//                 request.url.startsWith('manual://')) {
//               widget.onIntercept(request.url);
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.paymentUrl));

//     // Injecter le script de détection
//     _controller.runJavaScript('''
//       // Surveiller les changements dans la page
//       let lastUrl = location.href;
//       setInterval(() => {
//         if (location.href !== lastUrl) {
//           lastUrl = location.href;
//           TranooBridge.postMessage('url_changed=' + location.href);
//         }
//       }, 1000);

//       // Surveiller les éléments de la page pour détecter la fin du paiement
//       setInterval(() => {
//         // Détecter les messages de succès/échec
//         const successElements = document.querySelectorAll('[class*="success"], [class*="Success"], [id*="success"], [id*="Success"]');
//         const errorElements = document.querySelectorAll('[class*="error"], [class*="Error"], [class*="fail"], [class*="Fail"], [id*="error"], [id*="Error"]');
        
//         if (successElements.length > 0) {
//           TranooBridge.postMessage('status=success');
//         } else if (errorElements.length > 0) {
//           TranooBridge.postMessage('status=failed');
//         }

//         // Détecter les boutons de retour
//         const backButtons = document.querySelectorAll('button, a, [onclick*="back"], [onclick*="return"], [onclick*="close"]');
//         backButtons.forEach(btn => {
//           if (btn.textContent && (btn.textContent.includes('Retour') || btn.textContent.includes('Back') || btn.textContent.includes('Fermer') || btn.textContent.includes('Close'))) {
//             btn.addEventListener('click', () => {
//               TranooBridge.postMessage('user_action=back_button');
//             });
//           }
//         });
//       }, 2000);
//     ''');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Paiement en cours'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (ctx) => AlertDialog(
//                 title: const Text('Quitter le paiement ?'),
//                 content: const Text('Êtes-vous sûr de vouloir quitter le processus de paiement ?'),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(ctx).pop(),
//                     child: const Text('Annuler'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(ctx).pop();
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text('Quitter'),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (_isLoading)
//             const Center(
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class VerificationPaymentScreen extends StatelessWidget {
  const VerificationPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 60, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                '🚧 Cette section est en cours de développement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Merci de votre patience. Revenez bientôt pour découvrir les nouvelles fonctionnalités !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
