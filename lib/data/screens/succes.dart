import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tramoo/data/screens/avant_home.dart';

class SuccesScreen extends StatelessWidget {
  const SuccesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Définir la barre d'état en noir avec des icônes blanches
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // Permet au contenu de passer sous l'AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon:  Icon(
                Icons.share,
                color: Colors.black),
            onPressed: () {
              // Action de partage
            },
          ),
        ],
      ),
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
                          'Woo hoo !!',
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
                                text: 'Cher client vous avez réussi à faire votre achat avec succès. ',
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: 'Votre produit vous sera livré au plus dans 5 jrs. Merci pour votre confiance !',
                                style: TextStyle(color: Color(0xFF00D67D)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32), // Espacement augmenté
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AvantHome()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D67D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Accéder à l\'accueil',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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

