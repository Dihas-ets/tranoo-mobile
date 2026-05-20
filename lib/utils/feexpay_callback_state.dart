class FeexPayCallbackState {
  static bool? _lastSuccess;
  static String? _lastArgs;
  static String? _lastTransactionId;
  static DateTime? _lastAt;

  /// À appeler avant d’ouvrir [ChoicePage] pour ne pas réutiliser un callback
  /// d’une session précédente (deep link `/payment-success` enregistré dans [report]).
  static void clearPendingAtNewCheckout() {
    _lastSuccess = null;
    _lastArgs = null;
    _lastTransactionId = null;
    _lastAt = null;
  }

  static void report({
    required bool success,
    String? args,
    String? transactionId,
  }) {
    _lastSuccess = success;
    _lastArgs = args;
    _lastTransactionId = transactionId;
    _lastAt = DateTime.now();
  }

  static ({
    bool? success,
    String? args,
    String? transactionId,
    DateTime? at,
  }) takeLatest() {
    final payload = (
      success: _lastSuccess,
      args: _lastArgs,
      transactionId: _lastTransactionId,
      at: _lastAt,
    );
    _lastSuccess = null;
    _lastArgs = null;
    _lastTransactionId = null;
    _lastAt = null;
    return payload;
  }
}

