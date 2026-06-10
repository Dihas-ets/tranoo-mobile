import '../l10n/app_localizations.dart';

/// Maps stable API `code` values to localized messages.
class ApiErrorMessage {
  ApiErrorMessage._();

  static String fromMap(AppLocalizations l10n, Map<String, dynamic> data) {
    final code = data['code'] as String?;
    if (code != null && code.isNotEmpty) {
      final translated = _fromCode(l10n, code);
      if (translated != null) return translated;
    }
    final message = data['message'] as String?;
    if (message != null && message.trim().isNotEmpty) return message.trim();
    return l10n.errorOccurredTitle;
  }

  static String? subtitleForCode(AppLocalizations l10n, String? code) {
    if (code == 'ACCOUNT_NOT_FOUND') return l10n.useSameWhatsappAsSignup;
    return null;
  }

  static String? _fromCode(AppLocalizations l10n, String code) {
    switch (code) {
      case 'TOKEN_MISSING':
        return l10n.errorTokenMissing;
      case 'TOKEN_INVALID':
        return l10n.errorTokenInvalid;
      case 'USER_NOT_FOUND':
        return l10n.errorUserNotFound;
      case 'ACCOUNT_BLOCKED':
        return l10n.errorAccountBlocked;
      case 'SESSION_REQUIRED':
        return l10n.errorSessionRequired;
      case 'SESSION_REVOKED':
        return l10n.errorSessionRevoked;
      case 'SESSION_INACTIVE':
        return l10n.errorSessionInactive;
      case 'INVALID_PHONE':
        return l10n.errorInvalidPhone;
      case 'APP_REQUIRED':
        return l10n.errorAppRequired;
      case 'ACCOUNT_AMBIGUOUS':
        return l10n.errorAccountAmbiguous;
      case 'ACCOUNT_NOT_FOUND':
        return l10n.errorAccountNotFound;
      case 'OTP_SEND_FAILED':
        return l10n.errorOtpSendFailed;
      case 'MISSING_FIELDS':
        return l10n.errorMissingFields;
      case 'OTP_INVALID_OR_EXPIRED':
        return l10n.errorOtpInvalidOrExpired;
      case 'DEVICE_MISMATCH':
        return l10n.errorDeviceMismatch;
      case 'REQUEST_INVALID':
        return l10n.errorRequestInvalid;
      case 'OTP_EXPIRED':
        return l10n.errorOtpExpired;
      case 'OTP_LOCKED':
        return l10n.errorOtpLocked;
      case 'OTP_INCORRECT':
        return l10n.errorOtpIncorrect;
      case 'VERIFY_FIRST':
        return l10n.errorVerifyFirst;
      case 'PASSWORD_TOO_SHORT':
        return l10n.errorPasswordTooShort;
      case 'PASSWORD_UPDATE_FAILED':
        return l10n.errorPasswordUpdateFailed;
      case 'INTERNAL_ERROR':
        return l10n.errorInternalError;
      case 'VALIDATION_ERROR':
        return l10n.errorValidationError;
      default:
        return null;
    }
  }
}
