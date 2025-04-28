// import 'package:flutter/material.dart';

// import 'payement.dart';

// class MastervacPage extends StatefulWidget {
//   const MastervacPage({super.key});

//   @override
//   State<MastervacPage> createState() => _MastervacPageState();
// }

// class _MastervacPageState extends State<MastervacPage> {
//   int _currentImageIndex = 0;
//   final List<String> _images = [
//     'assets/images/piece.png',
//     'assets/images/piece.png',
//     'assets/images/piece.png',
//   ];

//   bool isNew = false;
//   bool is2023 = false;
//   bool isBeninese = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: _buildAppBar(),
//       body: ListView(
//         physics: const BouncingScrollPhysics(),
//         children: [
//           _buildImageSection(),
//           _buildContentSection(),
//           const SizedBox(height: 50),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.share, color: Colors.black),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }

//   Widget _buildImageSection() {
//     return Stack(
//       children: [
//         SizedBox(
//           height: 300,
//           width: double.infinity,
//           child: Image.asset(
//             _images[_currentImageIndex],
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 color: Colors.grey[300],
//                 child: const Center(child: Text('Image non disponible')),
//               );
//             },
//           ),
//         ),
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             height: 100,
//             color: Colors.black.withAlpha(50),
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _images.length,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _currentImageIndex = index;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 10,
//                     ),
//                     width: 120,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color:
//                             _currentImageIndex == index
//                                 ? Colors.amber
//                                 : Colors.transparent,
//                         width: 2,
//                       ),
//                     ),
//                     child: Image.asset(
//                       _images[index],
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.image_not_supported),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildContentSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           const SizedBox(height: 16),
//           _buildDescription(),
//           const SizedBox(height: 24),
//           _buildSpecifications(),
//           const SizedBox(height: 24),
//           _buildCheckboxes(),
//           const SizedBox(height: 24),
//           _buildSellButton(), // le bouton conservé ici 
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: const [
//             Text(
//               'Mastervac',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Mastervac SARL',
//               style: TextStyle(fontSize: 16, color: Colors.black87),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           '10,000 f',
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.grey[800],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescription() {
//     return const Text(
//       'Composant essentiel du système de freinage, le mastervac amplifie la force exercée sur la pédale de frein pour faciliter le freinage.',
//       style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
//     );
//   }

// Widget _buildSpecifications() {
//   return GridView.count(
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     crossAxisCount: 2, // Toujours 2 colonnes
//     childAspectRatio: 1.8, // Augmenté par rapport à 1.5 pour plus d'espace
//     mainAxisSpacing: 12, // Réduit légèrement
//     crossAxisSpacing: 12, // Réduit légèrement
//     children: [
//       _buildSpecCard('Model', '124-CFDS', Icons.settings),
//       _buildSpecCard('Type', 'Rare', Icons.local_gas_station),
//     ],
//   );
// }

// Widget _buildSpecCard(String title, String value, IconData icon) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Padding horizontal réduit
//     decoration: BoxDecoration(
//       color: const Color(0xFFE8F1FF),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.center, // Centrer le contenu verticalement
//       children: [
//         Icon(icon, size: 20, color: Colors.black87), // Taille d'icône légèrement réduite
//         const SizedBox(height: 6),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 14, // Taille réduite
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 13, // Taille réduite
//             color: Colors.black54,
//           ),
//         ),
//       ],
//     ),
//   );
// }
//   Widget _buildCheckboxes() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildCheckboxContainer(
//           'Nouveau',
//           isNew,
//           (val) => setState(() => isNew = val),
//         ),
//         _buildCheckboxContainer(
//           'Modèle',
//           is2023,
//           (val) => setState(() => is2023 = val),
//         ),
//         _buildCheckboxContainer(
//           'Bénin',
//           isBeninese,
//           (val) => setState(() => isBeninese = val),
//         ),
//       ],
//     );
//   }

//   Widget _buildCheckboxContainer(
//     String label,
//     bool value,
//     Function(bool) onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(1),
//       child: Container(
//         padding: const EdgeInsets.all(1),
//         color: Colors.amber,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Checkbox(
//               value: value,
//               onChanged: (bool? val) => onChanged(val!),
//               activeColor: Colors.black,
//               checkColor: Colors.white,
//             ),
//             Text(label),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSellButton() {
//     return Center(
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const PayementScreen()),
//           );
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 14),
//           decoration: BoxDecoration(
//             color: Colors.amber,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const Text(
//             'Vendez votre pièce',
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'payement.dart';

