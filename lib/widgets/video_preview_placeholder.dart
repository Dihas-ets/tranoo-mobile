import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/cloudinary_url.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';

/// Aperçu vidéo léger : miniature Cloudinary + bouton lecture (pas de loader bloquant).
class VideoPreviewPlaceholder extends StatelessWidget {
  final String? videoUrl;
  final double iconSize;
  final String? label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool enablePreviewFrame;

  const VideoPreviewPlaceholder({
    super.key,
    this.videoUrl,
    this.iconSize = 40,
    this.label,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.onTap,
    this.enablePreviewFrame = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final thumbUrl = cloudinaryVideoThumbUrl(videoUrl);
    final displayLabel = label ?? l10n.videoAvailable;

    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbUrl != null)
            TranooNetworkImage(
              url: thumbUrl,
              fit: BoxFit.cover,
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_circle_fill,
                    color: iconColor == Colors.white
                        ? Colors.grey.shade900
                        : iconColor,
                    size: iconSize,
                  ),
                ),
                if (displayLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    displayLabel,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}
