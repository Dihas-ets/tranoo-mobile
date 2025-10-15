import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/data/screens/avant_home.dart';
import 'dart:developer';

class SuccesScreen6 extends StatefulWidget {
  const SuccesScreen6({super.key});

  @override
  State<SuccesScreen6> createState() => _SuccesScreen6State();
}

class _SuccesScreen6State extends State<SuccesScreen6> {
  bool _canNavigate = false;

  @override
  void initState() {
    super.initState();
    // LOG pour tracer l'affichage de la page de succès
    log('[SuccesScreen6] Affichage de la page de succès');
    
    // Permettre la navigation après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _canNavigate = true;
        });
      }
    });
  }

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
      extendBodyBehindAppBar: true, // Permet au contenu de passer sous l'AppBar
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
                      color: const Color(0xFF00D67D).withAlpha(40),
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
                    padding: const EdgeInsets.all(32.0), // Padding augmenté
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/smiley.png',
                          height: 120,
                          width: 120,
                        ),
                        const SizedBox(height: 24), // Espacement augmenté
                        const Text(
                          'Félicitations !',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24), // Espacement augmenté
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, height: 1.5),
                            children: [
                              TextSpan(
                                text:
                                    'Votre paiement a été effectué avec succès ! ',
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'Votre article sera mis en avant dès validation par notre équipe. Vous recevrez une notification de confirmation.',
                                style: TextStyle(color: Color(0xFF00D67D)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32), // Espacement augmenté
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canNavigate ? () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AvantHome(),
                                ),
                                (route) => false,
                              );
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D67D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 2,
                            ),
                            child: _canNavigate 
                              ? const Text(
                                  'Accéder à l\'accueil',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Préparation...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
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
