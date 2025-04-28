import 'package:flutter/material.dart';
import 'mastervacpage.dart'; // Assure-toi que le fichier existe bien
import 'create_sell.dart'; // Import pour ajouter une pièce
import 'package:tranoo/services/user_service.dart'; // Import pour gérer les rôles
import 'package:tranoo/utils/role_redirect.dart'; // Import pour la redirection basée sur le rôle

import 'create_sell2.dart';
class Piece extends StatefulWidget {
  const Piece({super.key});

  @override
  State<Piece> createState() => _PieceState();
}

class _PieceState extends State<Piece> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  final List<String> piecesImages = [
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

  final List<String> piecesNames = [
    "Disque de frein",
    "Plaquette de frein",
    "Kit de frein",
    "Flexible de frein",
    "Pompe à vide",
    "Mastervac",
    "Mastervac",
    "Mastervac",
    "Disque de frein",
    "Mastervac",
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

  final List<double> piecesImageHeights = List.generate(32, (index) => 35.0);
  final List<double> piecesImageWidths = List.generate(32, (index) => 35.0);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService(); // Instance du service utilisateur
    final isVendeurOrTransitaire = userService.currentRole == UserRole.vendeur ||
        userService.currentRole == UserRole.transitaire;

    List<Map<String, dynamic>> allPieces = List.generate(
      piecesNames.length,
      (index) => {
        'name': piecesNames[index],
        'image': piecesImages[index % piecesImages.length],
        'height': piecesImageHeights[index % piecesImageHeights.length],
        'width': piecesImageWidths[index % piecesImageWidths.length],
      },
    );

    List<Map<String, dynamic>> filteredPieces = allPieces.where((piece) {
      if (_searchText.isEmpty) return true;
      return piece['name'].toLowerCase().contains(_searchText);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        //title: const Text("Pièces détachées"),
        //backgroundColor: Colors.amber,
        actions: isVendeurOrTransitaire
            ? [
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: () {
                    // Redirection vers la page pour ajouter une pièce
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateSellPage2()),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une pièce...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredPieces.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: isVendeurOrTransitaire
                            ? null // Pas de redirection pour les vendeurs/transitaires
                            : () {
                                // Redirection pour les acheteurs
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MastervacPage(isAcheteur: true,),
                                  ),
                                );
                              },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                filteredPieces[index]['image'],
                                height: filteredPieces[index]['height'],
                                width: filteredPieces[index]['width'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              filteredPieces[index]['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (isVendeurOrTransitaire)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                allPieces.removeWhere((piece) =>
                                    piece['name'] ==
                                    filteredPieces[index]['name']);
                              });
                            },
                          ),
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