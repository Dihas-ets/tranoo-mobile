import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'finalisation_achat.dart';
import 'package:confetti/confetti.dart';
<<<<<<< HEAD
// import 'package:tranoo/data/screens/succes6.dart';

class PayementScreen extends StatefulWidget {
  const PayementScreen({super.key});
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';
// import 'package:tranoo/data/screens/succes6.dart';

class PayementScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const PayementScreen({super.key, required this.article});
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274

  @override
  State<PayementScreen> createState() => _PayementScreenState();
}

class _PayementScreenState extends State<PayementScreen>
    with SingleTickerProviderStateMixin {
  String? selectedPiece;
  TextEditingController numeroController = TextEditingController(text: null);
  String? selectedTransitaire;
<<<<<<< HEAD
=======
  Map<String, dynamic>? selectedTransitaireObj; // pour afficher le prix ensuite
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
  File? uploadedImage;
  String? uploadedFileName;
  bool hasUploadedFile = false;

  bool isCarburantChecked = false;
  bool isChauffeurChecked = false;
  bool isFraisDeRouteChecked = false;
  bool isTransitaireChecked = true;
<<<<<<< HEAD
=======
  // Champs déplacés en amont (cars_info/mastervac)
  bool get isEnTransitCheckedFromArticle =>
      (widget.article['modeLivraison']?.toString() ?? '') == 'transit';
  bool get isEnConsommationCheckedFromArticle =>
      (widget.article['modeLivraison']?.toString() ?? '') == 'consommation';
  String? get selectedCountryFromArticle =>
      widget.article['paysDestination']?.toString();
  String get detailsFromArticle =>
      (widget.article['detailsSupplementaires']?.toString() ?? '');
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274

  late AnimationController _animationController;
  late ConfettiController _confettiController;

<<<<<<< HEAD
=======
  List<Map<String, dynamic>> transitPropositions = [];
  bool isLoadingPropositions = false;

>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
  final List<String> pieces = [
    'Copie de la Carte d\'identité',
    'Permis de conduire',
    'Passeport',
  ];

<<<<<<< HEAD
  final List<Map<String, String>> transitaires = [
    {'name': 'Transitaire 1', 'price': '50,000 f'},
    {'name': 'Transitaire 2', 'price': '60,000 f'},
    {'name': 'Transitaire 3', 'price': '70,000 f'},
  ];
=======
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Charger les propositions de transit pour cet article
    _loadTransitPropositions();
  }

  Future<void> _loadTransitPropositions() async {
    setState(() {
      isLoadingPropositions = true;
    });

    try {
      print('[PayementScreen] Article reçu: ${widget.article}');
      final dynamic rawId = widget.article['_id'] ?? widget.article['id'];
      final String? articleId = rawId?.toString();
      print('[PayementScreen] ID de l\'article (fallback _id|id): $articleId');

      // Vérifier si l'article a un ID valide
      if (articleId == null || articleId.isEmpty) {
        print('[PayementScreen] Article sans ID valide.');
        setState(() {
          transitPropositions = [];
          isLoadingPropositions = false;
        });
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.baseUrl = getBaseUrl();

      final url = '/transit/propositions/$articleId';
      print('[PayementScreen] Appel API: $url');

      // Récupérer toutes les propositions pour cet article
      final response = await dio.get(url);

      print('[PayementScreen] Réponse API: ${response.statusCode}');
      print('[PayementScreen] Données reçues: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Map<String, dynamic>> items =
            data is List ? List<Map<String, dynamic>>.from(data) : [];
        setState(() {
          transitPropositions = items;
        });
        print(
          '[PayementScreen] Propositions chargées: ${transitPropositions.length}',
        );
      }
    } catch (e) {
      print('[PayementScreen] Erreur lors du chargement des propositions: $e');
      // Gérer l'erreur silencieusement
    } finally {
      setState(() {
        isLoadingPropositions = false;
      });
    }
  }
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        uploadedImage = File(image.path);
        uploadedFileName = image.name;
        hasUploadedFile = true;
      });
    }
  }

  @override
