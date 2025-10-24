import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de succès
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 32),

              // Titre de succès
              const Text(
                'Paiement réussi !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message de confirmation
              const Text(
                'Votre publicité a été créée avec succès.\nElle sera visible après validation par notre équipe.',
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Bouton pour retourner à l'accueil
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Retourner à la page marque.dart (accueil)
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/marque', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Retourner à l\'accueil',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

