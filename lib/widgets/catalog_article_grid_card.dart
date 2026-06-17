import 'package:flutter/material.dart';
import 'package:tranoo/utils/article_view_helper.dart';
import 'package:tranoo/utils/catalog_display.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';

/// Carte catalogue identique à [VoituresPage] (grille 2 colonnes).
class CatalogArticleGridCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final bool isMoto;
  final VoidCallback onTap;
  final double width;
  final String conditionNewLabel;
  final String conditionUsedLabel;
  final String defaultTransmission;

  const CatalogArticleGridCard({
    super.key,
    required this.article,
    required this.isMoto,
    required this.onTap,
    required this.width,
    required this.conditionNewLabel,
    required this.conditionUsedLabel,
    this.defaultTransmission = 'Automatique',
  });

  static double aspectRatioForWidth(double screenWidth) {
    if (screenWidth < 360) return 0.58;
    if (screenWidth < 420) return 0.59;
    if (screenWidth < 520) return 0.7;
    return 0.78;
  }

  bool get _isNew {
    final c = (article['condition'] ?? '').toString().toLowerCase();
    return c == 'nouveau' || c == 'neuf';
  }

  Widget _spec(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.amber[700]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = width / aspectRatioForWidth(width * 2.2);
    final photos = article['photos'] as List?;
    final hasPhoto = photos != null && photos.isNotEmpty;
    final video = article['video']?.toString();
    final hasVideo = video != null && video.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: hasPhoto
                          ? Image.network(
                              photos!.first.toString(),
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : hasVideo
                              ? VideoPreviewPlaceholder(
                                  videoUrl: video,
                                  iconSize: 36,
                                  enablePreviewFrame: false,
                                )
                              : Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isNew
                              ? Colors.purple
                              : const Color(0xFFF8BF13),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          _isNew ? conditionNewLabel : conditionUsedLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: buildArticleViewBadge(
                        articleViewsFromMap(article),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      catalogVehicleInfoFooter(
                        title: vehicleTitleFromMap(article),
                        prix: article['prix'],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: isMoto
                              ? [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _spec(
                                          Icons.settings,
                                          article['transmission']?.toString() ??
                                              '',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _spec(
                                          Icons.calendar_today,
                                          article['annee']?.toString() ?? '',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _spec(
                                          Icons.local_gas_station,
                                          article['typeMoteur']?.toString() ??
                                              '',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _spec(
                                          Icons.speed,
                                          article['cylindre']?.toString() ??
                                              '',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _spec(
                                          Icons.two_wheeler,
                                          article['typeMoto']?.toString() ?? '',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _spec(
                                          Icons.bolt,
                                          article['puissance']?.toString() ??
                                              '',
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                              : [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _spec(
                                          Icons.settings,
                                          article['boiteVitesse']
                                                  ?.toString() ??
                                              defaultTransmission,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _spec(
                                          Icons.calendar_today,
                                          article['annee']?.toString() ?? '',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _spec(
                                          Icons.local_gas_station,
                                          article['carburant']?.toString() ??
                                              '',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _spec(
                                          Icons.speed,
                                          article['cylindre']?.toString() ??
                                              '',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _spec(
                                          Icons.speed,
                                          '${article['distance'] ?? ''} KM',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _spec(
                                          Icons.door_front_door,
                                          '${article['portes'] ?? ''} portes',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