// class MastervacPage extends StatefulWidget {
//   final bool isAcheteur; // Ajout d'un paramètre pour vérifier le rôle

//   const MastervacPage({super.key, required this.isAcheteur});

//   @override
//   State<MastervacPage> createState() => _MastervacPageState();
// }

// class _MastervacPageState extends State<MastervacPage> {
//   int _currentImageIndex = 0;
//   final List<String> _images = [
//     'assets/images/piece.png',
//     'assets/images/piece.png',
//     'assets/images/piece.png',
//   ];

//   // Définition des booléens nécessaires
//   bool isNew = false;
//   bool is2023 = false; // Ajout de la variable is2023
//   bool isBeninese = false; // Ajout de la variable isBeninese
//   bool isGarantieIncluse = false; // Case spécifique pour les acheteurs
//   bool isLivraisonRapide = false; // Case spécifique pour les acheteurs
//   TextEditingController detailsController = TextEditingController(); // Champ de texte pour les détails

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: _buildAppBar(),
  
//       body: ListView(
//         physics: const BouncingScrollPhysics(),
//         children: [
//           _buildImageSection(),
//           _buildContentSection(),
//           const SizedBox(height: 50),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.share, color: Colors.black),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }

//   Widget _buildImageSection() {
//     return Stack(
//       children: [
//         SizedBox(
//           height: 300,
//           width: double.infinity,
//           child: Image.asset(
//             _images[_currentImageIndex],
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 color: Colors.grey[300],
//                 child: const Center(child: Text('Image non disponible')),
//               );
//             },
//           ),
//         ),
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             height: 100,
//             color: Colors.black.withAlpha(50),
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _images.length,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _currentImageIndex = index;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 10,
//                     ),
//                     width: 120,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: _currentImageIndex == index
//                             ? Colors.amber
//                             : Colors.transparent,
//                         width: 2,
//                       ),
//                     ),
//                     child: Image.asset(
//                       _images[index],
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.image_not_supported),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildContentSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           const SizedBox(height: 16),
//           _buildDescription(),
//           const SizedBox(height: 24),
//           _buildSpecifications(),
//           const SizedBox(height: 24),
//           widget.isAcheteur ? _buildAcheteurOptions() : _buildVendeurOptions(),
//           const SizedBox(height: 24),
//           _buildActionButton(), // Bouton dynamique selon le rôle
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: const [
//             Text(
//               'Mastervac',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Mastervac SARL',
//               style: TextStyle(fontSize: 16, color: Colors.black87),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           '10,000 f',
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.grey[800],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescription() {
//     return const Text(
//       'Composant essentiel du système de freinage, le mastervac amplifie la force exercée sur la pédale de frein pour faciliter le freinage.',
//       style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
//     );
//   }

//   Widget _buildSpecifications() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 1.8,
//       mainAxisSpacing: 12,
//       crossAxisSpacing: 12,
//       children: [
//         _buildSpecCard('Model', '124-CFDS', Icons.settings),
//         _buildSpecCard('Type', 'Rare', Icons.local_gas_station),
//       ],
//     );
//   }

//   Widget _buildSpecCard(String title, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F1FF),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 20, color: Colors.black87),
//           const SizedBox(height: 6),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAcheteurOptions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildCheckboxContainer(
//               'En transit',
//               isLivraisonRapide,
//               (val) => setState(() => isLivraisonRapide = val),
//             ),
//             _buildCheckboxContainer(
//               'En consommation',
//               isGarantieIncluse,
//               (val) => setState(() => isGarantieIncluse = val),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Détails supplémentaires :',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: detailsController,
//           decoration: InputDecoration(
//             hintText: 'Entrez vos détails concernant la destination ici..',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           maxLines: 3,
//         ),
//       ],
//     );
//   }

//   Widget _buildVendeurOptions() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildCheckboxContainer(
//           'Nouveau',
//           isNew,
//           (val) => setState(() => isNew = val),
//         ),
//         _buildCheckboxContainer(
//           'Modèle',
//           is2023,
//           (val) => setState(() => is2023 = val),
//         ),
//         _buildCheckboxContainer(
//           'Bénin',
//           isBeninese,
//           (val) => setState(() => isBeninese = val),
//         ),
//       ],
//     );
//   }

//   Widget _buildCheckboxContainer(
//     String label,
//     bool value,
//     Function(bool) onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(1),
//       child: Container(
//         padding: const EdgeInsets.all(1),
//         color: Colors.amber,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Checkbox(
//               value: value,
//               onChanged: (bool? val) => onChanged(val!),
//               activeColor: Colors.black,
//               checkColor: Colors.white,
//             ),
//             Text(label),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton() {
//     return Center(
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const PayementScreen()),
//           );
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 14),
//           decoration: BoxDecoration(
//             color: Colors.amber,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             widget.isAcheteur ? 'Acheter la pièce' : 'Vendez votre pièce',
//             style: const TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'payement.dart';
import 'package:tranoo/services/user_service.dart'; // Importez UserService pour gérer les rôles
import 'package:tranoo/utils/role_redirect.dart';
import 'package:tranoo/services/user_service.dart';
class MastervacPage extends StatefulWidget {
  const MastervacPage({super.key, required bool isAcheteur});

