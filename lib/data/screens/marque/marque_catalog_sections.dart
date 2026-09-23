import 'package:flutter/material.dart';
import 'package:tranoo/data/models/article.dart';
import 'package:tranoo/data/models/article_voiture.dart';
import 'package:tranoo/data/models/pub.dart';
import 'package:tranoo/utils/pub_validity.dart';
import 'package:tranoo/widgets/cached_media_image.dart';
import 'package:tranoo/widgets/catalog_article_grid_card.dart';
import 'package:tranoo/widgets/catalog_piece_grid_card.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';

Widget _sectionHeader({
  required String title,
  required String seeAllLabel,
  required VoidCallback onSeeAll,
  Color titleColor = const Color(0xFF040415),
  Widget? leading,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            seeAllLabel,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

Widget _emptyMessage(String text) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ),
  );
}

/// Section voitures recommandées (liste horizontale).
class MarqueVoituresSection extends StatelessWidget {
  const MarqueVoituresSection({
    super.key,
    required this.voitures,
    required this.isLoading,
    required this.isVendeur,
    required this.conditionNewLabel,
    required this.conditionUsedLabel,
    required this.defaultTransmission,
    required this.onSeeAll,
    required this.onVehicleTap,
    this.error,
  });

  final List<ArticleVoiture> voitures;
  final bool isLoading;
  final String? error;
  final bool isVendeur;
  final String conditionNewLabel;
  final String conditionUsedLabel;
  final String defaultTransmission;
  final VoidCallback onSeeAll;
  final ValueChanged<ArticleVoiture> onVehicleTap;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.44;
    final cardHeight =
        cardWidth / CatalogArticleGridCard.aspectRatioForWidth(cardWidth * 2.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: isVendeur ? 'Mes voitures' : 'Véhicules',
          seeAllLabel: 'Voir tout',
          onSeeAll: onSeeAll,
        ),
        if (isLoading) SkeletonPresets.articleHorizontalStrip(count: 3),
        if (error != null) Center(child: Text(error!)),
        if (!isLoading && error == null)
          voitures.isEmpty
              ? _emptyMessage(
                  isVendeur
                      ? "Vous n'avez aucune voiture en ligne"
                      : 'Aucune voiture disponible pour le moment.',
                )
              : SizedBox(
                  height: cardHeight + 4,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: voitures.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final voiture = voitures[index];
                      return CatalogArticleGridCard(
                        article: voiture.toArticleMap(),
                        isMoto: false,
                        width: cardWidth,
                        conditionNewLabel: conditionNewLabel,
                        conditionUsedLabel: conditionUsedLabel,
                        defaultTransmission: defaultTransmission,
                        onTap: () => onVehicleTap(voiture),
                      );
                    },
                  ),
                ),
      ],
    );
  }
}

/// Section motos (liste horizontale).
class MarqueMotosSection extends StatelessWidget {
  const MarqueMotosSection({
    super.key,
    required this.motos,
    required this.isLoading,
    required this.isVendeur,
    required this.conditionNewLabel,
    required this.conditionUsedLabel,
    required this.onSeeAll,
    required this.onMotoTap,
    this.error,
  });

  final List<ArticleVoiture> motos;
  final bool isLoading;
  final String? error;
  final bool isVendeur;
  final String conditionNewLabel;
  final String conditionUsedLabel;
  final VoidCallback onSeeAll;
  final ValueChanged<ArticleVoiture> onMotoTap;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.44;
    final cardHeight =
        cardWidth / CatalogArticleGridCard.aspectRatioForWidth(cardWidth * 2.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: isVendeur ? 'Mes motos' : 'Motos',
          seeAllLabel: 'Voir plus',
          onSeeAll: onSeeAll,
        ),
        if (isLoading) SkeletonPresets.articleHorizontalStrip(count: 3),
        if (error != null) Center(child: Text(error!)),
        if (!isLoading && error == null)
          motos.isEmpty
              ? _emptyMessage(
                  isVendeur
                      ? "Vous n'avez aucune moto en ligne"
                      : 'Aucune moto disponible pour le moment.',
                )
              : SizedBox(
                  height: cardHeight + 4,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: motos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final moto = motos[index];
                      return CatalogArticleGridCard(
                        article: moto.toArticleMap(),
                        isMoto: true,
                        width: cardWidth,
                        conditionNewLabel: conditionNewLabel,
                        conditionUsedLabel: conditionUsedLabel,
                        onTap: () => onMotoTap(moto),
                      );
                    },
                  ),
                ),
      ],
    );
  }
}

