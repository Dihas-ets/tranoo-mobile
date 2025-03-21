import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tranoo/data/screens/cars_info.dart';

class Marque extends StatefulWidget {
  const Marque({super.key});

  @override
  State<Marque> createState() => _MarqueState();
}

class _MarqueState extends State<Marque> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 0;
  late PageController _pageController;

  final imgList = [
    'assets/images/jeni.png',
    'assets/images/mask.png',
    'assets/images/jeni.png',
    'assets/images/mask.png',
    'assets/images/jeni.png',
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _pageController = PageController(initialPage: 0);

    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (_currentPage < imgList.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTabButton(String title, int index, {bool isWide = false}) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = index;
        });
      },
      child: Container(
        width: isWide ? 85 : 65,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF007AFF) : Color(0xFF000000),
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    List<String> images = [
      "assets/images/teslapro.png",
      "assets/images/car.png", // Assure-toi que le nom de fichier est correct
      "assets/images/care.png", // Remplace par une image valide si nécessaire
      "assets/images/bagnole.png",
    ];

    List<String> texts = [
      "Tesla Model 3 Standard Range Plus", // Texte pour la première image
      "Tesla Model 3 Standard Range Plus", // Texte pour la deuxième image
      "Tesla Model 3 Standard Range Plus", // Texte pour la troisième image
      "Tesla Model 3 Standard Range Plus", // Texte pour la quatrième image
    ];
    List<String> Images = [
      "assets/images/car.png", // Remplace par ton image
      "assets/images/groupe2.png", // Remplace par ton image
      "assets/images/groupe3.png", // Remplace par ton image
      "assets/images/rectangle.png", // Remplace par ton image
      "assets/images/rectangle 1.png", // Remplace par ton image
      "assets/images/groupe2.png", // Remplace par ton image
    ];
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
    ];
    // Liste des hauteurs pour chaque image (correspond à l'ordre des images)
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
    ];

    // Liste des largeurs pour chaque image (correspond à l'ordre des images)
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
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ajuste la hauteur au contenu
        children: [
          // Carrousel des images
          SizedBox(
            height: 180, // Hauteur totale ajustée
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Cars_info()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 10), // Espacement
                    child: Stack(
                      alignment:
                          Alignment.bottomLeft, // Alignement du texte en bas
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            images[index],
                            width: 300,
                            height: 170,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  texts[index],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      color: Color(0xFFF8BF13),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      "Vérifiée",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFF8BF13),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),

                // Section "Recommandé"
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recommandé",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF040415),
                        ),
                      ),
                      Text(
                        "Voir tout",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // Liste des articles recommandés
                GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: Images.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                Images[index],
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 16, // Taille réduite du cercle
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: Colors.red, // Cœur rempli en rouge
                                    size: 18, // Taille de l'icône réduite
                                  ),
                                  onPressed: () {
                                    // Action pour aimer l'image
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: CircleAvatar(
                                radius:
                                    16, // Taille réduite du cercle pour YouTube
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.red, // Icône YouTube en rouge
                                    size: 18, // Taille de l'icône réduite
                                  ),
                                  onPressed: () {
                                    // Action pour ouvrir la vidéo YouTube
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Audi E-tron Premium",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "54,77 823,73 f",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 15),
                            SizedBox(width: 5),
                            Text(
                              "Vérifiée",
                              style: TextStyle(color: Color(0xFF188100)),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                // Section "Pièces détachées"
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Text(
                    "Pièces détachées",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF040415),
                    ),
                  ),
                ),

                // Liste des pièces détachées
                GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: PiecesImages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            PiecesImages[index],
                            height:
                                PiecesImageHeights[index], // Utilisation de la hauteur spécifique
                            width: PiecesImageWidths[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8), // Espace entre l'image et le texte
                        Text(
                          PiecesNames[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),

                // 🔴 Ajout d'un `SizedBox` pour éviter l'overflow
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche de Honda Pilot 7-Passenger',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8C9199),
                    fontSize: 14,
                    letterSpacing: 0.1,
                    height: 1.8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEDEEEF),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8C9199),
                    size: 30,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 15.0,
                  ),
                ),
                onChanged: (text) => print('Recherche: $text'),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 320,
                  height: 150,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: imgList.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(imgList[index], fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ), // Espacement entre le carrousel et les points
                SmoothPageIndicator(
                  controller: _pageController,
                  count: imgList.length,
                  effect: JumpingDotEffect(
                    activeDotColor: Color(0xFFF8BF13),
                    dotColor: Color(0xFFFFF7DD),
                    dotHeight: 8,
                    dotWidth: 8,
                    radius: 4,
                  ),
                ),
              ],
            ),

            // Onglets
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicator: const BoxDecoration(),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                tabs: [
                  _buildTabButton("Marque", 0),
                  _buildTabButton("Modèles", 1),
                  _buildTabButton("Localisation", 2, isWide: true),
                  _buildTabButton("Budget", 3),
                ],
              ),
            ),

            // Sections associées aux onglets (sans TabBarView)
            if (_tabController.index == 0) _buildMarqueSection(),
            if (_tabController.index == 1) _buildModeleSection(),
            if (_tabController.index == 2) _buildLocalisationSection(),
            if (_tabController.index == 3) _buildBudgetSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueSection() {
    List<Map<String, dynamic>> marques = [
      {
        "name": "Toyota",
        "image": "assets/images/Toyota.png",
        "logoW": 23.0,
        "logoH": 15.0,
        "textW": 45.0,
        "textH": 18.0,
      },
      {
        "name": "Nissan",
        "image": "assets/images/nissan.png",
        "logoW": 30.0,
        "logoH": 25.0,
        "textW": 45.0,
        "textH": 18.0,
      },
      {
        "name": "Ford",
        "image": "assets/images/ford.png",
        "logoW": 40.0,
        "logoH": 21.0,
        "textW": 33.0,
        "textH": 15.0,
      },
      {
        "name": "Hyundai",
        "image": "assets/images/hunydai.png",
        "logoW": 26.0,
        "logoH": 23.0,
        "textW": 54.0,
        "textH": 18.0,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Deux colonnes par ligne
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2, // Ajuste la hauteur
              ),
              itemCount: marques.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: marques[index]["logoW"],
                        height: marques[index]["logoH"],
                        child: Image.asset(marques[index]["image"]!),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: marques[index]["textW"],
                        height: marques[index]["textH"],
                        child: Center(
                          child: Text(
                            marques[index]["name"]! ?? "No name",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF000000),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildImageCarousel(),
        ],
      ),
    );
  }

  Widget _buildModeleSection() {
    List<Map<String, dynamic>> modeles = [
      {"name": "Toyota Land cuiser", "logoW": 50.0, "logoH": 30.0},
      {"name": "Nissan Patrol", "logoW": 50.0, "logoH": 30.0},
      {"name": "Nissan Altima", "logoW": 50.0, "logoH": 30.0},
      {"name": "Toyota RAV-4", "logoW": 50.0, "logoH": 30.0},
      {"name": "Toyota Hilux", "logoW": 50.0, "logoH": 30.0},
      {"name": "Jeep Wrangler", "logoW": 50.0, "logoH": 30.0},
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Deux colonnes
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2, // Ajuste la hauteur
              ),
              itemCount: modeles.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        modeles[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildImageCarousel(),
        ],
      ),
    );
  }

  Widget _buildLocalisationSection() {
    List<Map<String, dynamic>> modeles = [
      {
        "name": "Benin",
        "image": "assets/images/benin.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Mali",
        "image": "assets/images/mali.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Niger",
        "image": "assets/images/niger.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Burkina-Faso",
        "image": "assets/images/burkina.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Deux colonnes
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2, // Ajuste la hauteur
              ),
              itemCount: modeles.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: modeles[index]["logoW"],
                        height: modeles[index]["logoH"],
                        child: Image.asset(modeles[index]["image"]),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        modeles[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildImageCarousel(),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    List<Map<String, dynamic>> modeles = [
      {
        "name": "Moins de 5000000 f",
        "image": "assets/images/Vector.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Moins de 10000000 f",
        "image": "assets/images/Vector.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Moins de 1500000 f",
        "image": "assets/images/Vector.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
      {
        "name": "Moins de 20000000 f",
        "image": "assets/images/Vector.png",
        "logoW": 50.0,
        "logoH": 30.0,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Deux colonnes
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2, // Ajuste la hauteur
              ),
              itemCount: modeles.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: modeles[index]["logoW"],
                        height: modeles[index]["logoH"],
                        child: Image.asset(modeles[index]["image"]),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        modeles[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildImageCarousel(),
        ],
      ),
    );
  }
}
