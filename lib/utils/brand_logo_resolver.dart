import 'package:tranoo/utils/motomarks_config.dart';

/// Slugs Motomarks (certains labels catalogue ≠ slug API).
const Map<String, String> brandMotomarksSlugByKey = {
  'mercedes': 'mercedes-benz',
  'mercedes-benz': 'mercedes-benz',
  'land rover': 'land-rover',
  'land-rover': 'land-rover',
  'alfa romeo': 'alfa-romeo',
  'rolls royce': 'rolls-royce',
  'aston martin': 'aston-martin',
  'harley davidson': 'harley-davidson',
  'harley-davidson': 'harley-davidson',
  'ktm': 'ktm',
  'bmw': 'bmw',
  'volkswagen': 'volkswagen',
  'chevrolet': 'chevrolet',
};

String brandMotomarksSlug(String normalizedKey) {
  final k = normalizedKey.trim().toLowerCase();
  return brandMotomarksSlugByKey[k] ?? k.replaceAll(' ', '-');
}

/// Miniature PNG Wikimedia (fiable) à partir d'une URL SVG Commons.
String? wikimediaPngThumbUrl(String? svgUrl, {int widthPx = 120}) {
  if (svgUrl == null || svgUrl.isEmpty) return null;
  if (!svgUrl.contains('upload.wikimedia.org')) return null;
  if (!svgUrl.toLowerCase().endsWith('.svg')) return null;
  try {
    final uri = Uri.parse(svgUrl);
    var path = uri.path;
    if (!path.contains('/commons/')) return null;
    path = path.replaceFirst('/commons/', '/commons/thumb/');
    final fileName = path.split('/').last;
    final px = widthPx.clamp(48, 240);
    return 'https://upload.wikimedia.org$path/${px}px-$fileName.png';
  } catch (_) {
    return null;
  }
}

/// Ordre : Motomarks PNG → Wikimedia PNG → SVG distant.
List<String> brandLogoCandidateUrls({
  required String normalizedKey,
  String? networkSvgUrl,
  double displayWidth = 36,
}) {
  final urls = <String>[];
  final token = motomarksPublishableToken;
  if (token != null) {
    final slug = brandMotomarksSlug(normalizedKey);
    final size = motomarksSizePresetForDisplay(displayWidth);
    urls.add(
      '$motomarksCdnBase/$slug?token=$token&size=$size&format=png',
    );
  }
  final wiki = wikimediaPngThumbUrl(
    networkSvgUrl,
    widthPx: displayWidth.round().clamp(64, 200),
  );
  if (wiki != null) urls.add(wiki);
  if (networkSvgUrl != null && networkSvgUrl.trim().isNotEmpty) {
    urls.add(networkSvgUrl.trim());
  }
  return urls;
}
