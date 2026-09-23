import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';

/// Upload image principale (flyer) pour pub « À la une ».
class UneFeaturedFlyer extends StatelessWidget {
  const UneFeaturedFlyer({
    super.key,
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mainFlyerImage,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.recommendedDimensions,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.black,
                      child: TranooNetworkImage(
                        url: imageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        cloudinaryWidthPx: cloudinaryWidthPx(context),
                      ),
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addMainImage,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.dimensions1080x1350,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                if (isUploading)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (hasImage)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
