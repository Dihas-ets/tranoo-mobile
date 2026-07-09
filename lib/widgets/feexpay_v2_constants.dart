import 'package:flutter/material.dart';

/// Aligné sur [FeexPay API REST v2](https://docs.feexpay.me/?section=api-rest-integrations&version=v2).
class FeexPayV2Constants {
  static const double minAmount = 100;
  static const double minMobileAmount = minAmount;
  static const double minCardAmount = minAmount;
  static const svgPackage = 'feexpay_flutter_v2';

  static const mtnLogo = 'assets/images/logo_mtn.svg';
  static const moovLogo = 'assets/images/logo_moov.svg';
  static const visaLogo = 'assets/images/logo_visa.svg';
  static const mastercardLogo = 'assets/images/logo_mastercard.svg';
}

class FeexPayNetworkOption {
  final String id;
  final String label;
  final String subtitle;
  final Color brandColor;
  final Color accentColor;
  final String? logoAsset;
  /// Coris : OTP envoyé par SMS puis 2e requête.
  final bool twoStepOtp;
  /// Orange SN : OTP obtenu via #144#391# avant paiement.
  final bool requiresOtpUpfront;
  /// Free SN : renvoie une URL de redirection.
  final bool mayRedirect;

  const FeexPayNetworkOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.brandColor,
    required this.accentColor,
    this.logoAsset,
    this.twoStepOtp = false,
    this.requiresOtpUpfront = false,
    this.mayRedirect = false,
  });
}

class FeexPayCountry {
  final String code;
  final String name;
  final String flag;
  final String dialCode;
  final String phoneHint;
  final String phoneHelp;
  final List<FeexPayNetworkOption> networks;

  const FeexPayCountry({
    required this.code,
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.phoneHint,
    required this.phoneHelp,
    required this.networks,
  });
}