/// Section pièces détachées (liste horizontale).
class MarquePiecesSection extends StatelessWidget {
  const MarquePiecesSection({
    super.key,
    required this.pieces,
    required this.isLoading,
    required this.onSeeAll,
    required this.onPieceTap,
    this.error,
  });

  final List<Article> pieces;
  final bool isLoading;
  final String? error;
  final VoidCallback onSeeAll;
  final ValueChanged<Article> onPieceTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Pièces détachées',
          seeAllLabel: 'Voir plus',
          onSeeAll: onSeeAll,
        ),
        if (isLoading) SkeletonPresets.articleGrid(count: 2),
        if (error != null) Center(child: Text(error!)),
        if (!isLoading && error == null)
          pieces.isEmpty
              ? _emptyMessage('Aucune pièce en ligne actuellement')
              : SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pieces.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final piece = pieces[index];
                      final isNew =
                          (piece.pieceType ?? '').toLowerCase() == 'nouveau';
                      return CatalogPieceGridCard(
                        title: piece.title,
                        company: piece.company,
                        prix: piece.price,
                        images: piece.images,
                        video: piece.video,
                        views: piece.views,
                        badgeText: isNew ? 'Nouveau' : 'Occasion',
                        badgeColor: isNew
                            ? Colors.purple
                            : const Color(0xFFF8BF13),
                        width: 180,
                        expandImage: true,
                        borderRadius: 18,
                        padding: const EdgeInsets.all(12),
                        onTap: () => onPieceTap(piece),
                      );
                    },
                  ),
                ),
      ],
    );
  }
}

/// Bandeau pubs sponsorisées (UI) — tap délégué à handleMarqueSponsoredPubTap.
class MarqueSponsoredPubsSection extends StatelessWidget {
  const MarqueSponsoredPubsSection({
    super.key,
    required this.pubs,
    required this.isLoading,
    required this.onPubTap,
    this.error,
  });

  final List<Pub> pubs;
  final bool isLoading;
  final String? error;
  final ValueChanged<Pub> onPubTap;

  @override
  Widget build(BuildContext context) {
    final pubsValides = pubs.where(isPubValid).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: const [
              Icon(Icons.star, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Sponsorisé',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          SkeletonPresets.pubBanner(height: 100)
        else if (error != null)
          SizedBox(height: 100, child: Center(child: Text(error!)))
        else if (pubsValides.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Aucune voiture sponsorisée.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pubsValides.length,
              itemBuilder: (context, index) {
                final pub = pubsValides[index];
                return GestureDetector(
                  onTap: () => onPubTap(pub),
                  child: SizedBox(
                    width: 255,
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: Container(
                                  height: 170,
                                  width: 255,
                                  color: Colors.grey[300],
                                  child: pub.media.isNotEmpty
                                      ? CachedMediaImage(
                                          url: pub.media[0],
                                          width: 255,
                                          height: 170,
                                          fit: BoxFit.cover,
                                          cloudinaryWidthPx: 280,
                                        )
                                      : Icon(
                                          Icons.image_not_supported,
                                          size: 80,
                                          color: Colors.grey[600],
                                        ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pub.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            color: Color(0xFFF8BF13),
                                            size: 18,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Vérifiée',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFFF8BF13),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
