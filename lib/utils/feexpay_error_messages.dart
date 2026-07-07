/// Messages utilisateur alignés sur [FeexPay error codes v2](https://docs.feexpay.me/?section=error-codes&version=v2).
class FeexPayErrorMessages {
  static String fromHttpStatus(int? status, {String? fallback}) {
    switch (status) {
      case 401:
        return 'Accès refusé. Vérifiez la configuration FeexPay de la boutique.';
      case 402:
        return 'Référence de transaction introuvable.';
      case 404:
        return 'Boutique FeexPay introuvable. Vérifiez l\'identifiant boutique.';
      case 405:
        return 'Réseau ou numéro incompatible. Vérifiez le pays, l\'opérateur et le numéro saisi.';
      case 422:
        return 'Informations de paiement incorrectes. Vérifiez le montant et le numéro.';
      default:
        return fallback ?? 'Paiement impossible pour le moment.';
    }
  }

  static String fromApiPayload(dynamic data) {
    if (data == null) return 'Paiement impossible pour le moment.';
    if (data is String && data.trim().isNotEmpty) return data.trim();

    if (data is Map) {
      final statusCode = data['statusCode'] ?? data['status_code'];
      if (statusCode is int) {
        final mapped = fromHttpStatus(statusCode);
        if (mapped != 'Paiement impossible pour le moment.') return mapped;
      }

      for (final key in [
        'responsemsg',
        'responseMsg',
        'reason',
        'comment',
        'message',
        'error',
      ]) {
        final v = data[key];
        if (v is String && v.trim().isNotEmpty && !_isGeneric(v)) {
          return _humanize(v.trim());
        }
      }

      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final parts = <String>[];
        for (final e in errors) {
          if (e is Map) {
            final msg = e['constraints'];
            if (msg is Map && msg.isNotEmpty) {
              parts.add(msg.values.join(', '));
            } else if (e['message'] != null) {
              parts.add(e['message'].toString());
            }
          }
        }
        if (parts.isNotEmpty) return parts.join(' ');
      }
    }

    return 'Paiement impossible pour le moment.';
  }

  static String fromPollStatus(Map<String, dynamic> statusData) {
    final raw = statusData['raw'];
    if (raw is Map) {
      final reason = raw['reason']?.toString().trim();
      if (reason != null && reason.isNotEmpty) return _humanize(reason);
      final comment = raw['comment']?.toString().trim();
      if (comment != null && comment.isNotEmpty) return _humanize(comment);
      final msg = raw['responsemsg']?.toString().trim();
      if (msg != null && msg.isNotEmpty && msg.toUpperCase() != 'PENDING') {
        return _humanize(msg);
      }
    }
    return '';
  }

  static bool _isGeneric(String v) {
    final s = v.toLowerCase();
    return s == 'erreur init requesttopay' ||
        s == 'validation failed' ||
        s == 'pending';
  }

  static String pendingDiagnosis(Map<String, dynamic> statusData) {
    final raw = statusData['raw'];
    if (raw is! Map) {
      return 'En attente de validation sur votre téléphone.';
    }
    final operatorId = raw['operator_id']?.toString().trim() ?? '';
    final responsemsg = raw['responsemsg']?.toString().trim() ?? '';
    final reason = raw['reason']?.toString().trim() ?? '';
    final comment = raw['comment']?.toString().trim() ?? '';

    if (reason.isNotEmpty) return reason;
    if (comment.isNotEmpty) return comment;
    if (responsemsg.isNotEmpty &&
        responsemsg.toUpperCase() != 'PENDING') {
      return responsemsg;
    }
   if (operatorId.isEmpty) {
  return 'Une difficulté est survenue lors de l’initiation du paiement. '
      'Veuillez réessayer dans quelques instants.';
}
    return 'Validez le paiement sur votre téléphone (PIN ou notification MTN).';
  }

  static String _humanize(String v) {
    if (v.contains('amount must not be less than')) {
      return 'Montant minimum : 100 FCFA.';
    }
    if (v.toLowerCase().contains('mauvais réseau')) {
      return fromHttpStatus(405);
    }
    return v;
  }
}
