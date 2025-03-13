import 'package:flutter/material.dart';
import 'movie.dart';
import 'payement.dart';

class Cars_info extends StatefulWidget {
  const Cars_info({super.key});

  @override
  State<Cars_info> createState() => _CarsinfoState();
}

class _CarsinfoState extends State<Cars_info> {
  int _currentImageIndex = 0;
  final List<String> _images = [
    'assets/images/teslapro.png',
    'assets/images/Audi.png',
    'assets/images/Ford.jpeg',
  ];

  bool isNew = false;
  bool is2023 = false;
  bool isBeninese = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildImageSection(),
          _buildContentSection(),
          const SizedBox(height: 50),
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

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 300,
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
                MaterialPageRoute(builder: (context) => const Movie()), // Diriger vers la page movie.dart
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            color: Colors.black.withOpacity(0.5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentImageIndex == index
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

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 24),
          _buildSpecifications(),
          const SizedBox(height: 24),
          _buildCheckboxes(),
          const SizedBox(height: 24),
          _buildOrderButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tesla Modèle 3',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  ' / 5 ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const Icon(
                  Icons.star,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '18,00 000,00 f',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return const Text(
      'La Tesla Model 3 est une berline électrique de taille moyenne, reconnue pour ses performances impressionnantes, son accélération.....',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
        height: 1.5,
      ),
    );
  }

  Widget _buildSpecifications() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSpecCard('Boîte À Vitesses', 'Automate', Icons.settings),
        _buildSpecCard('Carburant', 'Essence', Icons.local_gas_station),
        _buildSpecCard('Climatiseur', 'Oui', Icons.ac_unit),
        _buildSpecCard('Distance', '500', Icons.speed),
        _buildSpecCard('Sièges', '5', Icons.event_seat),
        _buildSpecCard('Portes', '2', Icons.door_front_door),
      ],
    );
  }

  Widget _buildSpecCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
            padding: const EdgeInsets.all(1),
            color: Colors.amber,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isNew,
                  onChanged: (bool? value) {
                    setState(() {
                      isNew = value!;
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                ),
                const Text('Nouveau'),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
            padding: const EdgeInsets.all(1),
            color: Colors.amber,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: is2023,
                  onChanged: (bool? value) {
                    setState(() {
                      is2023 = value!;
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                ),
                const Text('Modèle 2023'),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
            padding: const EdgeInsets.all(1),
            color: Colors.amber,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isBeninese,
                  onChanged: (bool? value) {
                    setState(() {
                      isBeninese = value!;
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                ),
                const Text('Béninoise'),
              ],
            ),
          ),
        ),
      ],
    );
  }



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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
