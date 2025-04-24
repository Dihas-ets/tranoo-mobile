import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/succes6.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MobileMoneyPaymentScreen(),
    ),
  );
}

class MobileMoneyPaymentScreen extends StatelessWidget {
  const MobileMoneyPaymentScreen({super.key});

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
                      onPressed: () {
                        // Aller à la page de succès
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccesScreen6(),
                          ),
                        );
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
