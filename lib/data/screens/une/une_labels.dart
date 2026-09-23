import 'package:tranoo/l10n/app_localizations.dart';

/// Constantes + labels i18n pour l'écran Une (pub).
class UneLabels {
  UneLabels._();

  static const pubSponsored = 'Sponsorisée';
  static const pubFeatured = 'À la une';
  static const bankPayment = 'Paiement bancaire';
  static const dureeOneWeek = '1 semaine';
  static const dureeTwoWeeks = '2 semaines';
  static const dureeOneMonth = '1 mois';
  static const dureeTwoMonths = '2 mois';
  static const dureeThreeMonths = '3 mois';
  static const conditionNew = 'Nouveau';
  static const conditionUsed = 'Occasion';
  static const noEngine = 'Aucun';
  static const otherModel = 'Autre';

  static String pubType(AppLocalizations l10n, String type) {
    switch (type) {
      case pubSponsored:
        return l10n.sponsoredType;
      case pubFeatured:
        return l10n.featuredType;
      default:
        return type;
    }
  }

  static String duration(AppLocalizations l10n, String duree) {
    switch (duree) {
      case dureeOneWeek:
        return l10n.oneWeek;
      case dureeTwoWeeks:
        return l10n.twoWeeks;
      case dureeOneMonth:
        return l10n.oneMonth;
      case dureeTwoMonths:
        return l10n.twoMonths;
      case dureeThreeMonths:
        return l10n.threeMonths;
      default:
        return duree;
    }
  }

  static String condition(AppLocalizations l10n, String? value) {
    if (value == conditionNew) return l10n.newCondition;
    if (value == conditionUsed) return l10n.usedCondition;
    return value ?? '';
  }

  static String fuel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'Essence':
        return l10n.petrol;
      case 'Gazoil':
        return l10n.gazoil;
      case 'Diesel':
      case 'Diezel':
        return l10n.diesel;
      case 'Electrique':
        return l10n.electric;
      case 'Hybride':
        return l10n.hybrid;
      case noEngine:
        return l10n.noEngine;
      default:
        return value;
    }
  }
}
