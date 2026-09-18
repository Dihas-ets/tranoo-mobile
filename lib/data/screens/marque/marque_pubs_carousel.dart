import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tranoo/data/models/pub.dart';
import 'package:tranoo/widgets/cached_media_image.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';

/// Carrousel « À la une » de l'accueil Marque.
class MarquePubsCarousel extends StatelessWidget {
  const MarquePubsCarousel({
    super.key,
    required this.pubs,
    required this.isLoading,
    required this.pageController,
    this.error,
    required this.onOpenLink,
    required this.onOpenFlyer,
  });

  final List<Pub> pubs;
  final bool isLoading;
  final String? error;
  final PageController pageController;
  final ValueChanged<String> onOpenLink;
  final ValueChanged<String> onOpenFlyer;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SkeletonPresets.articleGrid(count: 2);
    }
    if (error != null) {
      return Center(child: Text(error!));
    }
    if (pubs.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: PageView.builder(
            controller: pageController,
            padEnds: true,
            itemCount: pubs.length,
            itemBuilder: (context, index) {
              final pub = pubs[index];
              final hasLink = (pub.lien ?? '').trim().isNotEmpty;
              final card = Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.black,
                    child: pub.media.isNotEmpty
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: CachedMediaImage(
                                  url: pub.media[0],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  cloudinaryWidthPx: 280,
                                ),
                              ),
                            ],
                          )
                        : Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 80),
                          ),
                  ),
                ),
              );

              return GestureDetector(
                onTap: () {
                  if (hasLink) {
                    onOpenLink(pub.lien!.trim());
                  } else {
                    onOpenFlyer(pub.media.isNotEmpty ? pub.media[0] : '');
                  }
                },
                onDoubleTap: () {
                  if (hasLink) {
                    onOpenFlyer(pub.media.isNotEmpty ? pub.media[0] : '');
                  }
                },
                child: card,
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        if (pubs.length > 1)
          SmoothPageIndicator(
            controller: pageController,
            count: pubs.length,
            effect: JumpingDotEffect(
              activeDotColor: Color(0xFFF8BF13),
              dotColor: Colors.grey.shade300,
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
      ],
    );
  }
}