  @override
  State<MastervacPage> createState() => _MastervacPageState();
}

class _MastervacPageState extends State<MastervacPage> {
  int _currentImageIndex = 0;
  final List<String> _images = [
    'assets/images/piece.png',
    'assets/images/piece.png',
    'assets/images/piece.png',
  ];

  // Définition des booléens nécessaires
  bool isNew = false;
  bool is2023 = false;
  bool isBeninese = false;
  bool isGarantieIncluse = false;
  bool isLivraisonRapide = false;
  TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userService = UserService(); // Instance du service utilisateur
    final isAcheteur = userService.currentRole == UserRole.acheteur;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildImageSection(),
          _buildContentSection(isAcheteur),
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
        SizedBox(
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
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            color: Colors.black.withAlpha(50),
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

  Widget _buildContentSection(bool isAcheteur) {
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
          _buildCheckboxes(isAcheteur),
          const SizedBox(height: 24),
          _buildActionButton(isAcheteur),
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
          children: const [
            Text(
              'Mastervac',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Mastervac SARL',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '10,000 f',
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
      'Composant essentiel du système de freinage, le mastervac amplifie la force exercée sur la pédale de frein pour faciliter le freinage.',
      style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
    );
  }

  Widget _buildSpecifications() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildSpecCard('Model', '124-CFDS', Icons.settings),
        _buildSpecCard('Type', 'Rare', Icons.local_gas_station),
      ],
    );
  }

  Widget _buildSpecCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(height: 6),
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
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxes(bool isAcheteur) {
    if (!isAcheteur) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCheckboxContainer('Nouveau', isNew, (val) {
            setState(() => isNew = val);
          }),
          _buildCheckboxContainer('Modèle', is2023, (val) {
            setState(() => is2023 = val);
          }),
          _buildCheckboxContainer('Bénin', isBeninese, (val) {
            setState(() => isBeninese = val);
          }),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCheckboxContainer('En transit', isLivraisonRapide, (val) {
                setState(() => isLivraisonRapide = val);
              }),
              _buildCheckboxContainer('En consommation', isGarantieIncluse, (val) {
                setState(() => isGarantieIncluse = val);
              }),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Détails supplémentaires :',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: detailsController,
            decoration: InputDecoration(
              hintText: 'Entrez vos détails concernant la destination ici...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
        ],
      );
    }
  }

  Widget _buildCheckboxContainer(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: const EdgeInsets.all(1),
        color: Colors.amber,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: (bool? val) => onChanged(val!),
              activeColor: Colors.black,
              checkColor: Colors.white,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isAcheteur) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PayementScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isAcheteur ? 'Acheter la pièce' : 'Vendez votre pièce',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}