/// Options de filtres catalogue (marques, modèles, localisations) dérivées
/// des articles + graines connues, sans doublons.
class CatalogFilterOption {
  final String label;
  final String normalizedKey;
  final String? assetPath;
  final String? networkSvgUrl;

  const CatalogFilterOption({
    required this.label,
    required this.normalizedKey,
    this.assetPath,
    this.networkSvgUrl,
  });
}

String normalizeCatalogKey(String input) {
  var s = input.trim().toLowerCase();
  const replacements = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'ï': 'i',
    'î': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'œ': 'oe',
  };
  for (final entry in replacements.entries) {
    s = s.replaceAll(entry.key, entry.value);
  }
  s = s.replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

double? parseArticlePrice(dynamic raw) {
  if (raw == null) return null;
  return double.tryParse(
    raw.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
  );
}

const Set<String> _excludedNonMarqueKeys = {
  'nouveau',
  'occasion',
  'neuf',
  'new',
  'used',
  'reconditionne',
};

bool _isExcludedNonMarqueLabel(String raw) {
  return _excludedNonMarqueKeys.contains(normalizeCatalogKey(raw));
}

String? _readMarque(Map<String, dynamic> article, {required bool isPiece}) {
  final marque = (article['marque'] ?? '').toString().trim();
  if (marque.isEmpty) return null;
  if (_isExcludedNonMarqueLabel(marque)) return null;
  return marque;
}

String? _readModele(Map<String, dynamic> article) {
  final modele = (article['modele'] ?? '').toString().trim();
  return modele.isNotEmpty ? modele : null;
}

String? _readLocationRaw(Map<String, dynamic> article) {
  final loc =
      (article['localisation'] ?? article['lieu'] ?? '').toString().trim();
  return loc.isNotEmpty ? loc : null;
}

/// Graines marques — Motomarks en priorité, SVG Wikimedia vérifiés en secours.
const List<CatalogFilterOption> _seedMarques = [
  CatalogFilterOption(
    label: 'Toyota',
    normalizedKey: 'toyota',
    networkSvgUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/e7/Toyota.svg',
  ),
  CatalogFilterOption(
    label: 'Nissan',
    normalizedKey: 'nissan',
    networkSvgUrl: 'https://cdn.worldvectorlogo.com/logos/nissan-6.svg',
  ),
  CatalogFilterOption(
    label: 'Ford',
    normalizedKey: 'ford',
    networkSvgUrl: 'https://cdn.worldvectorlogo.com/logos/ford-5.svg',
  ),
  CatalogFilterOption(
    label: 'Hyundai',
    normalizedKey: 'hyundai',
    networkSvgUrl:
        'https://cdn.worldvectorlogo.com/logos/hyundai-motor-company.svg',
  ),
  CatalogFilterOption(
    label: 'Honda',
    normalizedKey: 'honda',
    networkSvgUrl: 'https://cdn.worldvectorlogo.com/logos/honda-4.svg',
  ),
  CatalogFilterOption(
    label: 'Kia',
    normalizedKey: 'kia',
    networkSvgUrl: 'https://cdn.worldvectorlogo.com/logos/kia-motors-1.svg',
  ),
  CatalogFilterOption(
    label: 'BMW',
    normalizedKey: 'bmw',
    networkSvgUrl: 'https://cdn.worldvectorlogo.com/logos/bmw-7.svg',
  ),
  CatalogFilterOption(
    label: 'Mercedes',
    normalizedKey: 'mercedes',
    networkSvgUrl:
        'https://upload.wikimedia.org/wikipedia/commons/9/90/Mercedes-Logo.svg',
  ),
  CatalogFilterOption(
    label: 'Audi',
    normalizedKey: 'audi',
    networkSvgUrl:
        'https://upload.wikimedia.org/wikipedia/commons/9/92/Audi-Logo_2016.svg',
  ),
  CatalogFilterOption(
    label: 'Volkswagen',
    normalizedKey: 'volkswagen',
    networkSvgUrl:
        'https://upload.wikimedia.org/wikipedia/commons/6/6d/Volkswagen_logo_2019.svg',
  ),
  CatalogFilterOption(
    label: 'Lexus',
    normalizedKey: 'lexus',
    networkSvgUrl: 'https://cdn.worldvectorlogo.com/logos/lexus-2.svg',
  ),
  CatalogFilterOption(
    label: 'Mazda',
    normalizedKey: 'mazda',
    networkSvgUrl:
        'https://upload.wikimedia.org/wikipedia/commons/3/3f/Mazda_logo.svg',
  ),
  CatalogFilterOption(
    label: 'Chevrolet',
    normalizedKey: 'chevrolet',
    networkSvgUrl:
        'https://upload.wikimedia.org/wikipedia/commons/8/81/Chevrolet-logo.svg',
  ),
  CatalogFilterOption(
    label: 'Jeep',
    normalizedKey: 'jeep',
    networkSvgUrl: 'https://cdn.worldvectorlogo.com/logos/jeep-4.svg',
  ),
  CatalogFilterOption(
    label: 'Peugeot',
    normalizedKey: 'peugeot',
    networkSvgUrl: 'https://cdn.worldvectorlogo.com/logos/peugeot-9.svg',
  ),
  CatalogFilterOption(
    label: 'Renault',
    normalizedKey: 'renault',
    networkSvgUrl:
        'https://upload.wikimedia.org/wikipedia/commons/b/b7/Renault_2021_Text.svg',
  ),
];

