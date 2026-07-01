import 'package:dio/dio.dart';

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
    final messageKey = data['messageKey'] as String?;
    if (messageKey != null && messageKey.isNotEmpty) {
      final legacy = _fromLegacyMessageKey(l10n, messageKey);
      if (legacy != null) return legacy;
    }
    final message = data['message'] as String?;
    if (message != null && message.trim().isNotEmpty) return message.trim();
    return l10n.errorOccurredTitle;
  }

  static String fromDio(AppLocalizations l10n, DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      return fromMap(l10n, Map<String, dynamic>.from(data));
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return l10n.errorConnectionFailed;
    }
    return l10n.errorOccurredTitle;
  }

  static String? subtitleForCode(AppLocalizations l10n, String? code) {
    if (code == 'ACCOUNT_NOT_FOUND') return l10n.useSameWhatsappAsSignup;
    return null;
  }

  static String? _fromLegacyMessageKey(AppLocalizations l10n, String key) {
    switch (key) {
      case 'galleryTransitaireOnly':
        return l10n.errorGalleryTransitaireOnly;
      case 'galleryMustBeArray':
        return l10n.errorGalleryMustBeArray;
      case 'galleryMaxItems':
        return l10n.errorGalleryMaxItems;
      case 'galleryInvalidItem':
        return l10n.errorGalleryInvalidItem;
      case 'galleryItemTypeUrl':
        return l10n.errorGalleryItemTypeUrl;
      default:
        return null;
    }
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
      case 'NOT_AUTHENTICATED':
        return l10n.errorNotAuthenticated;
      case 'FORBIDDEN':
        return l10n.errorForbidden;
      case 'ACCESS_DENIED':
        return l10n.errorAccessDenied;
      case 'NOT_FOUND':
        return l10n.errorNotFound;
      case 'NO_UPDATE_DATA':
        return l10n.errorNoUpdateData;
      case 'DESCRIPTION_TOO_LONG':
        return l10n.errorDescriptionTooLong;
      case 'GALLERY_TRANSITAIRE_ONLY':
        return l10n.errorGalleryTransitaireOnly;
      case 'GALLERY_MUST_BE_ARRAY':
        return l10n.errorGalleryMustBeArray;
      case 'GALLERY_MAX_ITEMS':
        return l10n.errorGalleryMaxItems;
      case 'GALLERY_INVALID_ITEM':
        return l10n.errorGalleryInvalidItem;
      case 'GALLERY_ITEM_TYPE_URL':
        return l10n.errorGalleryItemTypeUrl;
      case 'VENDEUR_TYPE_SELLERS_ONLY':
        return l10n.errorVendeurTypeSellersOnly;
      case 'VENDEUR_TYPE_INVALID':
        return l10n.errorVendeurTypeInvalid;
      case 'PHONE_ALREADY_USED':
        return l10n.errorPhoneAlreadyUsed;
      case 'PHONE_AMBIGUOUS':
        return l10n.errorPhoneAmbiguous;
      case 'USER_INCOMPLETE':
        return l10n.errorUserIncomplete;
      case 'PROFILE_UPDATE_FAILED':
        return l10n.errorProfileUpdateFailed;
      case 'FIREBASE_EMAIL_SYNC_FAILED':
        return l10n.errorFirebaseEmailSyncFailed;
      case 'FCM_TOKEN_REQUIRED':
        return l10n.errorFcmTokenRequired;
      case 'ARTICLE_ID_REQUIRED':
        return l10n.errorArticleIdRequired;
      case 'FILE_REQUIRED':
        return l10n.errorFileRequired;
      case 'TRANSITAIRE_ACTIF':
        return l10n.errorTransitaireActif;
      case 'ACHAT_ANNULE':
        return l10n.errorAchatAnnule;
      default:
        return null;
    }
  }
}
