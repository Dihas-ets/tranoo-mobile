import 'package:flutter/material.dart';

class Transit extends StatefulWidget {
  const Transit({super.key});

  @override
  State<Transit> createState() => _TransitState();
}

class _TransitState extends State<Transit> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> inTransit = [
    {
      'title': 'Toyota Corolla',
      'status': 'En Transit',
      'price': '18,000,000 f',
      'image': 'assets/images/car.png',
      'proposedPrice': null, // Prix proposé par l'utilisateur
    },
    {
      'title': 'Honda Civic',
      'status': 'En Transit',
      'price': '20,000,000 f',
      'image': 'assets/images/care.png',
      'proposedPrice': null, // Prix proposé par l'utilisateur
    },
  ];

  final List<Map<String, dynamic>> inConsumption = [
    {
      'title': 'Ford Focus',
      'status': 'En Consommation',
      'price': '22,000,000 f',
      'image': 'assets/images/care.png',
      'proposedPrice': null, // Prix proposé par l'utilisateur
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Transits'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icône de retour
          onPressed: () {
            Navigator.pop(context); // Retour à la page précédente
          },
        ),
        backgroundColor: Colors.amber,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize:
                18, // Augmente la taille du texte des onglets sélectionnés
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize:
                16, // Taille légèrement plus petite pour les onglets non sélectionnés
            fontWeight: FontWeight.normal,
          ),
          labelColor:
              Colors.white, // Couleur du texte pour l'onglet sélectionné
          unselectedLabelColor:
              Colors
                  .black, // Couleur du texte pour les onglets non sélectionnés
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: Colors.black, // Couleur du soulignement
              width: 3, // Épaisseur du soulignement
            ),
            insets: const EdgeInsets.symmetric(
              horizontal: 16,
            ), // Marges du soulignement
          ),
          tabs: const [Tab(text: 'En Transits'), Tab(text: 'En Consommation')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransitList(inTransit),
          _buildTransitList(inConsumption),
        ],
      ),
    );
  }

  Widget _buildTransitList(List<Map<String, dynamic>> transits) {
    if (transits.isEmpty) {
      return const Center(
        child: Text(
          'Aucun transit disponible',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: transits.length,
      itemBuilder: (context, index) {
        final transit = transits[index];
        return _buildTransitCard(transit);
      },
    );
  }

  Widget _buildTransitCard(Map<String, dynamic> transit) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false; // Variable pour suivre l'état du survol

        return MouseRegion(
          onEnter: (_) {
            setState(() {
              isHovered = true; // Active l'effet de survol
            });
          },
          onExit: (_) {
            setState(() {
              isHovered = false; // Désactive l'effet de survol
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isHovered
                        ? Colors.amber
                        : Colors.transparent, // Bordure amber au survol
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 77),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image miniature
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    transit['image']!, // Image associée au transit
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 16,
                ), // Espacement entre l'image et le texte
                // Texte descriptif
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transit['title']!, // Titre du transit
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transit['status']!, // Statut du transit
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transit['price']!, // Prix du transit
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      if (transit['proposedPrice'] !=
                          null) // Affiche le prix proposé s'il existe
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Proposé: ${transit['proposedPrice']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
