import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tranoo/utils/auth_config.dart';
import 'package:tranoo/utils/catalog_display.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/widgets/spec_info_card.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';

/// Nuancier partagé (détails voiture / moto).
const Map<String, Color> catalogVehicleColors = {
  'Blanc': Colors.white,
  'Noir': Colors.black,
  'Gris': Colors.grey,
  'Argenté': Color(0xFFC0C0C0),
  'Rouge': Colors.red,
  'Bleu': Colors.blue,
  'Vert': Colors.green,
  'Jaune': Colors.yellow,
  'Orange': Colors.orange,
  'Violet': Colors.purple,
  'Rose': Colors.pink,
  'Marron': Colors.brown,
  'Beige': Color(0xFFF5F5DC),
  'Bordeaux': Color(0xFF800020),
  'Bleu marine': Color(0xFF000080),
  'Vert foncé': Color(0xFF006400),
  'Gris foncé': Color(0xFF696969),
  'Gris clair': Color(0xFFD3D3D3),
  'Rouge foncé': Color(0xFF8B0000),
  'Bleu clair': Color(0xFFADD8E6),
  'Vert clair': Color(0xFF90EE90),
  'Jaune clair': Color(0xFFFFFFE0),
  'Orange foncé': Color(0xFFFF8C00),
  'Violet foncé': Color(0xFF4B0082),
  'Rose foncé': Color(0xFFC71585),
  'Marron clair': Color(0xFFD2B48C),
  'Crème': Color(0xFFFFFDD0),
  'Ivoire': Color(0xFFFFFFF0),
  'Champagne': Color(0xFFF7E7CE),
  'Bronze': Color(0xFFCD7F32),
  'Doré': Color(0xFFFFD700),
  'Cuivre': Color(0xFFB87333),
  'Turquoise': Color(0xFF40E0D0),
  'Cyan': Color(0xFF00FFFF),
  'Magenta': Color(0xFFFF00FF),
  'Lime': Color(0xFF00FF00),
  'Indigo': Color(0xFF4B0082),
  'Olive': Color(0xFF808000),
  'Saumon': Color(0xFFFA8072),
  'Corail': Color(0xFFFF7F50),
  'Pêche': Color(0xFFFFDAB9),
  'Lavande': Color(0xFFE6E6FA),
  'Menthe': Color(0xFF98FB98),
  'Bleu pétrole': Color(0xFF008B8B),
  'Vert olive': Color(0xFF6B8E23),
  'Rouge brique': Color(0xFFB22222),
  'Bleu acier': Color(0xFF4682B4),
  'Vert forêt': Color(0xFF228B22),
  'Prune': Color(0xFFDDA0DD),
  'Kaki': Color(0xFFF0E68C),
  'Anthracite': Color(0xFF36454F),
  'Perle': Color(0xFFEAE0C8),
};

bool catalogIsNewCondition(String? value) {
  final lower = (value ?? '').toLowerCase();
  return lower == 'nouveau' || lower == 'neuf' || lower == 'new';
}

String catalogConditionLabel({
  required String? value,
  required String newLabel,
  required String usedLabel,
  required String fallback,
}) {
  if (catalogIsNewCondition(value)) return newLabel;
  final lower = (value ?? '').toLowerCase();
  if (lower == 'occasion' || lower == 'used') return usedLabel;
  return value ?? fallback;
}

String catalogSpecValue(String? value, String fallback) {
  if (value != null && value.isNotEmpty) return value;
  return fallback;
}

