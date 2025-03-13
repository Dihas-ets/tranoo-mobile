import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/connexion_page.dart';

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📸 Image d'arrière-plan
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/image_background.png',
                ), // Remplace par ton image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌫️ Dégradé sombre pour rendre le texte plus lisible
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withAlpha(60), Colors.transparent],
              ),
            ),
          ),

          // 📄 Texte et bouton
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 30.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

                // 🔘 Bouton fléché
                Row(
                  children: [
                    Expanded(child: SizedBox()),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffF8BF13).withAlpha(50),
                            spreadRadius: 0,
                            blurRadius: 50,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConnexionPage(),
                            ),
                          );
                        },
                        icon: Icon(
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
        ],
      ),
    );
  }
}
