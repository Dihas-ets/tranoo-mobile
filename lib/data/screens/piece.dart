import 'package:flutter/material.dart';

class Piece extends StatefulWidget {
  const Piece({super.key});

  @override
  State<Piece> createState() => _PieceState();
}

class _PieceState extends State<Piece> {
  // Liste des images, des noms et des dimensions pour chaque pièce
  List<String> PiecesImages = [
    "assets/images/image1.png",
    "assets/images/image.png",
    "assets/images/image2.png",
    "assets/images/image3.png",
    "assets/images/image4.png",
    "assets/images/image5.png",
    "assets/images/image6.png",
    "assets/images/image7.png",
    "assets/images/image8.png",
    "assets/images/image9.png",
    "assets/images/image10.png",
    "assets/images/image11.png",
  ];

  List<String> PiecesNames = [
    "Disque de frein",
    "Plaquette de frein",
    "Kit de frein",
    "Flexible de frein",
    "Pompe à vide",
    "Mastevac",
    "Mastevac",
    "Mastevac",
    "Disque de frein",
    "Mastevac",
    "Kit de frein",
    "Flexible de frein",
    "Courroie de distribution",
    "Batterie",
    "Alternateur",
    "Amortisseur",
    "Clé à molette",
    "Boîte de vitesses",
    "Radiateur",
    "Étrier de frein",
    "Pneu",
    "Bouchon de vidange",
    "Filtre à huile",
    "Filtre à air",
    "Bougie d'allumage",
    "Phare avant",
    "Pare-chocs",
    "Essuie-glace",
    "Joint de culasse",
    "Vitre",
    "Aile avant",
    "Capot",
  ];

  List<double> PiecesImageHeights = [
    30,
    31,
    29,
    32,
    36,
    36,
    37,
    38,
    30,
    34,
    40,
    36,
    35,
    36,
    38,
    37,
    33,
    39,
    35,
    36,
    37,
    34,
    36,
    38,
    33,
    36,
    40,
    34,
    39,
    32,
  ];

  List<double> PiecesImageWidths = [
    30,
    31,
    29,
    32,
    36,
    36,
    37,
    38,
    30,
    34,
    40,
    36,
    35,
    36,
    38,
    37,
    33,
    39,
    35,
    36,
    37,
    34,
    36,
    38,
    33,
    36,
    40,
    34,
    39,
    32,
  ];

  @override
  Widget build(BuildContext context) {
    // Duplique les images et les noms pour afficher plus de pièces
    List<String> allPiecesImages = [];
    List<String> allPiecesNames = [];
    for (int i = 0; i < 40; i++) {
      allPiecesImages.add(PiecesImages[i % PiecesImages.length]);
      allPiecesNames.add(PiecesNames[i % PiecesNames.length]);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Titre
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              // child: Text(
              //   "Pièces détachées",
              //   style: TextStyle(
              //     fontSize: 25,
              //     fontWeight: FontWeight.bold,
              //     color: Color(0xFF040415),
              //   ),
              // ),
            ),

            // Liste des pièces détachées avec GridView
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                primary: true, // Permet le défilement vertical
                physics: AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Affiche 4 éléments par ligne
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Ajuste la taille de chaque item
                ),
                itemCount: allPiecesImages.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          allPiecesImages[index],
                          height:
                              PiecesImageHeights[index %
                                  PiecesImages
                                      .length], // Utilisation de la hauteur spécifique
                          width:
                              PiecesImageWidths[index %
                                  PiecesImages.length], // Largeur spécifique
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8), // Espace entre l'image et le texte
                      Text(
                        allPiecesNames[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Ajuste la taille du texte
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