const kFeexPayCountries = <FeexPayCountry>[
  FeexPayCountry(
    code: 'BJ',
    name: 'Bénin',
    flag: '🇧🇯',
    dialCode: '229',
    phoneHint: '01 XX XX XX XX',
    phoneHelp: 'Numéro commençant par 01 (ex : 0166000000).',
    networks: [
      FeexPayNetworkOption(
        id: 'mtn',
        label: 'MTN',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFFFFCC00),
        accentColor: Color(0xFF1A1A1A),
        logoAsset: FeexPayV2Constants.mtnLogo,
      ),
      FeexPayNetworkOption(
        id: 'moov',
        label: 'Moov',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFF0066B3),
        accentColor: Colors.white,
        logoAsset: FeexPayV2Constants.moovLogo,
      ),
      FeexPayNetworkOption(
        id: 'celtiis_bj',
        label: 'Celtiis',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFF003DA5),
        accentColor: Colors.white,
      ),
      FeexPayNetworkOption(
        id: 'coris',
        label: 'Coris',
        subtitle: 'Code SMS',
        brandColor: Color(0xFFE85D04),
        accentColor: Colors.white,
        twoStepOtp: true,
      ),
    ],
  ),
  FeexPayCountry(
    code: 'TG',
    name: 'Togo',
    flag: '🇹🇬',
    dialCode: '228',
    phoneHint: '90 XX XX XX',
    phoneHelp: 'Numéro togolais avec indicatif 228 (ex : 22890123456).',
    networks: [
      FeexPayNetworkOption(
        id: 'togocom_tg',
        label: 'Togocom',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFF0066CC),
        accentColor: Colors.white,
      ),
      FeexPayNetworkOption(
        id: 'moov_tg',
        label: 'Moov',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFF0066B3),
        accentColor: Colors.white,
        logoAsset: FeexPayV2Constants.moovLogo,
      ),
    ],
  ),
  FeexPayCountry(
    code: 'SN',
    name: 'Sénégal',
    flag: '🇸🇳',
    dialCode: '221',
    phoneHint: '77 XXX XX XX',
    phoneHelp: 'Numéro sénégalais avec indicatif 221.',
    networks: [
      FeexPayNetworkOption(
        id: 'orange_sn',
        label: 'Orange',
        subtitle: 'OTP #144#391#',
        brandColor: Color(0xFFFF6600),
        accentColor: Colors.white,
        requiresOtpUpfront: true,
      ),
      FeexPayNetworkOption(
        id: 'free_sn',
        label: 'Free',
        subtitle: 'Redirection web',
        brandColor: Color(0xFFE30613),
        accentColor: Colors.white,
        mayRedirect: true,
      ),
    ],
  ),
  FeexPayCountry(
    code: 'CI',
    name: "Côte d'Ivoire",
    flag: '🇨🇮',
    dialCode: '225',
    phoneHint: '07 XX XX XX XX',
    phoneHelp: 'Numéro ivoirien avec indicatif 225 (ex : 2250766000000).',
    networks: [
      FeexPayNetworkOption(
        id: 'mtn_ci',
        label: 'MTN',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFFFFCC00),
        accentColor: Color(0xFF1A1A1A),
        logoAsset: FeexPayV2Constants.mtnLogo,
      ),
      FeexPayNetworkOption(
        id: 'moov_ci',
        label: 'Moov',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFF0066B3),
        accentColor: Colors.white,
        logoAsset: FeexPayV2Constants.moovLogo,
      ),
      FeexPayNetworkOption(
        id: 'wave_ci',
        label: 'Wave',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFF1DC8FF),
        accentColor: Colors.white,
      ),
      FeexPayNetworkOption(
        id: 'orange_ci',
        label: 'Orange',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFFFF6600),
        accentColor: Colors.white,
      ),
    ],
  ),
  FeexPayCountry(
    code: 'BF',
    name: 'Burkina Faso',
    flag: '🇧🇫',
    dialCode: '226',
    phoneHint: '70 XX XX XX',
    phoneHelp: 'Numéro burkinabè avec indicatif 226.',
    networks: [
      FeexPayNetworkOption(
        id: 'moov_bf',
        label: 'Moov',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFF0066B3),
        accentColor: Colors.white,
        logoAsset: FeexPayV2Constants.moovLogo,
      ),
      FeexPayNetworkOption(
        id: 'orange_bf',
        label: 'Orange',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFFFF6600),
        accentColor: Colors.white,
      ),
    ],
  ),
  FeexPayCountry(
    code: 'CM',
    name: 'Cameroun',
    flag: '🇨🇲',
    dialCode: '237',
    phoneHint: '6XX XX XX XX',
    phoneHelp: 'Numéro camerounais avec indicatif 237.',
    networks: [
      FeexPayNetworkOption(
        id: 'mtn_cm',
        label: 'MTN',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFFFFCC00),
        accentColor: Color(0xFF1A1A1A),
        logoAsset: FeexPayV2Constants.mtnLogo,
      ),
    ],
  ),
  FeexPayCountry(
    code: 'CG',
    name: 'Congo',
    flag: '🇨🇬',
    dialCode: '242',
    phoneHint: '06 XXX XX XX',
    phoneHelp: 'Numéro congolais avec indicatif 242.',
    networks: [
      FeexPayNetworkOption(
        id: 'mtn_cg',
        label: 'MTN',
        subtitle: 'Mobile Money',
        brandColor: Color(0xFFFFCC00),
        accentColor: Color(0xFF1A1A1A),
        logoAsset: FeexPayV2Constants.mtnLogo,
      ),
    ],
  ),
];

const kFeexPayCardTypes = <String, String>{
  'VISA': 'Visa',
  'MASTERCARD': 'Mastercard',
};

FeexPayCountry feexPayCountryByCode(String code) {
  return kFeexPayCountries.firstWhere(
    (c) => c.code == code,
    orElse: () => kFeexPayCountries.first,
  );
}
