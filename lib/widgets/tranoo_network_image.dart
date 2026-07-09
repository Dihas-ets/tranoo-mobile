import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tranoo/utils/cloudinary_url.dart';

class TranooNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color placeholderColor;

  /// Si fourni, applique `w_...` Cloudinary (en px écran).
  final int? cloudinaryWidthPx;

  const TranooNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderColor = const Color(0xFFEAEAEA),
    this.cloudinaryWidthPx,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return _fallbackBox();
    }

    // Pas de memCacheWidth/Height : forcer une taille de décode déforme les images
    // quand width ou height est infini (pubs, cartes voitures) — même logique que
    // CachedMediaImage sur tranoo_pro.
    Widget child = CachedNetworkImage(
      imageUrl: cloudinaryOptimizedUrl(
        trimmed,
        widthPx: cloudinaryWidthPx != null && cloudinaryWidthPx! > 0
            ? cloudinaryWidthPx
            : null,
      ),
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (context, _) => _placeholderBox(),
      errorWidget: (context, _, __) => _fallbackBox(),
    );

    final r = borderRadius;
    if (r != null) {
      child = ClipRRect(borderRadius: r, child: child);
    }
    return child;
  }

  Widget _placeholderBox() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor,
    );
  }

  Widget _fallbackBox() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Colors.black45),
    );
  }
}
