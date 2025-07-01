import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tranoo/data/screens/cars_info.dart';
import 'package:tranoo/data/screens/voitures.dart';
import 'package:tranoo/data/screens/paymentform.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/mastervacpage.dart';
import 'package:tranoo/utils/role_redirect.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/data/screens/tarif.dart';
import 'package:tranoo/data/screens/transit.dart';

class Marque extends StatefulWidget {
  const Marque({super.key});

  @override
  State<Marque> createState() => _MarqueState();
}

class _MarqueState extends State<Marque> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late PageController _pageController;
  late TabController _tabController;
  final UserService _userService = UserService();
  late int _marqueTabIndex;
  late int _modeleTabIndex;
  late int _localisationTabIndex;
  late int _budgetTabIndex;

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

    // Initialisation des indices des onglets selon le rôle
    final isTransitaire = _userService.currentRole == UserRole.transitaire;
    _marqueTabIndex = isTransitaire ? 1 : 0;
    _modeleTabIndex = isTransitaire ? 2 : 1;
    _localisationTabIndex = isTransitaire ? 3 : 2;
    _budgetTabIndex = isTransitaire ? 4 : 3;

    _tabController = TabController(length: isTransitaire ? 5 : 4, vsync: this);

    _tabController.addListener(() {
      setState(() {});
    });

    _pageController = PageController(initialPage: 0);

    // Configuration du carrousel automatique
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
            color:
                isSelected ? const Color(0xFF007AFF) : const Color(0xFF000000),
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
    List<String> recommendedImages = [
      "assets/images/car.png",
      "assets/images/groupe2.png",
      "assets/images/groupe3.png",
      "assets/images/rectangle.png",
      "assets/images/rectangle 1.png",
      "assets/images/groupe2.png",
    ];

    List<String> piecesImages = [
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

    List<String> piecesNames = [
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

    List<double> piecesImageHeights = [
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

    List<double> piecesImageWidths = [
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
        mainAxisSize: MainAxisSize.min,
        children: [
          //Ajout du texte "Sponsorisé"
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.star, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                "Sponsorisé",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          //Section du carrousel
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendedImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CarsInfo(
                              selectedImageIndex: index,
                              images: recommendedImages,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            recommendedImages[index],
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
                                  "Tesla Model 3 Standard Range Plus",
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VoituresPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Voir tout",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  itemCount: recommendedImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CarsInfo(
                                  selectedImageIndex: index,
                                  images: recommendedImages,
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
                                  recommendedImages[index],
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    onPressed: () {},
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
                              Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 15,
                              ),
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pièces détachées",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF040415),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Piece()),
                          );
                        },
                        child: Text(
                          "Voir plus",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  itemCount: piecesImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MastervacPage(isAcheteur: true),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              piecesImages[index],
                              height: piecesImageHeights[index],
                              width: piecesImageWidths[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            piecesNames[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final isTransitaire = _userService.currentRole == UserRole.transitaire;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche de Honda Pilot 7-Passenger',
                  hintStyle: TextStyle(
                    color: const Color(0xFF8C9199),
                    fontSize: screenWidth * (isPortrait ? 0.035 : 0.025),
                    letterSpacing: 0.1,
                    height: 1.8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEDEEEF),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF8C9199),
                    size: screenWidth * 0.06,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.03,
                  ),
                ),
                onChanged: (text) => print('Recherche: $text'),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * (isPortrait ? 0.8 : 0.6),
                  height: screenHeight * (isPortrait ? 0.2 : 0.3),
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
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        child: Image.asset(imgList[index], fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: imgList.length,
                  effect: JumpingDotEffect(
                    activeDotColor: const Color(0xFFF8BF13),
                    dotColor: const Color(0xFFFFF7DD),
                    dotHeight: screenHeight * 0.01,
                    dotWidth: screenHeight * 0.01,
                    radius: screenHeight * 0.005,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: const BoxDecoration(),
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                ),
                tabs: [
                  if (isTransitaire) _buildTabButton("Activités", 0),
                  _buildTabButton("Marque", _marqueTabIndex),
                  _buildTabButton("Modèles", _modeleTabIndex),
                  _buildTabButton(
                    "Localisation",
                    _localisationTabIndex,
                    isWide: true,
                  ),
                  _buildTabButton("Budget", _budgetTabIndex),
                ],
              ),
            ),
            if (_tabController.index == 0 && isTransitaire)
              _buildActivitesSection(),
            if (_tabController.index == _marqueTabIndex) _buildMarqueSection(),
            if (_tabController.index == _modeleTabIndex) _buildModeleSection(),
            if (_tabController.index == _localisationTabIndex)
              _buildLocalisationSection(),
            if (_tabController.index == _budgetTabIndex) _buildBudgetSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitesSection() {
    List<Map<String, dynamic>> activites = [
      {
        "name": "Souscrire",
        "icon": "assets/images/souscrire.png",
        "route": Tarif(),
      },
      {
        "name": "Soumettre",
        "icon": "assets/images/soumis.png",
        "route": Tarif(),
      },
      {
        "name": "En Transit",
        "icon": "assets/images/transit.png",
        "route": Transit(),
      },
      {
        "name": "En Consommation",
        "icon": "assets/images/en_consommation.png",
        "route": Transit(),
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
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              itemCount: activites.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => activites[index]["route"],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          activites[index]["icon"],
                          height: 50,
                          width: 50,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          activites[index]["name"],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF000000),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
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
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
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
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
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
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
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

          // Section Recommandé
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recommandé",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF040415),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VoituresPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Voir tout",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: 6, // Exemple : nombre d'éléments recommandés
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CarsInfo(
                            selectedImageIndex: index,
                            images: const [
                              "assets/images/car.png",
                            ], // Exemple d'image
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
                            "assets/images/car.png", // Exemple d'image
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () {
                                // Action pour ajouter aux favoris
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Audi E-tron Premium",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "54,77 823,73 f",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
