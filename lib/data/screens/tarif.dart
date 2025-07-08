import 'package:flutter/material.dart';

class Tarif extends StatefulWidget {
  const Tarif({super.key});

  @override
  State<Tarif> createState() => _TarifState();
}

class _TarifState extends State<Tarif> {
  // Liste des annonces de voitures
  final List<Map<String, dynamic>> carAds = [
    {
      'title': 'Toyota Corolla',
      'description': '2018, 50,000 km, Blanc',
      'company': 'Tranoo',
      'price': '18,000,000 f',
      'specs': {
        'Cylindre': '4',
        'Boîte À Vitesses': 'Automate',
        'Carburant': 'Essence',
        'Climatiseur': 'Oui',
        'Distance': '500 km',
        'Sièges': '5',
        'Portes': '4',
      },
      'images': ['assets/images/Audi.png', 'assets/images/car.png'],
      'proposed': false,
      'proposedAmount': null,
    },
    {
      'title': 'Honda Civic',
      'description': '2020, 30,000 km, Noir',
      'company': 'Tranoo',
      'price': '20,000,000 f',
      'specs': {
        'Cylindre': '4',
        'Boîte À Vitesses': 'Manuelle',
        'Carburant': 'Diesel',
        'Climatiseur': 'Oui',
        'Distance': '600 km',
        'Sièges': '5',
        'Portes': '4',
      },
      'images': ['assets/images/care.png', 'assets/images/groupe2.png'],
      'proposed': true,
      'proposedAmount': '19,500,000',
    },
    {
      'title': 'Ford Focus',
      'description': '2019, 40,000 km, Bleu',
      'company': 'Tranoo',
      'price': '22,000,000 f',
      'specs': {
        'Cylindre': '4',
        'Boîte À Vitesses': 'Automate',
        'Carburant': 'Essence',
        'Climatiseur': 'Oui',
        'Distance': '550 km',
        'Sièges': '5',
        'Portes': '4',
      },
      'images': ['assets/images/groupe3.png', 'assets/images/groupe2.png'],
      'proposed': false,
      'proposedAmount': null,
    },
  ];

  // Filtre actif : "Souscrire" ou "Soumis"
  String activeFilter = 'Souscrire';

  // Met à jour l'état d'une annonce après une proposition de tarif
  void updateProposalStatus(int index, String amount) {
    setState(() {
      carAds[index]['proposed'] = true;
      carAds[index]['proposedAmount'] = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredAds =
        activeFilter == 'Souscrire'
            ? carAds.where((ad) => !ad['proposed']).toList()
            : carAds.where((ad) => ad['proposed']).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouton "Souscrire" avec style amélioré
            TextButton(
              onPressed: () => setState(() => activeFilter = 'Souscrire'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                'Souscrire',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      activeFilter == 'Souscrire'
                          ? Colors.white
                          : Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Bouton "Soumis" avec style amélioré
            TextButton(
              onPressed: () => setState(() => activeFilter = 'Soumis'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                'Soumis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      activeFilter == 'Soumis' ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment:
                activeFilter == 'Souscrire'
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 3.0,
              color: Colors.black, // Soulignement noir animé
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredAds.length,
        itemBuilder: (context, index) {
          final car = filteredAds[index];
          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CarDetailsPage(
                          car: car,
                          onProposalSubmitted:
                              (amount) => updateProposalStatus(
                                carAds.indexOf(car),
                                amount,
                              ),
                        ),
                  ),
                ),
            child: _buildCarAdCard(
              car,
            ), // Utilise le même effet hover que Transit
          );
        },
      ),
    );
  }

  // Widget _buildCarAdCard identique à celui de Transit (avec hover et animation)
  Widget _buildCarAdCard(Map<String, dynamic> car) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHovered ? Colors.amber : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(
                    Colors.grey.r.toInt(),
                    Colors.grey.g.toInt(),
                    Colors.grey.b.toInt(),
                    0.3,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    car['images'][0],
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${car['price']} f",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                if (activeFilter == 'Soumis' && car['proposedAmount'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 16.0),
                    child: Text(
                      '${car['prColors.amberoposedAmount']} f',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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

// Classe pour afficher les détails d'une voiture
class CarDetailsPage extends StatefulWidget {
  final Map<String, dynamic> car; // Détails de la voiture
  final Function(String)
  onProposalSubmitted; // Callback pour soumettre un tarif

  const CarDetailsPage({
    super.key,
    required this.car,
    required this.onProposalSubmitted,
  });

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  final TextEditingController _tarifController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        // title: Text(widget.car['title']!),
        // backgroundColor: Colors.amber,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildImageSection(), // Affiche une image d'exemple
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 24),
          _buildSpecifications(),
          const SizedBox(height: 24),
          _buildProposalSection(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    // Utilisation d'une image d'exemple pour le front-end
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Image.asset(
            'assets/images/car.png', // Image d'exemple
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(child: Text('Image non disponible')),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Description de l\'image',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    final specs = widget.car['specs'] as Map<String, String>;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isSmallScreen ? 2 : 3,
      childAspectRatio: isSmallScreen ? 2.0 : 2.5, // Réduit pour petits écrans
      mainAxisSpacing:
          isSmallScreen ? 8 : 16, // Réduit l'espacement pour petits écrans
      crossAxisSpacing: isSmallScreen ? 8 : 16,
      children:
          specs.entries.map((entry) {
            return Container(
              padding: EdgeInsets.all(
                isSmallScreen ? 8 : 12,
              ), // Padding réduit pour petits écrans
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize:
                          isSmallScreen ? 12 : 14, // Taille de police réduite
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize:
                          isSmallScreen ? 11 : 12, // Taille de police réduite
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.car['title']!,
          style: TextStyle(
            fontSize: screenWidth > 600 ? 24 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.car['company']!,
          style: TextStyle(
            fontSize: screenWidth > 600 ? 20 : 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.car['price']!,
          style: TextStyle(
            fontSize: screenWidth > 600 ? 22 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.car['description']!,
      style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
    );
  }

  Widget _buildProposalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proposez votre tarif pour le transit :',
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _tarifController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Entrez votre tarif',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // Aligne le bouton sur la droite
          children: [
            ElevatedButton(
              onPressed: () {
                final tarif = _tarifController.text;
                if (tarif.isNotEmpty) {
                  widget.onProposalSubmitted(tarif);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tarif proposé: $tarif f'),
                      backgroundColor: Colors.amber,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Soumettre'),
            ),
          ],
        ),
      ],
    );
  }
}