<<<<<<< HEAD
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
=======
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Informations supplémentaires',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pièce
                    _buildLabel('Pièce'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedPiece,
                      hint: 'Copie de la Carte d\'identité',
                      items: pieces,
                      onChanged:
                          (value) => setState(() => selectedPiece = value),
                    ),
                    const SizedBox(height: 24),

                    // Numéro de la pièce
                    _buildLabel('Numéro de la pièce'),
                    const SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      child: TextField(
                        controller: numeroController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          hintText: '245678399',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Choix du transitaire
                    _buildLabel('Choix du transitaire'),
                    const SizedBox(height: 8),
                    _buildTransitaireDropdown(),
<<<<<<< HEAD
                    const SizedBox(height: 24),
=======
                    const SizedBox(height: 16),
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274

                    // Télécharger des images
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Télécharger des images',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fichier téléchargé
                    if (hasUploadedFile)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              uploadedFileName!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.image, size: 24),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Processus d'achat nécessaires
                    _buildLabel('Processus d\'achat nécessaires'),
                    const SizedBox(height: 8),
                    _buildCheckbox('Carburant', isCarburantChecked, (value) {
                      setState(() {
                        isCarburantChecked = value!;
                      });
                    }),
                    _buildCheckbox('Chauffeur', isChauffeurChecked, (value) {
                      setState(() {
                        isChauffeurChecked = value!;
                      });
                    }),
                    _buildCheckbox('Frais de route', isFraisDeRouteChecked, (
                      value,
                    ) {
                      setState(() {
                        isFraisDeRouteChecked = value!;
                      });
                    }),
                    _buildCheckbox('Transitaire', isTransitaireChecked, (
                      value,
                    ) {
                      setState(() {
                        isTransitaireChecked = value!;
                      });
                    }),
                    const SizedBox(height: 16),

                    // Note
                    const Text(
                      'NB: Pour le service d\'entretien veuillez cliquer sur le bouton ci-dessous.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Bouton clignotant avec animation en utilisant FadeTransition
                    // et AnimationController
                    Center(
                      child: FadeTransition(
                        opacity: _animationController,
                        child: ElevatedButton(
                          onPressed: () {
                            // Action pour contacter le service d'entretien
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Contacter le service entretien',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildPaymentButton(context),
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
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, activeColor: Colors.amber),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          isExpanded: true,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTransitaireDropdown() {
<<<<<<< HEAD
=======
    if (isLoadingPropositions) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Chargement des propositions...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (transitPropositions.isEmpty) {
      // Vérifier si l'article a un ID valide
      if (widget.article['_id'] == null ||
          widget.article['_id'].toString().isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Article sans ID valide - propositions non disponibles',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        );
      }

      // Pour les articles réels sans propositions
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: const Text(
          'Aucune proposition de transit disponible pour cet article',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTransitaire,
          hint: const Text(
            'Choisissez votre transitaire',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          isExpanded: true,
          items:
<<<<<<< HEAD
              transitaires.map((transitaire) {
                return DropdownMenuItem<String>(
                  value: transitaire['name'],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(transitaire['name']!), // Nom du transitaire
                      Text(
                        transitaire['price']!, // Prix du transitaire
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
=======
              transitPropositions.map((proposition) {
                final transitaire = proposition['transitaire'];
                final montant = proposition['montant'];
                final nomTransitaire =
                    transitaire?['nom'] ??
                    transitaire?['entreprise'] ??
                    'Transitaire inconnu';
                final montantFormate = '${montant?.toString() ?? '0'} FCFA';

                return DropdownMenuItem<String>(
                  value: proposition['_id'],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          nomTransitaire,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        montantFormate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
<<<<<<< HEAD
          onChanged: (value) => setState(() => selectedTransitaire = value),
=======
          onChanged: (value) {
            setState(() {
              selectedTransitaire = value;
              selectedTransitaireObj = transitPropositions.firstWhere(
                (p) => p['_id'] == value,
                orElse: () => {},
              );
            });
          },
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
        ),
      ),
    );
  }

<<<<<<< HEAD
=======
  Future<void> _submitAchat(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');
      final token = await user.getIdToken();
      final dio = Dio();
      dio.options.baseUrl = getBaseUrl();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final dynamic rawId = widget.article['_id'] ?? widget.article['id'];
      final String? articleId = rawId?.toString();
      if (articleId == null || articleId.isEmpty) {
        throw Exception('Article sans ID valide');
      }

      // Upload optionnel de l'image vers Cloudinary si présente
      String? uploadedUrl;
      if (uploadedImage != null) {
        try {
          // ignore: use_build_context_synchronously
          uploadedUrl = await uploadImageToCloudinary(uploadedImage!);
        } catch (_) {}
      }

      final payload = {
        'articleId': articleId,
        'propositionTransitId': selectedTransitaire,
        'modeLivraison':
            (widget.article['modeLivraison']?.toString() ?? 'consommation'),
        'paysDestination': widget.article['paysDestination'],
        'detailsSupplementaires':
            (widget.article['detailsSupplementaires']?.toString() ?? ''),
        'services': {
          'carburant': isCarburantChecked,
          'chauffeur': isChauffeurChecked,
          'fraisRoute': isFraisDeRouteChecked,
          'transitaire': isTransitaireChecked,
        },
        'pieceType': selectedPiece,
        'pieceNumero': numeroController.text.trim(),
        'fichierNom': uploadedFileName,
        'fichierUrl': uploadedUrl,
      };

      final response = await dio.post('/achats', data: payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Aller à la finalisation avec données dynamiques
        final String imageUrl =
            (widget.article['photos'] is List &&
                    (widget.article['photos'] as List).isNotEmpty)
                ? (widget.article['photos'][0].toString())
                : '';
        final String titre = (widget.article['titre'] ?? '').toString();
        final String prixStr =
            (widget.article['prix'] ?? widget.article['price'] ?? '0')
                .toString();
        final int? tarifTransitaire =
            selectedTransitaireObj?['montant'] is num
                ? (selectedTransitaireObj!['montant'] as num).toInt()
                : null;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FinalisationAchatScreen(
                  articleImage: imageUrl,
                  articleTitle: titre,
                  articlePrice: prixStr,
                  tarifChoisit: tarifTransitaire?.toString(),
                ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
  Widget _buildPaymentButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: () {
          if (isCarburantChecked &&
              isChauffeurChecked &&
              isFraisDeRouteChecked &&
<<<<<<< HEAD
              isTransitaireChecked) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinalisationAchatScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Veuillez cocher toutes les cases (y compris Transitaire) avant de continuer.',
                ),
                backgroundColor: Colors.red,
              ),
=======
              isTransitaireChecked &&
              selectedTransitaire != null) {
            _submitAchat(context);
          } else {
            String message =
                'Veuillez cocher toutes les cases obligatoires et sélectionner un transitaire.';
            if (selectedTransitaire == null) {
              message = 'Veuillez sélectionner un transitaire.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
>>>>>>> 9a14c5c228b12a01b85c3371f5bdeaa34389f274
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'Valider pour finaliser',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
    );
  }
}
