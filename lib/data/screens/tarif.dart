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

  // Ajout pour les nouveaux filtres
  int _selectedFilter = 0; // 0: Soumis, 1: Soumettre, 2: Validés, 3: Archivés
  final List<String> _filters = ['Soumis', 'Soumettre', 'Validés', 'Archivés'];
  List<Map<String, dynamic>> archives = [];
  List<Map<String, dynamic>> valides = [];

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tarif'),
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _filters.length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: ChoiceChip(
                    label: Text(
                      _filters[i],
                      style: TextStyle(
                        color:
                            _selectedFilter == i
                                ? Colors.black
                                : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: _selectedFilter == i,
                    selectedColor: const Color(0xFFF8BF13),
                    backgroundColor: Colors.grey[200],
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = i;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildFilteredList()),
        ],
      ),
    );
  }

  Widget _buildFilteredList() {
    if (_selectedFilter == 0) {
      // Soumis
      final filteredAds = carAds.where((ad) => !ad['proposed']).toList();
      return _buildCarList(filteredAds);
    } else if (_selectedFilter == 1) {
      // Soumettre
      final filteredAds = carAds.where((ad) => ad['proposed']).toList();
      return _buildCarList(filteredAds);
    } else if (_selectedFilter == 2) {
      // Validés
      return _buildValidesList();
    } else {
      // Archivés
      return _buildArchivesList();
    }
  }

  Widget _buildCarList(List<Map<String, dynamic>> ads) {
    return ListView.builder(
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final car = ads[index];
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
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
                            Icons.directions_car,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car['description'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        if (car['proposed'] == true &&
                            car['proposedAmount'] != null)
                          Text(
                            'Proposé : ${car['proposedAmount']} f',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            car['price'] ?? '',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }

  Widget _buildValidesList() {
    if (valides.isEmpty) {
      return const Center(child: Text('Aucune proposition validée.'));
    }
    return ListView.builder(
      itemCount: valides.length,
      itemBuilder: (context, index) {
        final item = valides[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading:
                item['images'] != null && item['images'].isNotEmpty
                    ? Image.asset(
                      item['images'][0],
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                    : null,
            title: Text(
              item['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['description'] ?? ''),
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Validé',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  tooltip: 'Je ne suis pas disponible',
                  onPressed: () {
                    setState(() {
                      archives.add(item);
                      valides.remove(item);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.amber),
                  tooltip: 'J\'accepte',
                  onPressed: () {
                    setState(() {
                      // Passe dans transit.dart (enTransit ou enConsumption selon le détail)
                      // Ici, on simule juste le retrait de la liste
                      valides.remove(item);
                    });
                  },
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildArchivesList() {
    if (archives.isEmpty) {
      return const Center(child: Text('Aucune proposition archivée.'));
    }
    return ListView.builder(
      itemCount: archives.length,
      itemBuilder: (context, index) {
        final item = archives[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading:
                item['images'] != null && item['images'].isNotEmpty
                    ? Image.asset(
                      item['images'][0],
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                    : null,
            title: Text(
              item['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item['description'] ?? ''),
            isThreeLine: true,
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
