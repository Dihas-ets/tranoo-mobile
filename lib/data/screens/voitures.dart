import 'package:flutter/material.dart';
import 'cars_info.dart'; // Importez Cars_info
import 'movie.dart'; // Importez Movies
import 'notifications.dart'; // Importez Notifications
import 'create_sell.dart'; // Importez CreateSell
import 'package:tranoo/services/user_service.dart'; // Importez UserService
import 'package:tranoo/utils/role_redirect.dart';

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

  // Liste des noms des voitures
  final List<String> carNames = [
    "Tesla Model 3",
    "Audi E-tron",
    "BMW iX",
    "Mercedes EQC",
    "Nissan Leaf",
    "Hyundai Kona Electric",
  ];

  // Contrôleur pour la barre de recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userService = UserService(); // Instance du service utilisateur
    final isVendeurOrTransitaire =
        userService.currentRole == UserRole.vendeur ||
        userService.currentRole == UserRole.transitaire;

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
          if (isVendeurOrTransitaire)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: () {
                // Redirection vers la page pour ajouter une voiture
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateSellPage()),
                );
              },
            ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.black,
                ),
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap:
                            isVendeurOrTransitaire
                                ? null // Pas de redirection pour les vendeurs/transitaires
                                : () {
                                  // Redirection pour les acheteurs
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => Cars_info(
                                            selectedImageIndex:
                                                index, // Passer l'index cliqué
                                            images: Images, // Passer les images
                                          ),
                                    ),
                                  );
                                },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 4),
                            Text(
                              carNames[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "54,77 823,73 f",
                              style: TextStyle(color: Colors.grey),
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
                                Images.removeAt(index); // Supprimer l'image
                                carNames.removeAt(index); // Supprimer le nom
                              });
                            },
                          ),
                        ),
                    ],
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