/// Pays / zones avec drapeaux SVG (flagcdn).
const List<CatalogFilterOption> _seedLocations = [
  CatalogFilterOption(
    label: 'Bénin',
    normalizedKey: 'benin',
    networkSvgUrl: 'https://flagcdn.com/bj.svg',
  ),
  CatalogFilterOption(
    label: 'Mali',
    normalizedKey: 'mali',
    networkSvgUrl: 'https://flagcdn.com/ml.svg',
  ),
  CatalogFilterOption(
    label: 'Niger',
    normalizedKey: 'niger',
    networkSvgUrl: 'https://flagcdn.com/ne.svg',
  ),
  CatalogFilterOption(
    label: 'Burkina-Faso',
    normalizedKey: 'burkina-faso',
    networkSvgUrl: 'https://flagcdn.com/bf.svg',
  ),
  CatalogFilterOption(
    label: 'Côte d\'Ivoire',
    normalizedKey: 'cote d ivoire',
    networkSvgUrl: 'https://flagcdn.com/ci.svg',
  ),
  CatalogFilterOption(
    label: 'Sénégal',
    normalizedKey: 'senegal',
    networkSvgUrl: 'https://flagcdn.com/sn.svg',
  ),
  CatalogFilterOption(
    label: 'Togo',
    normalizedKey: 'togo',
    networkSvgUrl: 'https://flagcdn.com/tg.svg',
  ),
  CatalogFilterOption(
    label: 'Ghana',
    normalizedKey: 'ghana',
    networkSvgUrl: 'https://flagcdn.com/gh.svg',
  ),
  CatalogFilterOption(
    label: 'Nigéria',
    normalizedKey: 'nigeria',
    networkSvgUrl: 'https://flagcdn.com/ng.svg',
  ),
  CatalogFilterOption(
    label: 'Maroc',
    normalizedKey: 'maroc',
    networkSvgUrl: 'https://flagcdn.com/ma.svg',
  ),
];

CatalogFilterOption? _matchSeedLocation(String raw) {
  final key = normalizeCatalogKey(raw);
  for (final seed in _seedLocations) {
    if (key.contains(seed.normalizedKey) ||
        seed.normalizedKey.contains(key) ||
        key.contains(seed.label.toLowerCase())) {
      return seed;
    }
  }
  for (final seed in _seedLocations) {
    if (raw.toLowerCase().contains(seed.label.toLowerCase())) {
      return seed;
    }
  }
  return null;
}

CatalogFilterOption? _matchSeedMarque(String raw) {
  final key = normalizeCatalogKey(raw);
  for (final seed in _seedMarques) {
    if (key == seed.normalizedKey || key.contains(seed.normalizedKey)) {
      return seed;
    }
  }
  return null;
}

/// Modèles catalogue (liste fixe — pas enrichie par les saisies vendeur).
const List<String> _seedModeles = [
  'Land Cruiser',
  'Patrol',
  'Altima',
  'RAV4',
  'Hilux',
  'Wrangler',
  'Civic',
  'Corolla',
  'Camry',
  'Accord',
  'Tucson',
  'Sportage',
];

/// Liste fixe des marques affichées dans les filtres.
List<CatalogFilterOption> get catalogSeedMarques =>
    List<CatalogFilterOption>.from(_seedMarques);

/// Liste fixe des localisations affichées dans les filtres.
List<CatalogFilterOption> get catalogSeedLocations =>
    List<CatalogFilterOption>.from(_seedLocations);

/// Liste fixe des modèles affichés dans les filtres.
List<String> get catalogSeedModeles => List<String>.from(_seedModeles);

class PieceTypeFilterOption {
  final String label;
  final String normalizedKey;
  final List<String> categorieKeys;

  const PieceTypeFilterOption({
    required this.label,
    required this.normalizedKey,
    required this.categorieKeys,
  });
}

