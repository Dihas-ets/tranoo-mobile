// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'payement.dart'; // Plus utilisé
import 'package:tranoo/services/user_service.dart'; // Importez UserService pour gérer les rôles
import 'package:tranoo/services/cart_service.dart';
import 'cart_page.dart';
import 'order_summary.dart';
// import 'package:tranoo/data/screens/paymentscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/utils/auth_dialog.dart';
import 'package:confetti/confetti.dart';
// import 'verification_payment.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';
import 'package:tranoo/utils/article_view_helper.dart';
import 'package:tranoo/utils/auth_config.dart';
import 'package:url_launcher/url_launcher.dart';

// Fonction utilitaire pour formater les prix avec des séparateurs de milliers
String formatPrice(dynamic price) {
  if (price == null) return '0';
  try {
    final priceNum = double.tryParse(price.toString()) ?? 0;
    final priceStr = priceNum.toStringAsFixed(0);
    final reversed = priceStr.split('').reversed.join('');
    final withDots = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (Match m) => '${m[0]}.',
    );
    return withDots.split('').reversed.join('');
  } catch (e) {
    return price.toString();
  }
}

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

  TextEditingController detailsController = TextEditingController();
  // Champs de livraison/lieu supprimés - gérés dans OrderSummaryPage
  late ConfettiController _confettiController;
  bool _isOnline = false;
  String? _sellerPhone;

  @override
  void initState() {
    super.initState();
    trackArticleView(widget.id);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _pageController = PageController(initialPage: _currentImageIndex);
    _loadArticleDetails();
  }

  String? _extractSellerPhone(Map<String, dynamic> data) {
    final fournisseur = data['fournisseur'];
    if (fournisseur is Map) {
      final phone = fournisseur['telephone']?.toString().trim() ?? '';
      if (phone.isNotEmpty) return phone;
    }
    final vendeur = data['vendeur'];
    if (vendeur is Map) {
      final phone = vendeur['telephone']?.toString().trim() ?? '';
      if (phone.isNotEmpty) return phone;
    }
    return null;
  }

  String _digitsOnly(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  void _showSellerContactUnavailable() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Numéro du vendeur indisponible')),
    );
  }

  Future<void> _openSellerWhatsApp() async {
    final phone = _sellerPhone?.trim() ?? '';
    if (phone.isEmpty) {
      _showSellerContactUnavailable();
      return;
    }
    final digits = _digitsOnly(phone);
    if (digits.isEmpty) {
      _showSellerContactUnavailable();
      return;
    }
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
    );
  }

  Future<void> _callSeller() async {
    final phone = _sellerPhone?.trim() ?? '';
    if (phone.isEmpty) {
      _showSellerContactUnavailable();
      return;
    }
    final digits = _digitsOnly(phone);
    if (digits.isEmpty) {
      _showSellerContactUnavailable();
      return;
    }
    final uri = Uri.parse('tel:+$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible de passer un appel')),
    );
  }

  Future<void> _startDeliveryFlow() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      showAuthDialog(
        context,
        message: 'Connectez-vous pour commander avec livraison',
      );
      return;
    }
    final firstImage = widget.images.whereType<String>().firstWhere(
          (e) => e.startsWith('http'),
          orElse: () => '',
        );
    await CartService().clear();
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderSummaryPage()),
    );
  }

  Future<void> _loadArticleDetails() async {
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
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final statut = (data['statut'] ?? '').toString().toLowerCase();
        if (!mounted) return;
        setState(() {
          _isOnline = (statut == 'en_ligne');
          _sellerPhone = _extractSellerPhone(data);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _startDeliveryFlow,
        backgroundColor: Colors.blue,
        tooltip: 'Commander avec livraison',
        child: const Icon(Icons.local_shipping, color: Colors.white),
      ),
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
    final hasImages = widget.images.isNotEmpty;
    final hasVideo = widget.video != null && widget.video!.isNotEmpty;
    
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: hasImages
              ? PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, index) {
              final String img = widget.images[index] ?? '';
              final Widget child = img.startsWith('http')
                  ? Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
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
                          errorBuilder: (c, e, s) => Container(
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
                )
              : hasVideo
                  ? VideoPreviewPlaceholder(
                      videoUrl: widget.video,
                      iconSize: 60,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 80),
                      ),
                    ),
        ),
        // Icônes verticales (droite)
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              // WhatsApp
              GestureDetector(
                onTap: _openSellerWhatsApp,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/images/whatsapp_icon.png',
                    width: 22,
                    height: 22,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.chat_bubble_outline,
                      color: Color(0xFF25D366),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Appel téléphonique
              GestureDetector(
                onTap: _callSeller,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.phone,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasImages && widget.images.length > 1)
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
                  final Widget child = img.startsWith('http')
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
              AuthConfig.displayEntreprise(
                widget.company.isNotEmpty ? widget.company : null,
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.price.isNotEmpty ? '${formatPrice(widget.price)} FCFA' : 'Non renseigné',
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

  Widget _buildActionButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _openSellerWhatsApp,
            icon: const Icon(Icons.chat),
            label: const Text(
              'Contacter le vendeur',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _callSeller,
            icon: const Icon(Icons.phone),
            label: const Text('Appeler le vendeur'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Utilisez le bouton bleu (livraison) à droite pour commander avec livraison.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
