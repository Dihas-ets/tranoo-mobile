import 'package:flutter/material.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';

/// Aperçu plein écran d'un flyer publicitaire.
void showMarqueFlyerPreview(BuildContext context, String imageUrl) {
  if (imageUrl.isEmpty) return;
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TranooNetworkImage(
                url: imageUrl,
                fit: BoxFit.contain,
                cloudinaryWidthPx:
                    (MediaQuery.of(context).size.width *
                            MediaQuery.of(context).devicePixelRatio)
                        .round()
                        .clamp(600, 1600),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    ),
  );
}
