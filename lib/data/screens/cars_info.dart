import 'package:flutter/material.dart';
import 'movie.dart'; // Importer la page pour les vidéos
import 'payement.dart'; // Importer la page pour le paiement

class Cars_info extends StatefulWidget {
  final int selectedImageIndex; // Index de l'image sélectionnée
  final List<String> images; // Liste des images

  const Cars_info({
    super.key,
    required this.selectedImageIndex,
    required this.images,
  });

  @override
  State<Cars_info> createState() => _CarsinfoState();
}

class _CarsinfoState extends State<Cars_info> {
  late int _currentImageIndex; // Gère l'image actuelle affichée
  bool isNew = false;
  bool is2023 = false;
  bool isBeninese = false;

  @override
  void initState() {
    super.initState();
    // Utilise l'image sélectionnée comme point de départ
    _currentImageIndex = widget.selectedImageIndex;
  }

  // Fonction utilitaire pour ajuster la taille en fonction de l'écran
  double responsiveSize(double screenWidth, double smallSize, double largeSize) {
    return screenWidth < 600 ? smallSize : largeSize;
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran pour la responsivité
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildImageSection(screenWidth, screenHeight), // Affiche l'image en grand
          _buildContentSection(screenWidth), // Affiche les détails et spécifications
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // Barre d'application avec bouton de retour et partage
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
          onPressed: () {
            // Action de partage ici
          },
        ),
      ],
    );
  }

  // Affiche l'image principale sélectionnée
  Widget _buildImageSection(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        SizedBox(
          height: screenHeight * 0.4, // Hauteur ajustée pour la responsivité
          width: double.infinity,
          child: Image.asset(
            widget.images[_currentImageIndex], // Image sélectionnée
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(child: Text('Image non disponible')),
              );
            },
          ),
        ),
        // Bouton pour accéder à la page des vidéos
        Positioned(
          right: 16,
          top: 16,
          child: IconButton(
            icon: const Icon(
              Icons.play_circle_fill,
              color: Colors.red,
              size: 40,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Movie(),
                ), // Redirige vers la page "movie.dart"
              );
            },
          ),
        ),
        // Liste des miniatures pour changer l'image affichée
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: screenHeight * 0.15, // Hauteur ajustée pour la responsivité
            color: Colors.black.withAlpha(50),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = index; // Change l'image affichée
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    width: screenWidth * 0.3, // Largeur ajustée pour la responsivité
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentImageIndex == index
                            ? Colors.amber
                            : Colors.transparent, // Image sélectionnée mise en évidence
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      widget.images[index],
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

  // Section des détails et spécifications
  Widget _buildContentSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04), // Espacement ajusté
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(screenWidth), // En-tête avec le modèle et le prix
          const SizedBox(height: 16),
          _buildDescription(screenWidth), // Description de la voiture
          const SizedBox(height: 24),
          _buildSpecifications(screenWidth), // Liste des spécifications
          const SizedBox(height: 24),
          _buildCheckboxes(screenWidth), // Cases à cocher
          const SizedBox(height: 24),
          _buildOrderButton(), // Bouton pour passer commande
        ],
      ),
    );
  }

  // En-tête avec le nom de la voiture et le prix
  Widget _buildHeader(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tesla Modèle 3',
              style: TextStyle(
                fontSize: responsiveSize(screenWidth, 20, 24), // Taille ajustée
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '18,00 000,00 f',
          style: TextStyle(
            fontSize: responsiveSize(screenWidth, 16, 20), // Taille ajustée
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Description de la voiture
  Widget _buildDescription(double screenWidth) {
    return Text(
      'La Tesla Model 3 est une berline électrique de taille moyenne, reconnue pour ses performances impressionnantes, son accélération et son autonomie.',
      style: TextStyle(
        fontSize: responsiveSize(screenWidth, 14, 16), // Taille ajustée
        color: Colors.grey,
        height: 1.5,
      ),
    );
  }

  // Spécifications de la voiture sous forme de grille
  Widget _buildSpecifications(double screenWidth) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSpecCard('Cylindre', '4', Icons.settings, screenWidth),
        _buildSpecCard('Boîte À Vitesses', 'Automate', Icons.settings, screenWidth),
        _buildSpecCard('Carburant', 'Essence', Icons.local_gas_station, screenWidth),
        _buildSpecCard('Climatiseur', 'Oui', Icons.ac_unit, screenWidth),
        _buildSpecCard('Distance', '500 km', Icons.speed, screenWidth),
        _buildSpecCard('Sièges', '5', Icons.event_seat, screenWidth),
        _buildSpecCard('Portes', '2', Icons.door_front_door, screenWidth),
      ],
    );
  }

  // Carte d'information générique pour les spécifications
  Widget _buildSpecCard(String title, String value, IconData icon, double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: responsiveSize(screenWidth, 20, 24), color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: responsiveSize(screenWidth, 14, 16), // Taille ajustée
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: responsiveSize(screenWidth, 12, 14), // Taille ajustée
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Cases à cocher pour les options
  Widget _buildCheckboxes(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCheckbox('Nouveau', isNew, (value) {
          setState(() {
            isNew = value!;
          });
        }, screenWidth),
        _buildCheckbox('Modèle 2023', is2023, (value) {
          setState(() {
            is2023 = value!;
          });
        }, screenWidth),
        _buildCheckbox('Béninoise', isBeninese, (value) {
          setState(() {
            isBeninese = value!;
          });
        }, screenWidth),
      ],
    );
  }

  // Widget générique pour une case à cocher
  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged, double screenWidth) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          checkColor: Colors.white,
        ),
        Text(
          label,
          style: TextStyle(fontSize: responsiveSize(screenWidth, 12, 14)), // Taille ajustée
        ),
      ],
    );
  }

  // Bouton pour passer une commande
  Widget _buildOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PayementScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Passez la commande',
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