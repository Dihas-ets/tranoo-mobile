// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'payement.dart'; // Plus utilisé
import 'package:tranoo/services/user_service.dart'; // Importez UserService pour gérer les rôles
import 'package:tranoo/services/cart_service.dart';
import 'cart_page.dart';
import 'package:tranoo/utils/role_redirect.dart';
// import 'package:tranoo/data/screens/paymentscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/data/screens/succes6.dart';
import 'package:confetti/confetti.dart';
import 'dart:developer';
import 'une.dart'; // Import pour la page de demande de pub
// import 'verification_payment.dart';

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
  late PageController _pageController;
  // SUPPRIME la liste statique _images

  // Définition des booléens nécessaires
  bool isNew = false;
  bool is2023 = false;
  bool isGarantieIncluse = false;
  bool isLivraisonRapide = false;
  TextEditingController detailsController = TextEditingController();
  // Champs de livraison/lieu supprimés - gérés dans OrderSummaryPage
  late ConfettiController _confettiController;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _pageController = PageController(initialPage: _currentImageIndex);
    _loadArticleStatut();
  }

  Future<void> _loadArticleStatut() async {
    try {
      final id = widget.id;
      if (id == null || id.isEmpty) return;
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final res = await http.get(
        Uri.parse(getBaseUrl() + '/articles/' + id),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer ' + token,
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final statut = (data['statut'] ?? '').toString().toLowerCase();
        if (!mounted) return;
        setState(() {
          _isOnline = (statut == 'en_ligne');
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
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
        // Icône Panier avec compteur
        AnimatedBuilder(
          animation: CartService(),
          builder: (context, _) {
            final qty = CartService().totalQuantity;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
                if (qty > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        qty.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
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
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, index) {
              final String img = widget.images[index] ?? '';
              final Widget child =
                  img.startsWith('http')
                      ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (c, e, s) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Image non disponible'),
                              ),
                            ),
                      )
                      : (img.isNotEmpty
                          ? Image.asset(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (c, e, s) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text('Image non disponible'),
                                  ),
                                ),
                          )
                          : Image.asset(
                            'assets/images/image_not_found.png',
                            fit: BoxFit.cover,
                          ));
              return GestureDetector(
                onTap: () => _openImageViewer(index),
                child: ClipRect(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.images.length,
                effect: JumpingDotEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white70,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openImageViewer(int startIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (ctx) {
        final controller = PageController(initialPage: startIndex);
        return GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  final String img = widget.images[index] ?? '';
                  final Widget child =
                      img.startsWith('http')
                          ? Image.network(img, fit: BoxFit.contain)
                          : (img.isNotEmpty
                              ? Image.asset(img, fit: BoxFit.contain)
                              : const Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 80,
                              ));
                  return Center(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 5,
                      child: child,
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: controller,
                    count: widget.images.length,
                    effect: WormEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white24,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    return const SizedBox.shrink(); // Supprimé - géré dans OrderSummaryPage
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
          onPressed: () async {
            // Ajout au panier (sans validation des champs de livraison)
            final firstImage = widget.images.whereType<String>().firstWhere(
              (e) => e.startsWith('http'),
              orElse: () => '',
            );
            await CartService().addOrIncrement(
              CartItem(
                articleId: (widget.id ?? '').toString(),
                title: widget.title,
                imageUrl: firstImage.isEmpty ? null : firstImage,
                priceLabel: widget.price,
                pieceType: widget.pieceType,
                model: widget.model,
                fuelType: widget.fuelType,
                quantity: 1,
              ),
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Article ajouté au panier'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Voir le panier',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          child: const Text(
            'Ajouter au panier',
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
          onPressed: () async {
            // Ajout au panier (sans validation des champs de livraison)
            final firstImage = widget.images.whereType<String>().firstWhere(
              (e) => e.startsWith('http'),
              orElse: () => '',
            );
            await CartService().addOrIncrement(
              CartItem(
                articleId: (widget.id ?? '').toString(),
                title: widget.title,
                imageUrl: firstImage.isEmpty ? null : firstImage,
                priceLabel: widget.price,
                pieceType: widget.pieceType,
                model: widget.model,
                fuelType: widget.fuelType,
                quantity: 1,
              ),
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Article ajouté au panier'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Voir le panier',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          child: const Text(
            'Ajouter au panier',
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
                backgroundColor: _isOnline ? Colors.grey[300] : Colors.amber,
                foregroundColor: _isOnline ? Colors.grey[600] : Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed:
                  _isOnline
                      ? null
                      : () async {
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
                                  if (token != null)
                                    'Authorization': 'Bearer $token',
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
                              MaterialPageRoute(
                                builder: (context) => SuccesScreen6(),
                              ),
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
                          log(
                            '[DEBUG] Exception lors de l\'appel API (mastervac): $e',
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur réseau ou serveur')),
                          );
                        }
                      },
              child: const Text(
                'Vendez votre pièce',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          isStandalone: false,
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
