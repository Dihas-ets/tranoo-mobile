import 'package:flutter/material.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart'; // Assure-toi que ce fichier contient enum UserRole { acheteur, vendeur, transitaire }

import 'create_sell2.dart';
import 'mastervacpage.dart';

class Piece extends StatefulWidget {
  const Piece({super.key});

  @override
  State<Piece> createState() => _PieceState();
}

class _PieceState extends State<Piece> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  final List<String> _filtres = ['Tous', 'Frein', 'Moteur', 'Électricité'];
  String _filtreActif = 'Tous';

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
    final userService = UserService();
    final currentRole = userService.currentRole;

    // Sécurité : en cas de rôle non défini
    if (currentRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAcheteur = currentRole == UserRole.acheteur;
    final isVendeurOrTransitaire =
        currentRole == UserRole.vendeur || currentRole == UserRole.transitaire;

    List<Map<String, dynamic>> allPieces = List.generate(
      piecesNames.length,
      (index) => {
        'name': piecesNames[index],
        'image': piecesImages[index % piecesImages.length],
        'height': piecesImageHeights[index % piecesImageHeights.length],
        'width': piecesImageWidths[index % piecesImageWidths.length],
      },
    );

    List<Map<String, dynamic>> filteredPieces =
        allPieces.where((piece) {
          final name = piece['name'].toLowerCase();
          final matchSearch = _searchText.isEmpty || name.contains(_searchText);
          final matchFiltre =
              _filtreActif == 'Tous' ||
              name.contains(_filtreActif.toLowerCase());
          return matchSearch && matchFiltre;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        actions:
            isVendeurOrTransitaire
                ? [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateSellPage2(),
                        ),
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
            if (isAcheteur)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Wrap(
                  spacing: 8.0,
                  children:
                      _filtres.map((filtre) {
                        final isSelected = _filtreActif == filtre;
                        return ChoiceChip(
                          label: Text(filtre),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _filtreActif = filtre;
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
            if (isAcheteur)
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
                        onTap:
                            isVendeurOrTransitaire
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MastervacPage(),
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
                                allPieces.removeWhere(
                                  (piece) =>
                                      piece['name'] ==
                                      filteredPieces[index]['name'],
                                );
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
