import 'package:flutter/material.dart';
import 'cars_info.dart'; // Importez Cars_info
import 'movie.dart'; // Importez Movies
import 'notifications.dart'; // Importez Notifications

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Retour à la page précédente
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Image.asset(
            "assets/images/logo_connexion.png", // Icône Tranoo
            height: 40,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_outlined, color: Colors.black),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Redirection vers la page des notifications
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notifications()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher une voiture...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Texte "Recommandé"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  "Recommandé",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Nombre de colonnes
                  crossAxisSpacing: 10, // Espacement horizontal
                  mainAxisSpacing: 10, // Espacement vertical
                  childAspectRatio: 0.75, // Ratio largeur/hauteur
                ),
                itemCount: Images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Redirection vers Cars_info
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cars_info(
                            selectedImageIndex: index, // Passer l'index cliqué
                            images: Images, // Passer les images
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
                                Images[index],
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
          ),
        ],
      ),
    );
  }
}