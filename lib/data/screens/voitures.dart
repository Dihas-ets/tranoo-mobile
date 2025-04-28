import 'package:flutter/material.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';

import 'cars_info.dart';
import 'create_sell.dart';

class voituresPage extends StatefulWidget {
  const voituresPage({super.key});

  @override
  State<voituresPage> createState() => _voituresPageState();
}

class _voituresPageState extends State<voituresPage> {
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

  bool filterTesla = false;
  bool filterAudi = false;
  bool filterBMW = false; // Ajout du filtre BMW
  bool filterNissan = false;
  bool filterPrice = false;
  bool filterYear = false;
  bool filterAll = true;

  @override
  void initState() {
    super.initState();
    displayedCars = List.from(allCars); // Affichage initial de toutes les voitures
  }

  void applyFilters() {
    setState(() {
      displayedCars = allCars.where((car) {
        bool matches = true;

        if (filterAll) {
          return true; // Affiche toutes les voitures si "Tous" est sélectionné
        }

        // Si un des filtres est activé, on vérifie si le nom de la voiture correspond
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
    final userService = UserService();
    final isVendeurOrTransitaire =
        userService.currentRole == UserRole.vendeur ||
            userService.currentRole == UserRole.transitaire;
    final isAcheteur = userService.currentRole == UserRole.acheteur;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (isVendeurOrTransitaire)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
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
                onChanged: (value) {
                  setState(() {
                    displayedCars = allCars.where((car) {
                      return car['name'].toString().toLowerCase().contains(
                        value.toLowerCase(),
                      );
                    }).toList();
                  });
                },
              ),
            ),

            if (isAcheteur)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FilterChip(
                          label: const Text('Tous'),
                          selected: filterAll,
                          selectedColor:
                          Colors.orange, // Orange color when selected
                          onSelected: (bool selected) {
                            setState(() {
                              filterAll = selected;
                              filterTesla = false;
                              filterAudi = false;
                              filterBMW = false; // Reset other filters
                              filterNissan = false;
                              applyFilters();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Tesla'),
                          selected: filterTesla,
                          selectedColor:
                          Colors.orange, // Orange color when selected
                          onSelected: (bool selected) {
                            setState(() {
                              filterTesla = selected;
                              filterAll = false; // "Tous" is deselected
                              filterAudi = false; // Inactive other filters
                              filterBMW = false;
                              filterNissan = false;
                              applyFilters();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Audi'),
                          selected: filterAudi,
                          selectedColor:
                          Colors.orange, // Orange color when selected
                          onSelected: (bool selected) {
                            setState(() {
                              filterAudi = selected;
                              filterAll = false; // "Tous" is deselected
                              filterTesla = false; // Inactive other filters
                              filterBMW = false;
                              filterNissan = false;
                              applyFilters();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('BMW'),
                          selected: filterBMW,
                          selectedColor:
                          Colors.orange, // Orange color when selected
                          onSelected: (bool selected) {
                            setState(() {
                              filterBMW = selected;
                              filterAll = false; // "Tous" is deselected
                              filterTesla = false; // Inactive other filters
                              filterAudi = false;
                              filterNissan = false;
                              applyFilters();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Nissan'),
                          selected: filterNissan,
                          selectedColor:
                          Colors.orange, // Orange color when selected
                          onSelected: (bool selected) {
                            setState(() {
                              filterNissan = selected;
                              filterAll = false; // "Tous" is deselected
                              filterTesla = false; // Inactive other filters
                              filterAudi = false;
                              filterBMW = false;
                              applyFilters();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recommandé",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                        onTap:
                        isVendeurOrTransitaire
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Cars_info(
                                selectedImageIndex: index,
                                images:
                                displayedCars
                                    .map(
                                      (c) =>
                                  c['image'] as String,
                                )
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
                              "${car['price'].toString()} f",
                              style: const TextStyle(color: Colors.grey),
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
