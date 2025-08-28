import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'finalisation_achat.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
// import 'package:tranoo/data/screens/succes6.dart';

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
  File? uploadedImage;
  String? uploadedFileName;
  bool hasUploadedFile = false;

  bool isCarburantChecked = false;
  bool isChauffeurChecked = false;
  bool isFraisDeRouteChecked = false;
  bool isTransitaireChecked = true;
  bool isEnConsommationChecked = false;
  bool isEnTransitChecked = false;

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
      print('[PayementScreen] ID de l\'article: ${widget.article['_id']}');

      // Vérifier si l'article a un ID valide
      if (widget.article['_id'] == null ||
          widget.article['_id'].toString().isEmpty) {
        print(
          '[PayementScreen] Article sans ID valide: ${widget.article['_id']}',
        );
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

      final url = '/transit/propositions/${widget.article['_id']}';
      print('[PayementScreen] Appel API: $url');

      // Récupérer toutes les propositions pour cet article
      final response = await dio.get(url);

      print('[PayementScreen] Réponse API: ${response.statusCode}');
      print('[PayementScreen] Données reçues: ${response.data}');

      if (response.statusCode == 200) {
        setState(() {
          transitPropositions = List<Map<String, dynamic>>.from(response.data);
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

                    // Choix du transitaire
                    _buildLabel('Choix du transitaire'),
                    const SizedBox(height: 8),
                    _buildTransitaireDropdown(),
                    const SizedBox(height: 16),

                    // Checkboxes pour le mode de livraison
                    _buildCheckbox('En Consommation', isEnConsommationChecked, (
                      value,
                    ) {
                      setState(() {
                        isEnConsommationChecked = value!;
                        // Si on coche "En Consommation", on décoche "En Transit"
                        if (value == true) {
                          isEnTransitChecked = false;
                        }
                      });
                    }),
                    _buildCheckbox('En Transit', isEnTransitChecked, (value) {
                      setState(() {
                        isEnTransitChecked = value!;
                        // Si on coche "En Transit", on décoche "En Consommation"
                        if (value == true) {
                          isEnConsommationChecked = false;
                        }
                      });
                    }),
                    const SizedBox(height: 24),

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
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) => setState(() => selectedTransitaire = value),
        ),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: () {
          if (isCarburantChecked &&
              isChauffeurChecked &&
              isFraisDeRouteChecked &&
              isTransitaireChecked &&
              (isEnConsommationChecked || isEnTransitChecked) &&
              selectedTransitaire != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinalisationAchatScreen(),
              ),
            );
          } else {
            String message =
                'Veuillez cocher toutes les cases obligatoires et sélectionner un transitaire.';
            if (!isEnConsommationChecked && !isEnTransitChecked) {
              message =
                  'Veuillez choisir un mode de livraison (En Consommation ou En Transit).';
            } else if (selectedTransitaire == null) {
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
}
