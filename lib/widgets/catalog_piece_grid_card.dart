import 'package:flutter/material.dart';
import 'package:tranoo/utils/article_view_helper.dart';
import 'package:tranoo/utils/catalog_display.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';

/// Carte pièce (grille listes + bandeau marque).
class CatalogPieceGridCard extends StatelessWidget {
  const CatalogPieceGridCard({
    super.key,
    required this.title,
    required this.company,
    required this.prix,
    required this.images,
    required this.onTap,
    this.video,
    this.views = 0,
    this.badgeText,
    this.badgeColor = const Color(0xFFF8BF13),
    this.width,
    this.expandImage = false,
    this.imageHeight = 100,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(10),
  });

  final String title;
  final String company;
  final dynamic prix;
  final List<String> images;
  final String? video;
  final int views;
  final String? badgeText;
  final Color badgeColor;
  final double? width;
  final bool expandImage;
  final double imageHeight;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;

  factory CatalogPieceGridCard.fromArticleMap({
    Key? key,
    required Map<String, dynamic> article,
    required VoidCallback onTap,
    required String title,
    required String company,
    String? badgeText,
    Color badgeColor = const Color(0xFFF8BF13),
    double? width,
    bool expandImage = false,
    double imageHeight = 100,
    double borderRadius = 20,
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
  }) {
    return CatalogPieceGridCard(
      key: key,
      title: title,
      company: company,
      prix: article['prix'],
      images: (article['photos'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      video: article['video']?.toString(),
      views: articleViewsFromMap(article),
      badgeText: badgeText,
      badgeColor: badgeColor,
      width: width,
      expandImage: expandImage,
      imageHeight: imageHeight,
      borderRadius: borderRadius,
      padding: padding,
      onTap: onTap,
    );
  }

  Widget _media(BuildContext context) {
    final hasPhoto = images.isNotEmpty;
    final hasVideo = video != null && video!.isNotEmpty;
    return Stack(
      children: [
        Positioned.fill(
          child: hasPhoto
              ? TranooNetworkImage(
                  url: images.first,
                  fit: BoxFit.cover,
                  cloudinaryWidthPx: cloudinaryWidthPx(context),
                )
              : hasVideo
                  ? VideoPreviewPlaceholder(
                      videoUrl: video,
                      iconSize: expandImage ? 32 : 36,
                      enablePreviewFrame: false,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 30,
                        color: Colors.black26,
                      ),
                    ),
        ),
        if (badgeText != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: expandImage ? 8 : 6,
          right: expandImage ? 8 : 6,
          child: buildArticleViewBadge(views),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageRadius = expandImage ? 14.0 : 16.0;
    final media = ClipRRect(
      borderRadius: BorderRadius.circular(imageRadius),
      child: expandImage
          ? SizedBox(width: double.infinity, child: _media(context))
          : SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: _media(context),
            ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expandImage) Expanded(child: media) else media,
        SizedBox(height: expandImage ? 8 : 8),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: expandImage ? null : 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          company,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black54,
            fontSize: expandImage ? 12 : 11,
          ),
        ),
        SizedBox(height: expandImage ? 6 : 10),
        catalogPiecePricePill(prix),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: padding,
          child: body,
        ),
      ),
    );
  }
}
