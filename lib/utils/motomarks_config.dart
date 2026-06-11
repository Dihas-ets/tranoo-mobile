import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Logos marques via [Motomarks](https://motomarks.io/docs) Image CDN.
const String motomarksCdnBase = 'https://motomarks.io/img';

/// Slugs Motomarks (certains labels catalogue diffèrent du slug API).
const Map<String, String> motomarksSlugByKey = {
  'mercedes': 'mercedes-benz',
};

String? get motomarksPublishableToken {
  final token = (dotenv.env['MOTOMARKS_API_TOKEN'] ??
          dotenv.env['MOTOMARKS_PUBLISHABLE_KEY'] ??
          '')
      .trim();
  return token.isEmpty ? null : token;
}

String motomarksSlugForKey(String normalizedKey) {
  return motomarksSlugByKey[normalizedKey] ?? normalizedKey;
}

/// Tailles CDN Motomarks : xs, sm, md, lg, xl (pas de pixels).
String motomarksSizePresetForDisplay(double displayWidth) {
  if (displayWidth <= 28) return 'xs';
  if (displayWidth <= 48) return 'sm';
  if (displayWidth <= 80) return 'md';
  if (displayWidth <= 120) return 'lg';
  return 'xl';
}

/// URL logo marque (CDN). Utiliser la clé **publishable** (`pk_…`), jamais la clé secrète.
String? motomarksBrandLogoUrl(
  String normalizedKey, {
  double displayWidth = 36,
  String format = 'png',
}) {
  final token = motomarksPublishableToken;
  if (token == null) return null;
  final slug = motomarksSlugForKey(normalizedKey);
  if (slug.isEmpty) return null;
  final size = motomarksSizePresetForDisplay(displayWidth);
  return '$motomarksCdnBase/$slug?token=$token&size=$size&format=$format';
}

bool get isMotomarksConfigured => motomarksPublishableToken != null;
