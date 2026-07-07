import 'dart:developer' as developer;

/// Logs paiement visibles dans `flutter run` (filtre: PAYMENT_DEBUG).
class PaymentDebugLogger {
  static const _name = 'PAYMENT_DEBUG';

  static void log(String tag, String message, [Object? detail]) {
    final line =
        detail != null ? '[$tag] $message | $detail' : '[$tag] $message';
    // ignore: avoid_print
    print(line);
    developer.log(line, name: _name);
  }

  static void step(String flow, String step, [Map<String, Object?>? data]) {
    if (data != null && data.isNotEmpty) {
      log(flow, step, data);
    } else {
      log(flow, step);
    }
  }

  static void feexConfig({
    required bool tokenOk,
    required bool shopOk,
    String? baseUrl,
  }) {
    log(
      'FEEXPAY_CONFIG',
      'token=${tokenOk ? "OK" : "MANQUANT"} '
          'shop=${shopOk ? "OK" : "MANQUANT"} baseUrl=${baseUrl ?? "?"}',
    );
  }

  static void api(
    String method,
    String path, {
    int? status,
    Object? body,
    Object? error,
  }) {
    if (error != null) {
      log('API', '$method $path ERREUR', error);
      return;
    }
    log('API', '$method $path → status=${status ?? "?"}', body);
  }

  static void choicePageReturn(
    String flow,
    dynamic result, {
    required bool paid,
    String? feexId,
    bool? callbackSuccess,
    String? transKey,
    Map<String, Object?>? extra,
  }) {
    log(
      flow,
      'ChoicePage result=$result feexId=$feexId paid=$paid '
          'callbackSuccess=$callbackSuccess transKey=$transKey',
      extra,
    );
  }

  static void blocked(String flow, String reason, [Object? detail]) {
    log(flow, 'BLOQUE: $reason', detail);
  }
}
