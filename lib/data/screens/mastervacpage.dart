import 'package:flutter/material.dart';
// import 'payement.dart'; // Plus utilisé
import 'package:tranoo/services/user_service.dart'; // Importez UserService pour gérer les rôles
import 'package:tranoo/utils/role_redirect.dart';
// import 'package:tranoo/data/screens/paymentscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/data/screens/succes6.dart';
import 'package:confetti/confetti.dart';
import 'dart:developer';
import 'une.dart'; // Import pour la page de demande de pub
import 'verification_payment.dart';

class MastervacPage extends StatefulWidget {
  final String? id;
  final bool isAcheteur;
  final String title;
  final String year;
  final String description;
  final String company;
  final String location;
  final String price;
  final String? fuelType;
  final String? model;
  final String? pieceType;
  final List<String?> images;
  final String? video;
  final bool fromPub;

  const MastervacPage({
    super.key,
    this.id,
    required this.isAcheteur,
    required this.title,
    required this.year,
    required this.description,
    required this.company,
    required this.location,
    required this.price,
    this.fuelType,
    this.model,
    this.pieceType,
    required this.images,
    this.video,
    this.fromPub = false,
  });

  @override
  State<MastervacPage> createState() => _MastervacPageState();
}

class _MastervacPageState extends State<MastervacPage> {
  int _currentImageIndex = 0;
  // SUPPRIME la liste statique _images

