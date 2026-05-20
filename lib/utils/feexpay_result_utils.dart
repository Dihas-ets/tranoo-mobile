import 'dart:convert';

/// Statut explicite dans la payload FeexPay (prioritaire sur le bool [success],
/// souvent [false] même après paiement réussi côté passerelle).
bool? _statusFieldIndicatesSuccess(String raw) {
  final s = raw.toLowerCase().trim();
  if (s.isEmpty) return null;
  if (s.contains('fail') ||
      s.contains('error') ||
      s.contains('cancel') ||
      s.contains('annul') ||
      s.contains('declin') ||
      s.contains('rejected') ||
      s.contains('expired')) {
    return false;
  }
  if (s.contains('success') ||
      s.contains('successful') ||
      s.contains('paid') ||
      s.contains('ok') ||
      s.contains('completed') ||
      s.contains('approved') ||
      s.contains('complete')) {
    return true;
  }
  return null;
}

String _collectStatusString(Map<dynamic, dynamic> map) {
  const keys = [
    'status',
    'state',
    'result',
    'paymentStatus',
    'payment_status',
    'transaction_status',
    'paymentState',
  ];
  final parts = <String>[];
  for (final k in keys) {
    final v = map[k];
    if (v != null && v.toString().trim().isNotEmpty) {
      parts.add(v.toString());
    }
  }
  return parts.join(' ').toLowerCase().trim();
}

/// Extrait l'identifiant FeexPay (UUID, ref, etc.) depuis le retour [ChoicePage].
String? extractFeexPayTransactionId(dynamic result) {
  if (result is Map) {
    final keys = [
      'id_transaction',
      'idTransaction',
      'transaction_id',
      'transactionId',
      'reference',
      'ref',
      'order_id',
      'orderId',
      'short_code',
      'shortCode',
      'payment_reference',
      'custom_id',
      'customId',
      'callbackArgs',
      'id',
    ];
    for (final k in keys) {
      final v = result[k]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
  }
  if (result is String) {
    final parsed = result.trim();
    if (parsed.startsWith('{') && parsed.endsWith('}')) {
      try {
        final m = jsonDecode(parsed);
        if (m is Map<String, dynamic>) {
          return extractFeexPayTransactionId(m);
        }
      } catch (_) {}
    }
    final uuidReg = RegExp(
      r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}',
    );
    final m = uuidReg.firstMatch(parsed);
    if (m != null) return m.group(0);
    final trn = RegExp(r'\bTRN-[A-Z0-9-]+\b', caseSensitive: false)
        .firstMatch(parsed);
    if (trn != null) return trn.group(0);
  }
  return null;
}

/// Interprète le résultat renvoyé par [ChoicePage] / [FeexPayChoiceCallbackPage] (Map, bool, String JSON…).
///
/// Ne se fie pas seul au bool [success] : le SDK peut renvoyer [success: false] alors que
/// [status] vaut encore `SUCCESSFUL` / `paid` (intégration classique FeexPay).
bool feexPayReturnIndicatesSuccess(dynamic result) {
  if (result == null) return false;
  if (result is bool) return result;
  if (result is Map) {
    final map = Map<dynamic, dynamic>.from(result);
    final statusBlob = _collectStatusString(map);
    final fromStatus = _statusFieldIndicatesSuccess(statusBlob);
    if (fromStatus == true) return true;
    if (fromStatus == false) return false;

    final successFlag = map['success'];
    if (successFlag is bool) return successFlag;
  }
  if (result is String) {
    final t = result.trim();
    if (t.startsWith('{') && t.endsWith('}')) {
      try {
        final m = jsonDecode(t);
        if (m is Map<String, dynamic>) {
          return feexPayReturnIndicatesSuccess(m);
        }
      } catch (_) {}
    }
    final fromStr = _statusFieldIndicatesSuccess(t);
    if (fromStr != null) return fromStr;
  }
  final payload = result.toString().toLowerCase();
  if (payload.contains('fail') ||
      payload.contains('error') ||
      payload.contains('cancel')) {
    return false;
  }
  return payload.contains('success') ||
      payload.contains('successful') ||
      payload.contains('paid') ||
      payload.contains('ok');
}
