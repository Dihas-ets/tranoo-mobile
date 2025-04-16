import 'package:flutter/material.dart';

class PaymentForm extends StatelessWidget {
  final String pieceName;
  final String pieceImage;

  // Constructor pour passer les informations de la pièce
  const PaymentForm({
    super.key,
    required this.pieceName,
    required this.pieceImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulaire de Paiement pour $pieceName')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage de l'image de la pièce
            Image.asset(pieceImage),
            const SizedBox(height: 20),
            Text('Nom de la pièce: $pieceName', style: TextStyle(fontSize: 18)),
            // Formulaire de paiement
            // (Tu peux ajouter des champs de saisie pour le paiement ici)
            TextField(
              decoration: InputDecoration(
                labelText: 'Nom sur la carte',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Logique de traitement du paiement ici
              },
              child: Text('Payer'),
            ),
          ],
        ),
      ),
    );
  }
}
