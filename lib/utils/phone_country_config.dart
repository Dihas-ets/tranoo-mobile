/// Indicatifs et longueurs de numéros nationaux (sans indicatif).
class PhoneCountryConfig {
  final String name;
  final String code;
  final String flag;
  final int minDigits;
  final int maxDigits;

  const PhoneCountryConfig({
    required this.name,
    required this.code,
    required this.flag,
    required this.minDigits,
    required this.maxDigits,
  });

  String get digitHint => minDigits == maxDigits
      ? '$maxDigits chiffres'
      : '$minDigits à $maxDigits chiffres';

  bool isValidNationalNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.length >= minDigits && digits.length <= maxDigits;
  }
}

enum TranooAuthApp { buyer, pro }

String syntheticEmailFromPhone(
  String countryCode,
  String nationalDigits, {
  TranooAuthApp app = TranooAuthApp.buyer,
}) {
  final cc = countryCode.replaceAll(RegExp(r'\D'), '');
  final nn = nationalDigits.replaceAll(RegExp(r'\D'), '');
  final prefix = app == TranooAuthApp.pro ? 'pro_' : '';
  return '$prefix$cc$nn@tranoo.app';
}

bool isLegacyEmailLogin(String input) => input.contains('@');

String resolveAuthIdentifier({
  required String input,
  required String countryCode,
  required TranooAuthApp app,
}) {
  final trimmed = input.trim();
  if (isLegacyEmailLogin(trimmed)) return trimmed.toLowerCase();
  return syntheticEmailFromPhone(countryCode, trimmed, app: app);
}

PhoneCountryConfig phoneCountryByName(String? name) {
  if (name != null) {
    for (final c in kPhoneCountries) {
      if (c.name == name) return c;
    }
  }
  return kPhoneCountries.first;
}

bool isTranooBuyerAppRole(String? role) =>
    (role ?? '').toLowerCase() == 'acheteur';

const String kTranooBuyerBlockedTitle =
    'Compte Tranoo Pro non autorisé sur cette application';

const String kTranooBuyerBlockedSubtitle =
    'Tous les comptes Tranoo Pro (vendeur, chauffeur, transitaire, livreur, agent commercial, etc.) doivent utiliser l\'application Tranoo Pro.';

const String kTranooProBuyerBlockedTitle =
    'Compte acheteur non autorisé sur Tranoo Pro';

const String kTranooProBuyerBlockedSubtitle =
    'Les acheteurs utilisent l\'application Tranoo.';

/// Liste partagée inscription / connexion / mot de passe oublié.
const List<PhoneCountryConfig> kPhoneCountries = [
  PhoneCountryConfig(
      name: 'Bénin', code: '+229', flag: '🇧🇯', minDigits: 8, maxDigits: 10),
  PhoneCountryConfig(
      name: 'Côte d\'Ivoire',
      code: '+225',
      flag: '🇨🇮',
      minDigits: 10,
      maxDigits: 10),
  PhoneCountryConfig(
      name: 'Sénégal', code: '+221', flag: '🇸🇳', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Togo', code: '+228', flag: '🇹🇬', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Mali', code: '+223', flag: '🇲🇱', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Burkina Faso',
      code: '+226',
      flag: '🇧🇫',
      minDigits: 8,
      maxDigits: 8),
  PhoneCountryConfig(
      name: 'Niger', code: '+227', flag: '🇳🇪', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Ghana', code: '+233', flag: '🇬🇭', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Nigeria',
      code: '+234',
      flag: '🇳🇬',
      minDigits: 10,
      maxDigits: 10),
  PhoneCountryConfig(
      name: 'Cameroun', code: '+237', flag: '🇨🇲', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Gabon', code: '+241', flag: '🇬🇦', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Congo', code: '+242', flag: '🇨🇬', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'RDC', code: '+243', flag: '🇨🇩', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Tchad', code: '+235', flag: '🇹🇩', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Centrafrique',
      code: '+236',
      flag: '🇨🇫',
      minDigits: 8,
      maxDigits: 8),
  PhoneCountryConfig(
      name: 'Guinée', code: '+224', flag: '🇬🇳', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Guinée-Bissau',
      code: '+245',
      flag: '🇬🇼',
      minDigits: 7,
      maxDigits: 7),
  PhoneCountryConfig(
      name: 'Liberia', code: '+231', flag: '🇱🇷', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Sierra Leone',
      code: '+232',
      flag: '🇸🇱',
      minDigits: 8,
      maxDigits: 8),
  PhoneCountryConfig(
      name: 'Mauritanie',
      code: '+222',
      flag: '🇲🇷',
      minDigits: 8,
      maxDigits: 8),
  PhoneCountryConfig(
      name: 'Gambie', code: '+220', flag: '🇬🇲', minDigits: 7, maxDigits: 7),
  PhoneCountryConfig(
      name: 'Cap-Vert', code: '+238', flag: '🇨🇻', minDigits: 7, maxDigits: 7),
  PhoneCountryConfig(
      name: 'Maroc', code: '+212', flag: '🇲🇦', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Algérie', code: '+213', flag: '🇩🇿', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Tunisie', code: '+216', flag: '🇹🇳', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Libye', code: '+218', flag: '🇱🇾', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Égypte', code: '+20', flag: '🇪🇬', minDigits: 10, maxDigits: 10),
  PhoneCountryConfig(
      name: 'Soudan', code: '+249', flag: '🇸🇩', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Éthiopie', code: '+251', flag: '🇪🇹', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Kenya', code: '+254', flag: '🇰🇪', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Tanzanie', code: '+255', flag: '🇹🇿', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Ouganda', code: '+256', flag: '🇺🇬', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Rwanda', code: '+250', flag: '🇷🇼', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Burundi', code: '+257', flag: '🇧🇮', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Afrique du Sud',
      code: '+27',
      flag: '🇿🇦',
      minDigits: 9,
      maxDigits: 9),
  PhoneCountryConfig(
      name: 'Botswana', code: '+267', flag: '🇧🇼', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Namibie', code: '+264', flag: '🇳🇦', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'Zambie', code: '+260', flag: '🇿🇲', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Zimbabwe', code: '+263', flag: '🇿🇼', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Mozambique',
      code: '+258',
      flag: '🇲🇿',
      minDigits: 9,
      maxDigits: 9),
  PhoneCountryConfig(
      name: 'Madagascar',
      code: '+261',
      flag: '🇲🇬',
      minDigits: 9,
      maxDigits: 9),
  PhoneCountryConfig(
      name: 'Maurice', code: '+230', flag: '🇲🇺', minDigits: 8, maxDigits: 8),
  PhoneCountryConfig(
      name: 'France', code: '+33', flag: '🇫🇷', minDigits: 9, maxDigits: 10),
  PhoneCountryConfig(
      name: 'Belgique', code: '+32', flag: '🇧🇪', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Allemagne', code: '+49', flag: '🇩🇪', minDigits: 10, maxDigits: 11),
  PhoneCountryConfig(
      name: 'Italie', code: '+39', flag: '🇮🇹', minDigits: 9, maxDigits: 10),
  PhoneCountryConfig(
      name: 'Espagne', code: '+34', flag: '🇪🇸', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Portugal', code: '+351', flag: '🇵🇹', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Suisse', code: '+41', flag: '🇨🇭', minDigits: 9, maxDigits: 9),
  PhoneCountryConfig(
      name: 'Pays-Bas', code: '+31', flag: '🇳🇱', minDigits: 9, maxDigits: 9),
];
