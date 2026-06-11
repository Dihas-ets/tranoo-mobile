import 'package:flutter/widgets.dart';

/// Texte API potentiellement bilingue : `{ "fr": "...", "en": "..." }` ou string simple.
String resolveLocaleMessage(dynamic raw, Locale locale) {
  if (raw == null) return '';
  if (raw is Map) {
    final lang = locale.languageCode.toLowerCase();
    final fr = raw['fr']?.toString();
    final en = raw['en']?.toString();
    if (lang == 'en' && en != null && en.trim().isNotEmpty) return en.trim();
    if (fr != null && fr.trim().isNotEmpty) return fr.trim();
    if (en != null && en.trim().isNotEmpty) return en.trim();
    return raw.values.map((e) => e.toString()).firstWhere(
          (s) => s.trim().isNotEmpty,
          orElse: () => '',
        );
  }
  return raw.toString();
}
