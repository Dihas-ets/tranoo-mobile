import 'package:flutter/material.dart';
import 'movie.dart';
import 'succes2.dart';

class Cars_info2 extends StatefulWidget {
  const Cars_info2({super.key});

  @override
  State<Cars_info2> createState() => _Carsinfo2State();
}

class _Carsinfo2State extends State<Cars_info2> {
  int _currentImageIndex = 0;
  final List<String> _images = [
    'assets/images/teslapro.png',
    'assets/images/Audi.png',
    'assets/images/Ford.jpeg',
  ];

  bool isNew = false;
  bool is2023 = false;
  bool isBeninese = false;

  // Ajout de l'index pour le BottomNavigationBar
  int _selectedIndex = 0;

  // Fonction pour gérer le changement d'onglet
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Vous pouvez ajouter une logique de navigation ici si nécessaire
  }

  @override
  Widget build(BuildContext context) {
    // 1. Récupération des dimensions de l'écran
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      // 2. Utilisation de ListView pour permettre le défilement
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // 3. Section image avec dimensions adaptatives
          _buildImageSection(screenWidth, screenHeight, isPortrait),
          // 4. Section contenu avec padding adaptatif
          _buildContentSection(screenWidth, screenHeight, isPortrait),
          // 5. Espacement en bas adaptatif
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF9FAFB),
        selectedItemColor: const Color(0xFFF8BF13),
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: 'Vendre'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Piece'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Parametres',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildImageSection(
    double screenWidth,
    double screenHeight,
    bool isPortrait,
  ) {
    return Stack(
      children: [
        // 6. Container principal avec hauteur adaptative
        Container(
          height: isPortrait ? screenHeight * 0.35 : screenHeight * 0.5,
          width: double.infinity,
          child: Image.asset(
            _images[_currentImageIndex],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(child: Text('Image non disponible')),
              );
            },
          ),
        ),
        // 7. Bouton play positionné de manière adaptative
        Positioned(
          right: screenWidth * 0.04,
          top: screenHeight * 0.02,
          child: IconButton(
            icon: Icon(
              Icons.play_circle_fill,
              color: Colors.red,
              size: screenWidth * 0.1,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Movie()),
              );
            },
          ),
        ),
        // 8. Miniatures avec dimensions adaptatives
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: screenHeight * 0.12,
            color: Colors.black.withOpacity(0.5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.01,
                    ),
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _currentImageIndex == index
                                ? Colors.amber
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      _images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(
    double screenWidth,
    double screenHeight,
    bool isPortrait,
  ) {
    return Padding(
      // 9. Padding adaptatif basé sur la largeur de l'écran
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(screenWidth, screenHeight, isPortrait),
          SizedBox(height: screenHeight * 0.02),
          _buildDescription(screenWidth, isPortrait),
          SizedBox(height: screenHeight * 0.03),
          _buildSpecifications(screenWidth, isPortrait),
          SizedBox(height: screenHeight * 0.03),
          _buildCheckboxes(screenWidth, isPortrait),
          SizedBox(height: screenHeight * 0.03),
          _buildOrderButton(screenWidth, isPortrait),
        ],
      ),
    );
  }

  Widget _buildHeader(
    double screenWidth,
    double screenHeight,
    bool isPortrait,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 10. Textes avec tailles de police adaptatives
            Text(
              'Tesla Modèle 3',
              style: TextStyle(
                fontSize: isPortrait ? screenWidth * 0.06 : screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '50 000 000 FCFA',
              style: TextStyle(
                fontSize: isPortrait ? screenWidth * 0.05 : screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        Row(
          children: [
            Icon(Icons.location_on, size: screenWidth * 0.04),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Cotonou, Bénin',
              style: TextStyle(
                fontSize: isPortrait ? screenWidth * 0.04 : screenWidth * 0.03,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(double screenWidth, bool isPortrait) {
    return const Text(
      'La Tesla Model 3 est une berline électrique de taille moyenne, reconnue pour ses performances impressionnantes, son accélération.....',
      style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
    );
  }

  Widget _buildSpecifications(double screenWidth, bool isPortrait) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildInfoCard(Icons.settings, 'Boîte À Vitesses', 'Automate'),
        _buildInfoCard(Icons.local_gas_station, 'Carburant', 'Essence'),
        _buildInfoCard(Icons.ac_unit, 'Climatiseur', 'Oui'),
        _buildInfoCard(Icons.speed, 'Distance', '500'),
        _buildInfoCard(Icons.event_seat, 'Sièges', '5'),
        _buildInfoCard(Icons.door_front_door, 'Portes', '2'),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxes(double screenWidth, bool isPortrait) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCheckboxItem(
            value: isNew,
            onChanged: (bool? value) => setState(() => isNew = value!),
            label: 'Nouveau',
          ),
          _buildCheckboxItem(
            value: is2023,
            onChanged: (bool? value) => setState(() => is2023 = value!),
            label: 'Modèle 2023',
          ),
          _buildCheckboxItem(
            value: isBeninese,
            onChanged: (bool? value) => setState(() => isBeninese = value!),
            label: 'Béninoise',
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required bool value,
    required Function(bool?) onChanged,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.black,
              checkColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderButton(double screenWidth, bool isPortrait) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuccesScreen2()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Vendez votre voiture',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
