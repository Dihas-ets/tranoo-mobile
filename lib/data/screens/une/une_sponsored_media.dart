import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';

/// Grille d'images + upload vidéo pour pub sponsorisée.
class UneSponsoredMedia extends StatelessWidget {
  const UneSponsoredMedia({
    super.key,
    required this.imageUrls,
    required this.isUploadingImage,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.uploadedVideo,
    required this.cloudinaryVideoUrl,
    required this.isUploadingVideo,
    required this.videoUploadProgress,
    required this.onPickVideo,
    required this.onRemoveVideo,
  });

  final List<String?> imageUrls;
  final List<bool> isUploadingImage;
  final void Function(int index) onPickImage;
  final void Function(int index) onRemoveImage;
  final File? uploadedVideo;
  final String? cloudinaryVideoUrl;
  final bool isUploadingVideo;
  final double videoUploadProgress;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.additionalImagesOptional,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final url = imageUrls[index];
            final hasImage = url != null && url.isNotEmpty;
            return GestureDetector(
              onTap: () => onPickImage(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (hasImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TranooNetworkImage(
                          url: url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          cloudinaryWidthPx: cloudinaryWidthPx(context),
                        ),
                      )
                    else
                      const Icon(Icons.add_a_photo, color: Colors.grey),
                    if (isUploadingImage[index])
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (hasImage)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => onRemoveImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onPickVideo,
          child: Container(
            height: 80,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              children: [
                if (uploadedVideo != null)
                  const Icon(Icons.videocam, color: Colors.blue, size: 40)
                else
                  const Icon(Icons.add_to_photos, color: Colors.grey),
                if (isUploadingVideo)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 35,
                              height: 35,
                              child: CircularProgressIndicator(
                                value: videoUploadProgress > 0
                                    ? videoUploadProgress
                                    : null,
                                color: Colors.blue,
                                backgroundColor: Colors.white24,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              videoUploadProgress < 0.85
                                  ? l10n.sending
                                  : l10n.processing,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${(videoUploadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 140,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: videoUploadProgress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (cloudinaryVideoUrl != null)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onRemoveVideo,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
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
