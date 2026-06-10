import 'package:tranoo/l10n/app_localizations.dart';

class LocaleHelper {
  static const supportedLanguageCodes = ['fr', 'en', 'ar'];

  static String languageLabel(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.english;
      case 'ar':
        return l10n.arabic;
      default:
        return l10n.french;
    }
  }

  static String currencyLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'Euro':
        return l10n.currencyEuro;
      case 'Dollars':
        return l10n.currencyDollars;
      default:
        return l10n.currencyXof;
    }
  }

  static String flagEmoji(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'ar':
        return '🇸🇦';
      default:
        return '🇫🇷';
    }
  }
}
