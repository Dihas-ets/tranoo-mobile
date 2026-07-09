import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tranoo/utils/cloudinary_url.dart';

/// Image réseau avec cache disque + placeholder (aligné tranoo_pro).
class CachedMediaImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cloudinaryWidthPx;
  final Color placeholderColor;
  final Widget? errorWidget;

  const CachedMediaImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cloudinaryWidthPx,
    this.placeholderColor = const Color(0xFFE8E8E8),
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return _box(child: const Icon(Icons.broken_image_outlined));
    }

    final optimized = cloudinaryOptimizedUrl(
      trimmed,
      widthPx:
          cloudinaryWidthPx != null ? math.max(1, cloudinaryWidthPx!) : null,
    );

    return CachedNetworkImage(
      imageUrl: optimized,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: const Duration(milliseconds: 80),
      placeholder: (_, __) => _box(),
      errorWidget: (_, __, ___) =>
          errorWidget ??
          _box(
            child: const Icon(Icons.broken_image_outlined, color: Colors.black45),
          ),
    );
  }

  Widget _box({Widget? child}) {
    return Container(
      width: width,
      height: height,
      color: placeholderColor,
      alignment: Alignment.center,
      child: child,
    );
  }
}

Future<void> precacheMediaImages(
  BuildContext context,
  Iterable<String> urls, {
  int? cloudinaryWidthPx,
  int maxCount = 16,
}) async {
  final tasks = <Future<void>>[];
  var count = 0;
  for (final raw in urls) {
    if (count >= maxCount) break;
    final trimmed = raw.trim();
    if (!trimmed.startsWith('http')) continue;
    tasks.add(
      precacheImage(
        CachedNetworkImageProvider(
          cloudinaryOptimizedUrl(
            trimmed,
            widthPx: cloudinaryWidthPx != null
                ? math.max(1, cloudinaryWidthPx)
                : null,
          ),
        ),
        context,
      ).catchError((_) {}),
    );
    count++;
  }
  if (tasks.isNotEmpty) {
    await Future.wait(tasks);
  }
}
