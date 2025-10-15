import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'finalisation_achat.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';
// import 'package:tranoo/data/screens/succes6.dart';

String getBaseUrl() {
  return UserService().dio.options.baseUrl;
}

class PayementScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const PayementScreen({super.key, required this.article});

  @override
  State<PayementScreen> createState() => _PayementScreenState();
}

class _PayementScreenState extends State<PayementScreen>
    with SingleTickerProviderStateMixin {
  String? selectedPiece;
  TextEditingController numeroController = TextEditingController(text: null);
  String? selectedTransitaire;
  Map<String, dynamic>? selectedTransitaireObj; // pour afficher le prix ensuite
  File? uploadedImage;
  String? uploadedFileName;
  bool hasUploadedFile = false;

  bool isCarburantChecked = false;
  bool isChauffeurChecked = false;
  bool isFraisDeRouteChecked = false;
  bool isTransitaireChecked = true;
  // Champs déplacés en amont (cars_info/mastervac)
  bool get isEnTransitCheckedFromArticle =>
      (widget.article['modeLivraison']?.toString() ?? '') == 'transit';
  bool get isEnConsommationCheckedFromArticle =>
      (widget.article['modeLivraison']?.toString() ?? '') == 'consommation';
  String? get selectedCountryFromArticle =>
      widget.article['paysDestination']?.toString();
  String get detailsFromArticle =>
      (widget.article['detailsSupplementaires']?.toString() ?? '');

  late AnimationController _animationController;
  late ConfettiController _confettiController;

  List<Map<String, dynamic>> transitPropositions = [];
  bool isLoadingPropositions = false;

  final List<String> pieces = [
    'Copie de la Carte d\'identité',
    'Permis de conduire',
    'Passeport',
  ];

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

                    // Choix du transitaire (masqué si dédouanement = true)
                    if (widget.article['dedouanement'] != true) ...[
                      _buildLabel('Choix du transitaire'),
                      const SizedBox(height: 8),
                      _buildTransitaireSelector(),
                      const SizedBox(height: 16),
                    ],

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
                    // Checkbox transitaire masquée si dédouanement = true
                    if (widget.article['dedouanement'] != true)
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

  Widget _buildTransitaireSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedTransitaireObj != null
                  ? selectedTransitaireObj!['nom'] ?? 'Prestataire sélectionné'
                  : 'Choisissez un prestataire de transit',
              style: TextStyle(
                color:
                    selectedTransitaireObj != null ? Colors.black : Colors.grey,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {
              _showTransitaireBottomSheet(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFFF8BF13),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Voir +'),
          ),
        ],
      ),
    );
  }

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

      final bool dedouanementFait = widget.article['dedouanement'] == true;
      
      final payload = {
        'articleId': articleId,
        if (!dedouanementFait) 'propositionTransitId': selectedTransitaire,
        'modeLivraison':
            (widget.article['modeLivraison']?.toString() ?? 'consommation'),
        'paysDestination': widget.article['paysDestination'],
        'detailsSupplementaires':
            (widget.article['detailsSupplementaires']?.toString() ?? ''),
        'services': {
          'carburant': isCarburantChecked,
          'chauffeur': isChauffeurChecked,
          'fraisRoute': isFraisDeRouteChecked,
          if (!dedouanementFait) 'transitaire': isTransitaireChecked,
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

  Widget _buildPaymentButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: () {
          final bool dedouanementFait = widget.article['dedouanement'] == true;
          final bool transitaireRequis = !dedouanementFait;
          
          bool validationOk = isCarburantChecked &&
              isChauffeurChecked &&
              isFraisDeRouteChecked;
          
          if (transitaireRequis) {
            validationOk = validationOk && isTransitaireChecked && selectedTransitaire != null;
          }
          
          if (validationOk) {
            _submitAchat(context);
          } else {
            String message = 'Veuillez cocher toutes les cases obligatoires.';
            if (transitaireRequis && selectedTransitaire == null) {
              message = 'Veuillez sélectionner un transitaire.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
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

  void _showTransitaireBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => TransitaireBottomSheet(
            transitPropositions: transitPropositions,
            onTransitaireSelected: (transitaire) {
              setState(() {
                selectedTransitaire = transitaire['_id'] ?? transitaire['id'];
                selectedTransitaireObj = transitaire;
              });
              Navigator.pop(context);
            },
          ),
    );
  }
}

class TransitaireBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> transitPropositions;
  final Function(Map<String, dynamic>) onTransitaireSelected;

  const TransitaireBottomSheet({
    super.key,
    required this.transitPropositions,
    required this.onTransitaireSelected,
  });

  @override
  State<TransitaireBottomSheet> createState() => _TransitaireBottomSheetState();
}

class _TransitaireBottomSheetState extends State<TransitaireBottomSheet> {
  List<Map<String, dynamic>> transitaires = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransitaires();
  }

  Future<void> _loadTransitaires() async {
    // Données statiques pour test
    await Future.delayed(const Duration(milliseconds: 500));
    
    final List<Map<String, dynamic>> staticData = [
      {
        '_id': '1',
        'title': 'Express Transit Pro',
        'description': 'Service premium certifié ⭐ - Livraison rapide et sécurisée',
        'time': '6h30',
        'price': '25 000 F',
        'capacity': 4,
        'hasSubscription': true,
      },
      {
        '_id': '2', 
        'title': 'Rapid Logistics',
        'description': 'Service premium certifié ⭐ - Transport de qualité supérieure',
        'time': '7h15',
        'price': '28 500 F',
        'capacity': 6,
        'hasSubscription': true,
      },
      {
        '_id': '3',
        'title': 'Standard Transport',
        'description': 'Service standard de qualité - Tarif économique',
        'time': '8h45',
        'price': '18 000 F',
        'capacity': 4,
        'hasSubscription': false,
      },
      {
        '_id': '4',
        'title': 'City Cargo',
        'description': 'Service standard de qualité - Transport urbain',
        'time': '9h20',
        'price': '22 000 F',
        'capacity': 4,
        'hasSubscription': false,
      },
      {
        '_id': '5',
        'title': 'Quick Delivery',
        'description': 'Service standard de qualité - Livraison dans la journée',
        'time': '10h00',
        'price': '20 500 F',
        'capacity': 4,
        'hasSubscription': false,
      },
    ];
    
    setState(() {
      transitaires = staticData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final premiumTransitaires = transitaires.where((t) => t['hasSubscription'] == true).toList();
    final standardTransitaires = transitaires.where((t) => t['hasSubscription'] != true).toList();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête noir
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Text(
              "Choisissez votre transitaire",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF8BF13),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Premium
                        if (premiumTransitaires.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: const Text(
                              "Nos meilleurs transitaires",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF8BF13),
                              ),
                            ),
                          ),
                          ...premiumTransitaires.map((transitaire) => _buildTransitaireCard(transitaire)),
                          const SizedBox(height: 24),
                        ],
                        
                        // Section Standard
                        if (standardTransitaires.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              "Autres transitaires",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...standardTransitaires.map((transitaire) => _buildTransitaireCard(transitaire)),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransitaireCard(Map<String, dynamic> transitaire) {
    final hasSubscription = transitaire['hasSubscription'] ?? false;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: hasSubscription 
            ? Border.all(color: const Color(0xFFF8BF13), width: 2)
            : Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => widget.onTransitaireSelected(transitaire),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: hasSubscription 
                ? const Color(0xFFF8BF13).withOpacity(0.2)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.local_shipping,
            color: hasSubscription 
                ? const Color(0xFFF8BF13)
                : Colors.grey[600],
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                "${transitaire['title']} 🚘 ${transitaire['capacity']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasSubscription) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.workspace_premium,
                size: 16,
                color: Color(0xFFF8BF13),
              ),
            ],
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: hasSubscription 
                    ? const Color(0xFFF8BF13)
                    : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasSubscription ? 'PREMIUM' : 'DISPONIBLE',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transitaire['time']),
            Text(
              transitaire['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

}

final List<Map<String, String>> _demoTransitItems = [
  {
    'title': 'UberX',
    'time': '8h15',
    'price': '25 000 F',
    'desc': 'Économique, rapide et fiable',
  },
  {
    'title': 'Taxi',
    'time': '8h18',
    'price': '16 500 F',
    'desc': 'Tarif au compteur, accès rapide',
  },
  {
    'title': 'Van',
    'time': '8h20',
    'price': '28 500 F',
    'desc': 'Haut de gamme jusqu’à 6 passagers',
  },
  {
    'title': 'XL',
    'time': '8h20',
    'price': '29 600 F',
    'desc': 'Abordable pour groupes jusqu’à 6',
  },
  {
    'title': 'Berline',
    'time': '8h20',
    'price': '39 700 F',
    'desc': 'Haut de gamme chauffeurs mieux notés',
  },
];
