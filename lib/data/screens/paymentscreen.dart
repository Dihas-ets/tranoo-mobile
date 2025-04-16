import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/succes6.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: PaymentScreen()));
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

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
                    color: Colors.grey.withOpacity(0.2),
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
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png',
                        width: 50,
                      ),
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png',
                        width: 50,
                      ),
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/1/1b/American_Express_logo_%282018%29.svg',
                        width: 50,
                      ),
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/6/6b/Discover_Card_logo.svg',
                        width: 50,
                      ),
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
