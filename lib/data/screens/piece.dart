import 'package:flutter/material.dart';
import 'mastervacpage.dart'; // Assure-toi que le fichier existe bien
import 'create_sell2.dart'; // Importer la page pour les vendeurs

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
    List<String> allPiecesImages = [];
    List<String> allPiecesNames = [];
    for (int i = 0; i < 40; i++) {
      allPiecesImages.add(piecesImages[i % piecesImages.length]);
      allPiecesNames.add(piecesNames[i % piecesNames.length]);
    }

    List<Map<String, dynamic>> filteredPieces = [];
    List<String> searchWords =
        _searchText.split(' ').where((word) => word.isNotEmpty).toList();

    for (int i = 0; i < allPiecesNames.length; i++) {
      String pieceName = allPiecesNames[i].toLowerCase();
      bool matchesAllWords = searchWords.every(
        (word) => pieceName.contains(word),
      );
      if (_searchText.isEmpty || matchesAllWords) {
        filteredPieces.add({
          'name': allPiecesNames[i],
          'image': allPiecesImages[i],
          'height': piecesImageHeights[i % piecesImageHeights.length],
          'width': piecesImageWidths[i % piecesImageWidths.length],
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pièces disponibles'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateSellPage2()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche
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
            // Filtres
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 8.0,
                children: _filtres.map((filtre) {
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
            // Grille des pièces
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
                  return GestureDetector(
                    onTap: () {
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