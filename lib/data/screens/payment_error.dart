import 'package:flutter/material.dart';

class PaymentErrorPage extends StatelessWidget {
  const PaymentErrorPage({super.key});

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
              // Icône d'erreur
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 32),

              // Titre d'erreur
              const Text(
                'Paiement échoué',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message d'erreur
              const Text(
                'Une erreur s\'est produite lors du paiement.\nVeuillez réessayer ou contacter le support.',
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Boutons d'action
              Column(
                children: [
                  // Bouton pour réessayer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Retourner en arrière pour permettre de relancer
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Réessayer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bouton pour retourner à l'accueil
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Retourner à la page marque.dart (accueil)
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/marque', (route) => false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Retourner à l\'accueil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

