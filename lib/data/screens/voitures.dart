import 'package:flutter/material.dart';
import 'cars_info.dart'; // Importez Cars_info
import 'create_sell.dart'; // Importez CreateSell
import 'package:tranoo/services/user_service.dart'; // Importez UserService
import 'package:tranoo/utils/role_redirect.dart'; // Importez RoleRedirect

class VoituresPage extends StatefulWidget {
  const VoituresPage({super.key});

  @override
  State<VoituresPage> createState() => VoituresPageState();
}

class VoituresPageState extends State<VoituresPage> {
  final List<Map<String, dynamic>> allCars = [
    {
      "image": "assets/images/car.png",
      "name": "Tesla Model 3",
      "price": 54777823,
      "year": 2022,
    },
    {
      "image": "assets/images/groupe2.png",
      "name": "Audi E-tron",
      "price": 62000000,
      "year": 2021,
    },
    {
      "image": "assets/images/groupe3.png",
      "name": "BMW iX",
      "price": 70000000,
      "year": 2023,
    },
    {
      "image": "assets/images/rectangle.png",
      "name": "Mercedes EQC",
      "price": 58000000,
      "year": 2020,
    },
    {
      "image": "assets/images/rectangle 1.png",
      "name": "Nissan Leaf",
      "price": 35000000,
      "year": 2019,
    },
    {
      "image": "assets/images/groupe2.png",
      "name": "Hyundai Kona Electric",
      "price": 33000000,
      "year": 2021,
    },
  ];

  List<Map<String, dynamic>> displayedCars = [];
  final TextEditingController _searchController = TextEditingController();

  // Filtres
  bool filterTesla = false;
  bool filterAudi = false;
  bool filterBMW = false;
  bool filterNissan = false;
  bool filterAll = true;

  @override
  void initState() {
    super.initState();
    displayedCars = List.from(
      allCars,
    ); // Affichage initial de toutes les voitures
  }

  void applyFilters() {
    setState(() {
      displayedCars =
          allCars.where((car) {
            bool matches = true;

            if (filterAll) {
              return true; // Affiche toutes les voitures si "Tous" est sélectionné
            }

            if (filterTesla) {
              matches = matches && car['name'].toString().contains('Tesla');
            }
            if (filterAudi) {
              matches = matches && car['name'].toString().contains('Audi');
            }
            if (filterBMW) {
              matches = matches && car['name'].toString().contains('BMW');
            }
            if (filterNissan) {
              matches = matches && car['name'].toString().contains('Nissan');
            }

            return matches;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService(); // Instance du service utilisateur
    final isVendeur = userService.currentRole == UserRole.vendeur;

    final isAcheteurOrTransitaire =
        userService.currentRole == UserRole.acheteur ||
        userService.currentRole == UserRole.transitaire;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voitures disponibles'),
        backgroundColor: Colors.amber,
        actions: [
          if (isVendeur)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSellPage(),
                  ),
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
                  hintText: 'Rechercher une voiture...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    displayedCars =
                        allCars.where((car) {
                          return car['name'].toString().toLowerCase().contains(
                            value.toLowerCase(),
                          );
                        }).toList();
                  });
                },
              ),
            ),
            // Filtres
            if (isAcheteurOrTransitaire)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    FilterChip(
                      label: const Text('Tous'),
                      selected: filterAll,
                      selectedColor: Colors.orange,
                      onSelected: (bool selected) {
                        setState(() {
                          filterAll = selected;
                          filterTesla = false;
                          filterAudi = false;
                          filterBMW = false;
                          filterNissan = false;
                          applyFilters();
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Tesla'),
                      selected: filterTesla,
                      selectedColor: Colors.orange,
                      onSelected: (bool selected) {
                        setState(() {
                          filterTesla = selected;
                          filterAll = false;
                          filterAudi = false;
                          filterBMW = false;
                          filterNissan = false;
                          applyFilters();
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Audi'),
                      selected: filterAudi,
                      selectedColor: Colors.orange,
                      onSelected: (bool selected) {
                        setState(() {
                          filterAudi = selected;
                          filterAll = false;
                          filterTesla = false;
                          filterBMW = false;
                          filterNissan = false;
                          applyFilters();
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('BMW'),
                      selected: filterBMW,
                      selectedColor: Colors.orange,
                      onSelected: (bool selected) {
                        setState(() {
                          filterBMW = selected;
                          filterAll = false;
                          filterTesla = false;
                          filterAudi = false;
                          filterNissan = false;
                          applyFilters();
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Nissan'),
                      selected: filterNissan,
                      selectedColor: Colors.orange,
                      onSelected: (bool selected) {
                        setState(() {
                          filterNissan = selected;
                          filterAll = false;
                          filterTesla = false;
                          filterAudi = false;
                          filterBMW = false;
                          applyFilters();
                        });
                      },
                    ),
                  ],
                ),
              ),
            // Grille des voitures
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: displayedCars.length,
                itemBuilder: (context, index) {
                  final car = displayedCars[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CarsInfo(
                                    selectedImageIndex: index,
                                    images:
                                        displayedCars
                                            .map((c) => c['image'] as String)
                                            .toList(),
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
                                car['image'],
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              car['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${car['price']} f",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (isVendeur)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                allCars.removeAt(index);
                                displayedCars = List.from(allCars);
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
