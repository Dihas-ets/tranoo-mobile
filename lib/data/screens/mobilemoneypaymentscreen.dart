import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/succes6.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:tranoo/services/user_service.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MobileMoneyPaymentScreen(
        pubId: '',
      ), // Placeholder, will be passed from previous screen
    ),
  );
}

class MobileMoneyPaymentScreen extends StatelessWidget {
  final String pubId;
  const MobileMoneyPaymentScreen({super.key, required this.pubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back, color: Colors.black),
        title: Text(
          'Mettre ma voiture à la une',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 500, minHeight: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(128, 128, 128, 0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Paiement Mobile Money',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Choisir l'opérateur Mobile Money
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Choisir l\'opérateur',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'MTN Mobile Money',
                              'Moov Money',
                              'Orange Money',
                              'FedaPay',
                            ]
                            .map(
                              (operator) => DropdownMenuItem(
                                value: operator,
                                child: Text(operator),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 20),

                  // Numéro Mobile Money
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Numéro Mobile Money',
                      hintText: 'Ex: +229XXXXXXXX',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  // Montant à payer
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Montant à payer',
                      hintText: 'Ex: 5000 FCFA',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Code de sécurité Mobile Money (si nécessaire)
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Code de sécurité',
                      hintText: 'Votre code de sécurité',
                      suffixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mettre à jour le statut de la pub à 'payee' avant de passer à la page de succès
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          final idToken = await user?.getIdToken();
                          final url =
                              '${getBaseUrl()}/publicites/$pubId/statut';
                          final headers = {
                            'Content-Type': 'application/json',
                            if (idToken != null)
                              'Authorization': 'Bearer $idToken',
                          };
                          final body = jsonEncode({'statut': 'payee'});
                          log(
                            '[DEBUG][MobileMoneyPaymentScreen] PATCH URL: $url',
                          );
                          log(
                            '[DEBUG][MobileMoneyPaymentScreen] PATCH BODY: $body',
                          );
                          log(
                            '[DEBUG][MobileMoneyPaymentScreen] PATCH HEADERS: $headers',
                          );
                          final response = await http.patch(
                            Uri.parse(url),
                            headers: headers,
                            body: body,
                          );
                          log(
                            '[DEBUG][MobileMoneyPaymentScreen] PATCH status: ${response.statusCode}',
                          );
                          log(
                            '[DEBUG][MobileMoneyPaymentScreen] PATCH response: ${response.body}',
                          );
                          if (response.statusCode == 200) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuccesScreen6(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erreur lors de la mise à jour du statut de la pub.',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur réseau ou serveur: $e'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Valider le paiement',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
