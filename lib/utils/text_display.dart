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