  // Définition des booléens nécessaires
  bool isNew = false;
  bool is2023 = false;
  bool isGarantieIncluse = false;
  bool isLivraisonRapide = false;
  TextEditingController detailsController = TextEditingController();
  // Champs de livraison/lieu déplacés depuis payement.dart
  bool isEnConsommationChecked = false;
  bool isEnTransitChecked = false;
  String? selectedCountry;
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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On ne passe plus de booléen, on déduit le rôle ici
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
        SizedBox(
          height: 300,
          width: double.infinity,
          child:
              (() {
                final String img = widget.images[_currentImageIndex] ?? '';
                if (img.startsWith('http')) {
                  return Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Image non disponible'),
                        ),
                      );
                    },
                  );
                } else if (img.isNotEmpty) {
                  return Image.asset(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Image non disponible'),
                        ),
                      );
                    },
                  );
                } else {
                  return Image.asset(
                    'assets/images/image_not_found.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Image non disponible'),
                        ),
                      );
                    },
                  );
                }
              })(),
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
              itemCount: widget.images.length,
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
                        color:
                            _currentImageIndex == index
                                ? Colors.amber
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child:
                        (() {
                          final String img = widget.images[index] ?? '';
                          if (img.startsWith('http')) {
                            return Image.network(
                              img,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            );
                          } else if (img.isNotEmpty) {
                            return Image.asset(
                              img,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            );
                          } else {
                            return Image.asset(
                              'assets/images/image_not_found.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            );
                          }
                        })(),
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
          _buildActionButton(),
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
            Text(
              widget.title.isNotEmpty ? widget.title : 'Non renseigné',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.company.isNotEmpty
                  ? widget.company
                  : 'Entreprise non renseignée',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.price.isNotEmpty ? widget.price : 'Non renseigné',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        // Année retirée de l'en-tête
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      (widget.description.isNotEmpty) ? widget.description : 'Non renseigné',
      style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
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
        _buildSpecCard(
          'Modèle',
          (widget.model != null && widget.model!.isNotEmpty)
              ? widget.model!
              : 'Non renseigné',
          Icons.settings,
        ),
        _buildSpecCard(
          'Type de pièce',
          (widget.pieceType != null && widget.pieceType!.isNotEmpty)
              ? widget.pieceType!
              : 'Non renseigné',
          Icons.category,
        ),
        _buildSpecCard(
          'Type moteur',
          (widget.fuelType != null && widget.fuelType!.isNotEmpty)
              ? widget.fuelType!
              : 'Non renseigné',
          Icons.local_gas_station,
        ),
        _buildSpecCard(
          'Année',
          widget.year.isNotEmpty ? widget.year : 'Non renseigné',
          Icons.calendar_today,
        ),
        _buildSpecCard(
          'Localisation',
          (widget.location.isNotEmpty) ? widget.location : 'Non renseigné',
          Icons.location_on,
        ),
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
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode de livraison (horizontal)
        Row(
          children: [
            _buildCheckboxContainer(
              'En Consommation',
              isEnConsommationChecked,
              (val) {
                setState(() {
                  isEnConsommationChecked = val;
                  if (val) isEnTransitChecked = false;
                });
              },
            ),
            const SizedBox(width: 16),
            _buildCheckboxContainer('En Transit', isEnTransitChecked, (val) {
              setState(() {
                isEnTransitChecked = val;
                if (val) isEnConsommationChecked = false;
              });
            }),
          ],
        ),
        const SizedBox(height: 12),
        // Lieu
        const Text('Lieu', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCountry,
              hint: const Text(
                'Choisissez un pays',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              isExpanded: true,
              items:
                  africanCountries
                      .map(
                        (c) =>
                            DropdownMenuItem<String>(value: c, child: Text(c)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedCountry = value),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Détails supplémentaires
        const Text(
          'Détails supplémentaires',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: detailsController,
          decoration: InputDecoration(
            hintText: 'Entrez vos détails concernant la destination ici...',
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildCheckboxContainer(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: const EdgeInsets.all(1),
        // color: Colors.amber,
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

  Widget _buildActionButton() {
    final userService = UserService();
    final isVendeur = userService.currentRole == UserRole.vendeur;
    if (widget.fromPub == true) {
      // Toujours afficher uniquement le bouton Acheter
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            // Validation des champs obligatoires
            if (!isEnConsommationChecked && !isEnTransitChecked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Veuillez choisir un mode de livraison (En Consommation ou En Transit).',
                  ),
                ),
              );
              return;
            }
            if (selectedCountry == null || selectedCountry!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez sélectionner un lieu.')),
              );
              return;
            }
            // Créer l'objet article à partir des propriétés du widget
            final article = {
              '_id': widget.id, // nécessite un ID réel pour charger les tarifs
              'titre': widget.title,
              'annee': widget.year,
              'description': widget.description,
              'entreprise': widget.company,
              'localisation': widget.location,
              'prix': widget.price,
              'typeMoteur': widget.fuelType,
              'modele': widget.model,
              'pieceType': widget.pieceType,
              'photos': widget.images.whereType<String>().toList(),
              'video': widget.video,
              'type': 'piece',
              // Pré-sélections
              'modeLivraison': isEnTransitChecked ? 'transit' : 'consommation',
              'paysDestination': selectedCountry,
              'detailsSupplementaires': detailsController.text.trim(),
            };

            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  content: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D67D).withOpacity(0.08),
                          const Color(0xFFFFCC00).withOpacity(0.12),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/smiley.png',
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Contrôle en cours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            children: const [
                              TextSpan(
                                text:
                                    'Les vérifications seront effectuées et vous seront envoyées sous ',
                              ),
                              TextSpan(
                                text: '10 jours',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFA000),
                                ),
                              ),
                              TextSpan(
                                text: '. Pour démarrer, veuillez payer les ',
                              ),
                              TextSpan(
                                text: 'frais de vérification',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00A86B),
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '20.000 FCFA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A86B),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const VerificationPaymentScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Payer les frais de vérification',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: const Text(
            'Acheter la pièce',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    if (!isVendeur) {
      // Acheteur ou chauffeur : bouton acheter
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (!isEnConsommationChecked && !isEnTransitChecked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Veuillez choisir un mode de livraison (En Consommation ou En Transit).',
                  ),
                ),
              );
              return;
            }
            if (selectedCountry == null || selectedCountry!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez sélectionner un lieu.')),
              );
              return;
            }
            // Créer l'objet article à partir des propriétés du widget
            final article = {
              '_id': widget.id, // nécessite un ID réel pour charger les tarifs
              'titre': widget.title,
              'annee': widget.year,
              'description': widget.description,
              'entreprise': widget.company,
              'localisation': widget.location,
              'prix': widget.price,
              'typeMoteur': widget.fuelType,
              'modele': widget.model,
              'pieceType': widget.pieceType,
              'photos': widget.images.whereType<String>().toList(),
              'video': widget.video,
              'type': 'piece',
            };

            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/smiley.png',
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Contrôle en cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Les vérifications seront effectuées et vous seront envoyées sous ',
                            ),
                            TextSpan(
                              text: '10 jours',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFA000),
                              ),
                            ),
                            TextSpan(
                              text: '. Pour démarrer, veuillez payer les ',
                            ),
                            TextSpan(
                              text: 'frais de vérification',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A86B),
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '20.000 FCFA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00A86B),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const VerificationPaymentScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Payer les frais de vérification'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Text(
            'Acheter la pièce',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      // Vendeur : boutons vendre + pub
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                log('[DEBUG] Bouton Vendez votre pièce cliqué');
                final pieceData = {
                  'type': 'piece',
                  'titre': widget.title,
                  'annee': widget.year,
                  'description': widget.description,
                  'entreprise': widget.company,
                  'localisation': widget.location,
                  'prix': widget.price,
                  'typeMoteur': widget.fuelType,
                  'modele': widget.model,
                  'pieceType': widget.pieceType,
                  'photos': widget.images.whereType<String>().toList(),
                  'video': widget.video,
                };
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final token = await user?.getIdToken();
                  final response = await http
                      .post(
                        Uri.parse(getBaseUrl() + '/articles/'),
                        headers: {
                          'Content-Type': 'application/json',
                          if (token != null) 'Authorization': 'Bearer $token',
                        },
                        body: jsonEncode(pieceData),
                      )
                      .timeout(const Duration(seconds: 8));
                  if (response.statusCode == 201 ||
                      response.statusCode == 200) {
                    if (!mounted) return;
                    _confettiController.play();
                    await Future.delayed(const Duration(seconds: 2));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SuccesScreen6()),
                    );
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erreur lors de l\'enregistrement en BDD',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  log('[DEBUG] Exception lors de l\'appel API (mastervac): $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur réseau ou serveur')),
                  );
                }
              },
              child: const Text(
                'Vendez votre pièce',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                log('[DEBUG] Bouton Faire une pub cliqué');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Une(
                          articleId: null,
                          articleType: 'piece',
                          articleTitle: widget.title,
                          articleYear: widget.year,
                          articleLocation: widget.location,
                          articlePrice: widget.price,
                          articleDescription: widget.description,
                          articleCompany: widget.company,
                          articleModel: widget.model,
                          articleFuelType: widget.fuelType,
                          articlePieceType: widget.pieceType,
                          articleImages:
                              widget.images.whereType<String>().toList(),
                          articleVideo: widget.video,
                        ),
                  ),
                );
              },
              child: const Text(
                'Faire une pub pour cette pièce',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 8,
            gravity: 0.3,
          ),
        ],
      );
    }
  }
}
