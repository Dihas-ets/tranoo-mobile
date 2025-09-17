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
      home: PaymentScreen(pubId: ''),
    ),
  );
}

class PaymentScreen extends StatelessWidget {
  final String pubId;
  const PaymentScreen({super.key, required this.pubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                      'Paiement',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Logos de cartes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImage('assets/images/American Express.png'),
                      SizedBox(width: 10), // Espacement réduit entre les images
                      _buildImage('assets/images/Visa.png'),
                      SizedBox(width: 10),
                      _buildImage('assets/images/American Express.png'),
                      SizedBox(width: 10),
                      _buildImage('assets/images/Discover.png'),
                    ],
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Nom sur la carte',
                      hintText: 'Rencontrez Patel',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Numéro de carte',
                      hintText: '0000 0000 0000 0000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Mois',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(12, (index) {
                            final mois = (index + 1).toString().padLeft(2, '0');
                            return DropdownMenuItem(
                              value: mois,
                              child: Text(mois),
                            );
                          }),
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Année',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(10, (index) {
                            final year =
                                (DateTime.now().year + index).toString();
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }),
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Code de sécurité de la carte',
                      hintText: 'Code',
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
                          log('[DEBUG][PaymentScreen] PATCH URL: $url');
                          log('[DEBUG][PaymentScreen] PATCH BODY: $body');
                          log('[DEBUG][PaymentScreen] PATCH HEADERS: $headers');
                          final response = await http.patch(
                            Uri.parse(url),
                            headers: headers,
                            body: body,
                          );
                          log(
                            '[DEBUG][PaymentScreen] PATCH status: ${response.statusCode}',
                          );
                          log(
                            '[DEBUG][PaymentScreen] PATCH response: ${response.body}',
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

  Widget _buildImage(String imagePath) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              128,
              128,
              128,
              0.2,
            ), // Remplace Colors.grey.withOpacity(0.2)
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}