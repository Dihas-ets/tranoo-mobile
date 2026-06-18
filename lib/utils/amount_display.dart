import 'package:flutter/services.dart';

/// Saisie : chiffres et au plus un séparateur décimal (`,` ou `.`).
final RegExp _decimalInputLine = RegExp(r'^[0-9]*([.,][0-9]*)?$');

/// Affichage FCFA : milliers séparés par `.`, décimales après `,` si présentes.
String formatFcfaDots(String? raw) {
  if (raw == null) return '';
  final n = tryParseFlexibleAmount(raw);
  if (n == null) return raw.trim();
  final s = n.toString();
  final parts = s.split('.');
  final intPart = parts[0];
  final grouped = _groupThousandsWithDots(intPart);
  final head = grouped;
  if (parts.length > 1 && parts[1].isNotEmpty) {
    return '$head,${parts[1]}';
  }
  return head;
}

String _groupThousandsWithDots(String digits) {
  if (digits.length <= 3) return digits;
  final rev = digits.split('').reversed.join();
  final buf = StringBuffer();
  for (var i = 0; i < rev.length; i++) {
    if (i > 0 && i % 3 == 0) buf.write('.');
    buf.write(rev[i]);
  }
  return buf.toString().split('').reversed.join();
}

/// Interprète un montant / nombre saisi avec `,` ou `.` (décimal ou milliers simples).
num? tryParseFlexibleAmount(String? raw) {
  if (raw == null) return null;
  var s = raw.trim().replaceAll(RegExp(r'\s'), '');
  if (s.isEmpty) return null;
  s = s.replaceAll(RegExp(r'[^\d.,]'), '');
  if (s.isEmpty) return null;

  final hasC = s.contains(',');
  final hasD = s.contains('.');
  if (hasC && hasD) {
    final lc = s.lastIndexOf(',');
    final ld = s.lastIndexOf('.');
    if (lc > ld) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }
  } else if (hasC) {
    s = s.replaceAll(',', '.');
  } else if (hasD) {
    if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(s)) {
      s = s.replaceAll('.', '');
    }
  }
  return num.tryParse(s);
}

String truncateWithEllipsis(String input, {int maxLen = 56}) {
  final t = input.trim();
  if (t.length <= maxLen) return t;
  if (maxLen <= 3) return '...';
  return '${t.substring(0, maxLen - 3)}...';
}

String concatLocationParts({
  String? location,
  String? company,
  String? ville,
  String? pays,
}) {
  final parts = <String>[
    if (location != null && location.trim().isNotEmpty) location.trim(),
    if (company != null && company.trim().isNotEmpty) company.trim(),
    if (ville != null && ville.trim().isNotEmpty) ville.trim(),
    if (pays != null && pays.trim().isNotEmpty) pays.trim(),
  ];
  return parts.join(' · ');
}

/// `FilteringTextInputFormatter` pour cylindre / distance / prix (décimaux optionnels).
List<TextInputFormatter> get decimalOptionalInputFormatters => [
      FilteringTextInputFormatter.allow(_decimalInputLine),
    ];