const List<PieceTypeFilterOption> kPieceTypeFilters = [
  PieceTypeFilterOption(
    label: 'Pièces détachées',
    normalizedKey: 'pieces_detachees',
    categorieKeys: ['piece_detachee', 'piece', 'pieces', 'pieces_detachees'],
  ),
  PieceTypeFilterOption(
    label: 'Pneus',
    normalizedKey: 'pneus',
    categorieKeys: ['pneu', 'pneus'],
  ),
  PieceTypeFilterOption(
    label: 'Huiles et lubrifiants',
    normalizedKey: 'huiles_lubrifiants',
    categorieKeys: ['huile_moteur', 'huile', 'lubrifiant', 'lubrifiants'],
  ),
  PieceTypeFilterOption(
    label: 'Batteries',
    normalizedKey: 'batteries',
    categorieKeys: ['batterie', 'batteries'],
  ),
  PieceTypeFilterOption(
    label: 'Accessoires',
    normalizedKey: 'accessoires',
    categorieKeys: ['accessoire', 'accessoires'],
  ),
];

List<String> buildPieceTypeFilterOptions() =>
    kPieceTypeFilters.map((e) => e.normalizedKey).toList();

String pieceTypeFilterLabel(dynamic l10n, String normalizedKey) {
  switch (normalizedKey) {
    case 'pieces_detachees':
      return l10n.pieceTypeSpareParts;
    case 'pneus':
      return l10n.pieceTypeTires;
    case 'huiles_lubrifiants':
      return l10n.pieceTypeOils;
    case 'batteries':
      return l10n.pieceTypeBatteries;
    case 'accessoires':
      return l10n.pieceTypeAccessories;
    default:
      return normalizedKey;
  }
}

PieceTypeFilterOption? _matchPieceTypeFilter(String? selected) {
  if (selected == null || selected.isEmpty) return null;
  final sel = normalizeCatalogKey(selected);
  for (final opt in kPieceTypeFilters) {
    if (normalizeCatalogKey(opt.label) == sel ||
        opt.normalizedKey == sel) {
      return opt;
    }
  }
  return null;
}

bool pieceMatchesTypeFilter(dynamic piece, String? selectedType) {
  if (selectedType == null || selectedType.isEmpty) return true;
  final opt = _matchPieceTypeFilter(selectedType);
  if (opt == null) return true;
  final cat = normalizeCatalogKey((piece['categorie'] ?? '').toString());
  final titre = normalizeCatalogKey((piece['titre'] ?? piece['title'] ?? '').toString());
  for (final key in opt.categorieKeys) {
    final nk = normalizeCatalogKey(key);
    if (cat.contains(nk) || nk.contains(cat) || titre.contains(nk)) {
      return true;
    }
  }
  return false;
}

/// Marque saisie par un vendeur : conservée seulement si elle correspond
/// à une marque connue du catalogue (évite Occasion, Nouveau, etc.).
String? normalizeVendorMarque(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty || _isExcludedNonMarqueLabel(trimmed)) return null;
  return _matchSeedMarque(trimmed)?.label;
}

List<CatalogFilterOption> buildMarqueFilterOptions(
  List<dynamic> articles, {
  required bool isPiece,
}) {
  // Toujours la liste complète des graines ; les articles servent uniquement
  // à vérifier qu'une marque vendeur est reconnue (pas à enrichir modèle/lieu).
  final options = List<CatalogFilterOption>.from(_seedMarques);
  final keys = options.map((e) => e.normalizedKey).toSet();

  for (final raw in articles) {
    if (raw is! Map) continue;
    final map = Map<String, dynamic>.from(raw);
    final marque = _readMarque(map, isPiece: isPiece);
    if (marque == null) continue;
    final seed = _matchSeedMarque(marque);
    if (seed != null && !keys.contains(seed.normalizedKey)) {
      keys.add(seed.normalizedKey);
      options.add(seed);
    }
  }

  return options;
}

List<String> buildModeleFilterOptions(List<dynamic> articles) {
  return List<String>.from(_seedModeles);
}

List<CatalogFilterOption> buildLocationFilterOptions(List<dynamic> articles) {
  return List<CatalogFilterOption>.from(_seedLocations);
}

bool catalogValueMatches(String? selected, String haystack) {
  if (selected == null || selected.isEmpty) return true;
  final sel = normalizeCatalogKey(selected);
  final hay = normalizeCatalogKey(haystack);
  return hay.contains(sel) || sel.contains(hay);
}

/// Pays suggérés à la saisie (pas de villes).
List<String> get catalogCountrySuggestions =>
    _seedLocations.map((e) => e.label).toList();

CatalogFilterOption? matchKnownCountry(String raw) => _matchSeedLocation(raw);

String? knownCountryLabel(String raw) => _matchSeedLocation(raw)?.label;

List<String> filterCountrySuggestions(String query) {
  final q = normalizeCatalogKey(query);
  if (q.isEmpty) return catalogCountrySuggestions;
  return catalogCountrySuggestions
      .where((c) => normalizeCatalogKey(c).contains(q))
      .toList();
}
