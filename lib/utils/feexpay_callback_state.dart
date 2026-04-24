class FeexPayCallbackState {
  static bool? _lastSuccess;
  static String? _lastArgs;
  static DateTime? _lastAt;

  static void report({required bool success, String? args}) {
    _lastSuccess = success;
    _lastArgs = args;
    _lastAt = DateTime.now();
  }

  static ({bool? success, String? args, DateTime? at}) takeLatest() {
    final payload = (success: _lastSuccess, args: _lastArgs, at: _lastAt);
    _lastSuccess = null;
    _lastArgs = null;
    _lastAt = null;
    return payload;
  }
}

