import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/third_page.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  SecondPageState createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E),
      body: Stack(
        children: [
          // 🌫️ Dégradé sombre
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withAlpha(60), Colors.transparent],
              ),
            ),
          ),

          // 📄 Texte, image et bouton avec espacement
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SingleChildScrollView(
              // Ajout de SingleChildScrollView pour éviter l'overflow
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),

                  // Ajout de l'image entourée par des espacements verticaux
                  Image.asset(
                    'assets/images/voiture_deuxieme_page.png',
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 70),

                  // Texte principal centré
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Découvrez votre\nvéhicule idéal en\nquelques clics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔘 Bouton fléché en bas à droite
                  Row(
                    children: [
                      const Expanded(child: SizedBox()), // Centrer à droite
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffF8BF13).withAlpha(50),
                              spreadRadius: 0,
                              blurRadius: 50,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ThirdPage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_circle_right,
                            color: Color(0xffF8BF13),
                            size: 60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
