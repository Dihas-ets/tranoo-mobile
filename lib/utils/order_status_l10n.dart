import 'package:tranoo/l10n/app_localizations.dart';

/// Localizes order/delivery status codes for buyer-facing screens.
String localizedOrderStatus(AppLocalizations l10n, String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'pending':
      return l10n.orderStatusPending;
    case 'confirmed':
      return l10n.orderStatusConfirmed;
    case 'preparing':
      return l10n.orderStatusPreparing;
    case 'ready':
      return l10n.orderStatusReady;
    case 'assigné':
      return l10n.orderStatusDriverAssigned;
    case 'delivering':
    case 'en_cours':
    case 'commandé':
      return l10n.orderStatusDelivering;
    case 'delivered':
    case 'livré':
    case 'livree':
      return l10n.orderStatusDelivered;
    case 'cancelled':
    case 'annulé':
    case 'annule':
    case 'refusé':
    case 'refuse':
    case 'retour':
      return l10n.orderStatusCancelled;
    default:
      if (status == null || status.isEmpty) return l10n.unknown;
      return status;
  }
}

List<String> localizedMonthAbbreviations(AppLocalizations l10n) => [
      l10n.monthJan,
      l10n.monthFeb,
      l10n.monthMar,
      l10n.monthApr,
      l10n.monthMay,
      l10n.monthJun,
      l10n.monthJul,
      l10n.monthAug,
      l10n.monthSep,
      l10n.monthOct,
      l10n.monthNov,
      l10n.monthDec,
    ];

String formatRelativeTime(AppLocalizations l10n, DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 0) return l10n.timeAgoDays(diff.inDays);
  if (diff.inHours > 0) return l10n.timeAgoHours(diff.inHours);
  return l10n.timeAgoMinutesLong(diff.inMinutes);
}