void showCatalogFullscreenImageViewer(
  BuildContext context, {
  required List<String> images,
  required int startIndex,
}) {
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
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: TranooNetworkImage(
                      url: images[index],
                      fit: BoxFit.contain,
                      cloudinaryWidthPx: cloudinaryWidthPx(context),
                    ),
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
                  count: images.length,
                  effect: const WormEffect(
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

/// Titre + entreprise + prix (détail véhicule).
class CatalogDetailHeader extends StatelessWidget {
  const CatalogDetailHeader({
    super.key,
    required this.screenWidth,
    required this.titre,
    required this.entreprise,
    required this.prix,
    required this.notProvidedLabel,
  });

  final double screenWidth;
  final String? titre;
  final String? entreprise;
  final String? prix;
  final String notProvidedLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (titre != null && titre!.isNotEmpty) ? titre! : notProvidedLabel,
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          AuthConfig.displayEntreprise(entreprise),
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          (prix != null && prix!.isNotEmpty)
              ? '${formatPrice(prix!)} FCFA'
              : notProvidedLabel,
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }
}

class CatalogDetailSpecGrid extends StatelessWidget {
  const CatalogDetailSpecGrid({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: cards,
    );
  }
}

Widget catalogSpecCard(String title, String value, IconData icon) {
  return SpecInfoCard(title: title, value: value, icon: icon);
}

Widget catalogSpecCardWithColor(
  String title,
  String value,
  IconData icon,
  String? couleur,
) {
  Widget? swatch;
  if (couleur != null && catalogVehicleColors.containsKey(couleur)) {
    final c = catalogVehicleColors[couleur]!;
    swatch = Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: c,
        border: Border.all(
          color: c == Colors.white ? Colors.grey : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
  return SpecInfoCard(
    title: title,
    value: value,
    icon: icon,
    valueTrailing: swatch,
  );
}

/// Galerie média détail (PageView + badges + actions latérales).
class CatalogDetailMediaSection extends StatelessWidget {
  const CatalogDetailMediaSection({
    super.key,
    required this.screenHeight,
    required this.pageController,
    required this.images,
    required this.videos,
    required this.primaryVideo,
    required this.conditionLabel,
    required this.isNewCondition,
    required this.onPageChanged,
    required this.onImageTap,
    required this.onVideoPageTap,
    required this.onFavoriteTap,
    required this.onPlayVideoTap,
    required this.onWhatsAppTap,
    required this.onCallTap,
  });

  final double screenHeight;
  final PageController pageController;
  final List<String> images;
  final List<String> videos;
  final String? primaryVideo;
  final String conditionLabel;
  final bool isNewCondition;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onImageTap;
  final ValueChanged<String?> onVideoPageTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onPlayVideoTap;
  final VoidCallback onWhatsAppTap;
  final VoidCallback onCallTap;

  int get _imagesCount => images.length;
  int get _videosCount => videos.length;
  int get _totalMediaCount => _imagesCount + _videosCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: screenHeight * 0.4,
          width: double.infinity,
          child: _totalMediaCount > 0
              ? PageView.builder(
                  controller: pageController,
                  itemCount: _totalMediaCount,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    if (index < _imagesCount) {
                      final hasImage =
                          index < images.length && images[index].isNotEmpty;
                      if (!hasImage) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 80),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () => onImageTap(index),
                        child: ClipRect(
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: TranooNetworkImage(
                              url: images[index],
                              fit: BoxFit.cover,
                              cloudinaryWidthPx: cloudinaryWidthPx(context),
                            ),
                          ),
                        ),
                      );
                    }
                    final videoIndex = index - _imagesCount;
                    final videoUrl = videoIndex < videos.length
                        ? videos[videoIndex]
                        : primaryVideo;
                    return VideoPreviewPlaceholder(
                      videoUrl: videoUrl,
                      iconSize: 60,
                      enablePreviewFrame: false,
                      onTap: () => onVideoPageTap(videoUrl),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 80),
                  ),
                ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isNewCondition
                  ? Colors.purple
                  : const Color(0xFFF8BF13),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              conditionLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              GestureDetector(
                onTap: onFavoriteTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onPlayVideoTap,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      primaryVideo != null ? Colors.white : Colors.grey[300],
                  child: Icon(
                    Icons.play_circle_fill,
                    color: primaryVideo != null ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onWhatsAppTap,
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
              GestureDetector(
                onTap: onCallTap,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.phone,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_totalMediaCount > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: _totalMediaCount,
                effect: const JumpingDotEffect(
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
}
