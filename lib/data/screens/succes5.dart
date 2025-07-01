import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/data/screens/paymentscreen.dart';

class SuccesScreen5 extends StatelessWidget {
  const SuccesScreen5({super.key});

  @override
  Widget build(BuildContext context) {
    // Définir la barre d'état en noir avec des icônes blanches
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withAlpha(40),
                      blurRadius: 40,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/smiley2.png',
                          height: 120,
                          width: 120,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Vous y êtes presque',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, height: 1.5),
                            children: [
                              TextSpan(
                                text: 'Votre mise en lumière coûtera environ ',
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: '15.000 XOF ',
                                style: TextStyle(color: Color(0xFF007AFF)),
                              ),
                              TextSpan(
                                text:
                                    'pour ce véhicule. Continuez et finalisez votre paiement pour voir votre véhicule en ',
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: 'tête de liste de nos produits',
                                style: TextStyle(color: Color(0xFF007AFF)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Finaliser le paiement',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
