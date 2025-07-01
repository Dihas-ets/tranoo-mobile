import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/paymentscreen.dart';
import 'movie.dart'; // Importer la page pour les vidéos
import 'payement.dart'; // Importer la page pour le paiement
import 'package:tranoo/services/user_service.dart'; // Importer UserService pour gérer les rôles
import 'package:tranoo/utils/role_redirect.dart'; // Importer RoleRedirect pour la redirection basée sur le rôle

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
  String? _selectedCountry;
  final List<String> africanCountries = [
    'Bénin',
    'Burkina Faso',
    'Côte d\'Ivoire',
    'Mali',
    'Niger',
    'Sénégal',
    'Togo',
    'Cameroun',
    'Gabon',
    'Guinée',
    'Congo',
    'RDC',
    'Maroc',
    'Algérie',
    'Tunisie',
    'Afrique du Sud',
    'Nigeria',
    'Ghana',
    'Kenya',
    'Éthiopie',
  ];

  @override
  void initState() {
    super.initState();
    // Utilise l'image sélectionnée comme point de départ
    _currentImageIndex = widget.selectedImageIndex;
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService(); // Instance du service utilisateur
    final isAcheteurOuChauffeur =
        userService.currentRole == UserRole.acheteur ||
        userService.currentRole == UserRole.chauffeur;

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
          _buildImageSection(
            screenWidth,
            screenHeight,
          ), // Affiche l'image en grand
          _buildContentSection(
            screenWidth,
            isAcheteurOuChauffeur,
          ), // Affiche les détails et spécifications
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
                    width:
                        screenWidth *
                        0.3, // Largeur ajustée pour la responsivité
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _currentImageIndex == index
                                ? Colors.amber
                                : Colors
                                    .transparent, // Image sélectionnée mise en évidence
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
  Widget _buildContentSection(double screenWidth, bool isAcheteur) {
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
          _buildCheckboxes(
            screenWidth,
            isAcheteur,
          ), // Cases à cocher (si applicable)
          const SizedBox(height: 24),
          _buildActionButton(isAcheteur), // Bouton d'action dynamique
        ],
      ),
    );
  }

  // En-tête avec le nom de la voiture et le prix
  Widget _buildHeader(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tesla Modèle 3',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        //Nom de l'entreprise
        Text(
          'Tranoo', // widget;companyName
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 8),
        Text(
          '18,00 000,00 f',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  // Description de la voiture
  Widget _buildDescription(double screenWidth) {
    return const Text(
      'La Tesla Model 3 est une berline électrique de taille moyenne, reconnue pour ses performances impressionnantes, son accélération et son autonomie.',
      style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
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
        _buildSpecCard('Cylindre', '4', Icons.settings),
        _buildSpecCard('Boîte À Vitesses', 'Automate', Icons.settings),
        _buildSpecCard('Carburant', 'Essence', Icons.local_gas_station),
        _buildSpecCard('Climatiseur', 'Oui', Icons.ac_unit),
        _buildSpecCard('Distance', '500 km', Icons.speed),
        _buildSpecCard('Sièges', '5', Icons.event_seat),
        _buildSpecCard('Portes', '2', Icons.door_front_door),
      ],
    );
  }

  // Carte d'information générique pour les spécifications
  Widget _buildSpecCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  // Cases à cocher pour les options
  Widget _buildCheckboxes(double screenWidth, bool isAcheteur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCheckbox(isAcheteur ? 'En transit' : 'Nouveau', isNew, (
              value,
            ) {
              setState(() {
                isNew = value!;
              });
            }),
            _buildCheckbox(
              isAcheteur ? 'En consommation' : 'Occasion',
              is2023,
              (value) {
                setState(() {
                  is2023 = value!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Menu déroulant Lieu
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          items:
              africanCountries
                  .map(
                    (country) =>
                        DropdownMenuItem(value: country, child: Text(country)),
                  )
                  .toList(),
          decoration: const InputDecoration(
            labelText: 'Lieu',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _selectedCountry = value),
        ),
        if (isAcheteur) ...[
          const SizedBox(height: 16),
          const Text(
            'Détails supplémentaires :',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Entrez vos détails concernant la destination ici...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  // Widget générique pour une case à cocher
  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          checkColor: Colors.white,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Bouton d'action dynamique
  Widget _buildActionButton(bool isAcheteur) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isAcheteur) {
            // Redirection pour les acheteurs
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PayementScreen()),
            );
          } else {
            // Affiche un popup de paiement pour les vendeurs
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber,
                              size: 32,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Frais à payer',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Pour publier votre voiture, vous devez payer les frais suivants :',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: const Text(
                            'Montant : 120 000 FCFA',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Ferme le dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Payer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          isAcheteur ? 'Passez la commande' : 'Vendez votre voiture',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
