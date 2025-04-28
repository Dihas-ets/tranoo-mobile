import 'package:flutter/material.dart';

class Tarif extends StatefulWidget {
  const Tarif({super.key});

  @override
  State<Tarif> createState() => _TarifState();
}

class _TarifState extends State<Tarif> {
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
      'images': ['assets/images/car1.png', 'assets/images/car2.png'],
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
      'images': ['assets/images/car3.png', 'assets/images/car4.png'],
      'proposed': false,
      'proposedAmount': null,
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
      'images': ['assets/images/car5.png', 'assets/images/car6.png'],
      'proposed': false,
      'proposedAmount': null,
    },
  ];

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
        title: const Text('Tarifs'),
        backgroundColor: Colors.amber,
      ),
      body: ListView.builder(
        itemCount: carAds.length,
        itemBuilder: (context, index) {
          final car = carAds[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(car['title']!),
              subtitle: Text(car['description']!),
              trailing:
                  car['proposed']
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            '${car['proposedAmount']} f',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                      : const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CarDetailsPage(
                          car: car,
                          onProposalSubmitted:
                              (amount) => updateProposalStatus(index, amount),
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CarDetailsPage extends StatefulWidget {
  final Map<String, dynamic> car;
  final Function(String) onProposalSubmitted;

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
  late int _currentImageIndex;

  @override
  void initState() {
    super.initState();
    _currentImageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car['title']!),
        backgroundColor: Colors.amber,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildImageSection(),
          const SizedBox(height: 20),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(
          height: screenWidth > 600 ? 300 : 200,
          width: double.infinity,
          child: Image.asset(
            widget.car['images'][_currentImageIndex],
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.car['images'].length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: screenWidth > 600 ? 80 : 60,
                  height: screenWidth > 600 ? 80 : 60,
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
                    widget.car['images'][index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    final specs = widget.car['specs'] as Map<String, String>;
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: screenWidth > 600 ? 3 : 2,
      childAspectRatio: screenWidth > 600 ? 2.5 : 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children:
          specs.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.value,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
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
        ElevatedButton(
          onPressed: () {
            final tarif = _tarifController.text;
            if (tarif.isNotEmpty) {
              widget.onProposalSubmitted(tarif);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tarif proposé: ${tarif} f'),
                  backgroundColor: Colors.amber,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          child: const Text('Soumettre'),
        ),
      ],
    );
  }
}
