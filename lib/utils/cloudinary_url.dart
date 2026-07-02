/// Utilitaires Cloudinary: génère des URLs optimisées (taille/qualité/format)
/// sans dépendre d'un SDK ni casser les URLs existantes.
///
/// Objectif:
/// - éviter de servir l'original (souvent énorme)
/// - appliquer `f_auto` + `q_auto` + `w_...` quand l'URL est Cloudinary
/// - laisser intactes les URLs non-Cloudinary
library;

String cloudinaryOptimizedUrl(
  String url, {
  int? widthPx,
  bool formatAuto = true,
  String quality = 'auto',
}) {
  final raw = url.trim();
  if (raw.isEmpty) return raw;

  // On ne touche qu'aux URLs Cloudinary standard `.../image/upload/...`
  final marker = '/image/upload/';
  final idx = raw.indexOf(marker);
  if (idx < 0) return raw;

  final prefix = raw.substring(0, idx + marker.length); // inclut upload/
  final suffix = raw.substring(idx + marker.length);

  // Si l'URL contient déjà des transformations, on évite de les doubler.
  // (ex: upload/w_300,q_auto,f_auto/....)
  final firstSlash = suffix.indexOf('/');
  final firstSegment = firstSlash >= 0 ? suffix.substring(0, firstSlash) : suffix;
  final hasTransformLike = firstSegment.contains('w_') ||
      firstSegment.contains('q_') ||
      firstSegment.contains('f_') ||
      firstSegment.contains('c_');
  if (hasTransformLike) return raw;

  final parts = <String>[];
  if (widthPx != null && widthPx > 0) {
    parts.add('w_$widthPx');
    parts.add('c_limit');
  }
  if (quality.trim().isNotEmpty) {
    parts.add('q_$quality');
  }
  if (formatAuto) {
    parts.add('f_auto');
  }

  if (parts.isEmpty) return raw;
  return '$prefix${parts.join(',')}/$suffix';
}

String? cloudinaryVideoThumbUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  final uploadIndex = url.indexOf('/upload/');
  if (uploadIndex == -1) return null;
  final prefix = url.substring(0, uploadIndex + '/upload/'.length);
  final suffix = url.substring(uploadIndex + '/upload/'.length);
  final noExt =
      suffix.contains('.') ? suffix.substring(0, suffix.lastIndexOf('.')) : suffix;
  return '${prefix}so_1/$noExt.jpg';
}

