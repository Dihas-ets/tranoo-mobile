import 'package:flutter/material.dart';
import 'cars_info.dart'; // Importez Cars_info
import 'movie.dart'; // Importez Movies

class voituresPage extends StatefulWidget {
  const voituresPage({super.key});

  @override
  State<voituresPage> createState() => _voituresPageState();
}

class _voituresPageState extends State<voituresPage> {
  // Liste d'images
  final List<String> Images = [
    "assets/images/car.png",
    "assets/images/groupe2.png",
    "assets/images/groupe3.png",
    "assets/images/rectangle.png",
    "assets/images/rectangle 1.png",
    "assets/images/groupe2.png",
  ];

  // Contrôleur pour la barre de recherche
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Filtrer les images en fonction de la recherche
    final filteredImages = Images.where((image) {
      return image.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value; // Met à jour la recherche
            });
          },
          decoration: InputDecoration(
            hintText: "Rechercher une voiture...",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        backgroundColor: Colors.white, // Couleur de l'AppBar
        elevation: 0, // Pas d'ombre
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Nombre de colonnes
            crossAxisSpacing: 10, // Espacement horizontal
            mainAxisSpacing: 10, // Espacement vertical
            childAspectRatio: 0.75, // Ratio largeur/hauteur
          ),
          itemCount: filteredImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Redirection vers Cars_info
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cars_info(
                      selectedImageIndex: index, // Passer l'index cliqué
                      images: filteredImages, // Passer les images filtrées
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          filteredImages[index],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.red,
                              size: 18,
                            ),
                            onPressed: () {
                              // Redirection vers Movies
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Movie(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Audi E-tron Premium",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "54,77 823,73 f",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.verified, color: Colors.green, size: 15),
                      SizedBox(width: 5),
                      Text(
                        "Vérifiée",
                        style: TextStyle(color: Color(0xFF188100)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}