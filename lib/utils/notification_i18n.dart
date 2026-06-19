/// Résolution des notifications système (clés alignées sur `src/utils/notificationI18n.js`).
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationI18n {
  static const Map<String, Map<String, String>> _templates = {
    'delivery.created.title': {
      'fr': 'Nouvelle livraison disponible',
      'en': 'New delivery available',
      'ar': 'توصيل جديد متاح',
    },
    'delivery.created.message': {
      'fr': 'Une nouvelle livraison est disponible pour prise en charge.',
      'en': 'A new delivery is available for pickup.',
      'ar': 'توصيل جديد متاح للاستلام.',
    },
    'delivery.assigned.title': {
      'fr': 'Livraison assignée',
      'en': 'Delivery assigned',
      'ar': 'تم تعيين التوصيل',
    },
    'delivery.assigned.message': {
      'fr': 'Une livraison vous a été assignée.',
      'en': 'A delivery has been assigned to you.',
      'ar': 'تم تعيين توصيل لك.',
    },
    'delivery.picked_up.title': {
      'fr': 'Colis récupéré',
      'en': 'Package picked up',
      'ar': 'تم استلام الطرد',
    },
    'delivery.picked_up.message': {
      'fr': 'Le colis a été récupéré par le livreur.',
      'en': 'The package has been picked up by the courier.',
      'ar': 'استلم السائق الطرد.',
    },
    'delivery.arrived.title': {
      'fr': 'Livreur arrivé',
      'en': 'Courier arrived',
      'ar': 'وصل السائق',
    },
    'delivery.arrived.message': {
      'fr':
          'Votre livreur est arrivé. Choisissez de payer ou de retourner le colis.',
      'en': 'Your courier has arrived. Choose to pay or return the package.',
      'ar': 'وصل السائق. اختر الدفع أو إرجاع الطرد.',
    },
    'delivery.delivered.title': {
      'fr': 'Colis livré',
      'en': 'Package delivered',
      'ar': 'تم تسليم الطرد',
    },
    'delivery.delivered.message': {
      'fr': 'Le colis a été livré.',
      'en': 'The package has been delivered.',
      'ar': 'تم تسليم الطرد.',
    },
    'delivery.refused.title': {
      'fr': 'Colis refusé',
      'en': 'Package refused',
      'ar': 'تم رفض الطرد',
    },
    'delivery.refused.message': {
      'fr': 'Le colis a été refusé par le client.',
      'en': 'The package was refused by the customer.',
      'ar': 'رفض العميل الطرد.',
    },
    'delivery.return.title': {
      'fr': 'Retour de pièce signalé',
      'en': 'Part return reported',
      'ar': 'تم الإبلاغ عن إرجاع قطعة',
    },
    'delivery.return.message': {
      'fr':
          "Le chauffeur a signalé un retour de pièce par l'acheteur pour cette livraison.",
      'en': 'The driver reported a part return by the buyer for this delivery.',
      'ar': 'أبلغ السائق عن إرجاع قطعة من المشتري لهذا التوصيل.',
    },
    'delivery.updated.title': {
      'fr': 'Mise à jour livraison',
      'en': 'Delivery update',
      'ar': 'تحديث التوصيل',
    },
    'delivery.updated.message': {
      'fr': 'Votre livraison a été mise à jour.',
      'en': 'Your delivery has been updated.',
      'ar': 'تم تحديث توصيلك.',
    },
    'delivery.refusedReminder.title': {
      'fr': 'Colis refusé - Rappel des conditions',
      'en': 'Package refused - Terms reminder',
      'ar': 'طرد مرفوض - تذكير بالشروط',
    },
    'delivery.refusedReminder.message': {
      'fr':
          'Le colis a été refusé. Conformément aux conditions, les frais de livraison restent dus, seuls les frais du colis peuvent être remboursés.',
      'en':
          'The package was refused. Per the terms, delivery fees remain due; only the item cost may be refunded.',
      'ar':
          'تم رفض الطرد. وفق الشروط، تبقى رسوم التوصيل مستحقة ويمكن استرداد ثمن القطعة فقط.',
    },
    'payment.balanceUpdated.title': {
      'fr': 'Balance mise à jour',
      'en': 'Balance updated',
      'ar': 'تم تحديث الرصيد',
    },
    'payment.balanceDelivered.message': {
      'fr':
          'Votre balance a été créditée de {amount} XOF pour une livraison livrée.',
      'en': 'Your balance was credited {amount} XOF for a completed delivery.',
      'ar': 'تم إضافة {amount} XOF إلى رصيدك مقابل توصيل مكتمل.',
    },
    'payment.balanceRefused.message': {
      'fr':
          'Votre balance a été créditée de {amount} XOF pour une livraison refusée (frais de livraison).',
      'en':
          'Your balance was credited {amount} XOF for a refused delivery (delivery fees).',
      'ar':
          'تم إضافة {amount} XOF إلى رصيدك مقابل توصيل مرفوض (رسوم التوصيل).',
    },
    'payment.balanceConfirmed.message': {
      'fr':
          'Votre balance a été créditée de {amount} XOF après confirmation de livraison par l’acheteur.',
      'en':
          'Your balance was credited {amount} XOF after buyer delivery confirmation.',
      'ar': 'تم إضافة {amount} XOF إلى رصيدك بعد تأكيد المشتري للتوصيل.',
    },
    'newArticle.buyer.title': {
      'fr': 'Nouveau {articleTypeLabel} disponible',
      'en': 'New {articleTypeLabel} available',
      'ar': '{articleTypeLabel} جديد متاح',
    },
    'newArticle.buyer.message': {
      'fr': '{articleTitle}{priceSuffix}',
      'en': '{articleTitle}{priceSuffix}',
      'ar': '{articleTitle}{priceSuffix}',
    },
    'newArticle.seller.title': {
      'fr': 'Article publié',
      'en': 'Listing published',
      'ar': 'تم نشر الإعلان',
    },
    'newArticle.seller.message': {
      'fr':
          'Votre {articleTypeLabel} « {articleTitle} » est maintenant en ligne{priceSuffix}.',
      'en':
          'Your {articleTypeLabel} "{articleTitle}" is now online{priceSuffix}.',
      'ar':
          '{articleTypeLabel} « {articleTitle} » متاح الآن على المنصة{priceSuffix}.',
    },
    'newArticle.admin.title': {
      'fr': 'Nouvel article {articleTypeLabel}',
      'en': 'New {articleTypeLabel} listing',
      'ar': 'إعلان {articleTypeLabel} جديد',
    },
    'newArticle.admin.message': {
      'fr': 'Un vendeur a publié : « {articleTitle} »{priceSuffix}',
      'en': 'A seller published: "{articleTitle}"{priceSuffix}',
      'ar': 'نشر بائع: « {articleTitle} »{priceSuffix}',
    },
    'verification.ready.title': {
      'fr': 'Vérification : {articleTitle}',
      'en': 'Verification: {articleTitle}',
      'ar': 'التحقق: {articleTitle}',
    },
    'verification.ready.titleFallback': {
      'fr': 'Vérification terminée',
      'en': 'Verification completed',
      'ar': 'اكتمل التحقق',
    },
    'verification.ready.message': {
      'fr':
          'Votre article « {articleTitle} » a été vérifié. Décidez maintenant de votre achat.',
      'en':
          'Your item "{articleTitle}" has been verified. Decide on your purchase now.',
      'ar': 'تم التحقق من « {articleTitle} ». قرّر بشأن شرائك الآن.',
    },
    'verification.ready.messageFallback': {
      'fr': 'Votre article a été vérifié. Décidez maintenant de votre achat.',
      'en': 'Your item has been verified. Decide on your purchase now.',
      'ar': 'تم التحقق من المنتج. قرّر بشأن شرائك الآن.',
    },
    'verification.resultAdmin.title': {
      'fr': 'Vérification {actionTitleLabel}{articleSuffix}',
      'en': 'Verification {actionTitleLabel}{articleSuffix}',
      'ar': 'التحقق {actionTitleLabel}{articleSuffix}',
    },
    'verification.resultAdmin.message': {
      'fr':
          '{buyerName} a {actionLabel} la demande liée à l’article {articleTitle}.',
      'en': '{buyerName} {actionLabel} the request for item {articleTitle}.',
      'ar': '{buyerName} {actionLabel} الطلب المتعلق بالمنتج {articleTitle}.',
    },
    'alert.vehicle.title': {
      'fr': 'Nouvelle alerte véhicule',
      'en': 'New vehicle alert',
      'ar': 'تنبيه مركبة جديد',
    },
    'alert.vehicle.message': {
      'fr':
          'Un acheteur recherche {quantity} véhicule(s). Caractéristiques : {details}',
      'en': 'A buyer is looking for {quantity} vehicle(s). Details: {details}',
      'ar': 'مشتري يبحث عن {quantity} مركبة. التفاصيل: {details}',
    },
    'alert.piece.title': {
      'fr': 'Nouvelle alerte pièce',
      'en': 'New parts alert',
      'ar': 'تنبيه قطع جديد',
    },
    'alert.piece.message': {
      'fr':
          'Un acheteur recherche {quantity} pièce(s) : {pieceName} pour {marque} {modele}. {details}',
      'en':
          'A buyer is looking for {quantity} part(s): {pieceName} for {marque} {modele}. {details}',
      'ar':
          'مشتري يبحث عن {quantity} قطعة: {pieceName} لـ {marque} {modele}. {details}',
    },
    'alert.proposal.title': {
      'fr': 'Une proposition correspond à votre alerte',
      'en': 'A listing matches your alert',
      'ar': 'عرض يطابق تنبيهك',
    },
    'alert.proposal.message': {
      'fr':
          'Votre alerte a reçu une nouvelle proposition : « {articleTitle} ».',
      'en': 'Your alert received a new proposal: "{articleTitle}".',
      'ar': 'تلقى تنبيهك عرضاً جديداً: « {articleTitle} ».',
    },
    'article.rejected.title': {
      'fr': 'Annonce rejetée',
      'en': 'Listing rejected',
      'ar': 'تم رفض الإعلان',
    },
    'article.rejected.message': {
      'fr':
          'Votre {articleTypeLabel} « {articleTitle} » a été rejetée. Motif : {motifRejet}',
      'en':
          'Your {articleTypeLabel} "{articleTitle}" was rejected. Reason: {motifRejet}',
      'ar':
          'تم رفض {articleTypeLabel} « {articleTitle} ». السبب: {motifRejet}',
    },
    'chat.new.title': {
      'fr': 'Nouvelle discussion',
      'en': 'New conversation',
      'ar': 'محادثة جديدة',
    },
    'chat.new.message': {
      'fr':
          '{senderName} a initié une discussion concernant votre article « {articleTitle} »',
      'en':
          '{senderName} started a conversation about your listing "{articleTitle}"',
      'ar':
          'بدأ {senderName} محادثة بخصوص إعلانك « {articleTitle} »',
    },
    'tricycle.newRequest.title': {
      'fr': 'Nouvelle demande Tricycle',
      'en': 'New Tricycle request',
      'ar': 'طلب تريكيلو جديد',
    },
    'tricycle.newRequest.message': {
      'fr': '{buyerName} souhaite vous contacter pour un déplacement en tricycle.',
      'en': '{buyerName} wants to contact you for a tricycle ride.',
      'ar': 'يريد {buyerName} التواصل معك لرحلة تريكيلو.',
    },
    'tricycle.accepted.title': {
      'fr': 'Demande Tricycle acceptée',
      'en': 'Tricycle request accepted',
      'ar': 'تم قبول طلب التريكيلو',
    },
    'tricycle.accepted.message': {
      'fr':
          'Le chauffeur a accepté votre demande. Vous pouvez maintenant échanger librement.',
      'en': 'The driver accepted your request. You can chat freely now.',
      'ar': 'قبل السائق طلبك. يمكنك المراسلة الآن.',
    },
    'tricycle.cancelled.title': {
      'fr': 'Demande Tricycle annulée',
      'en': 'Tricycle request cancelled',
      'ar': 'تم إلغاء طلب التريكيلو',
    },
    'tricycle.cancelled.message': {
      'fr': 'L’acheteur a annulé sa demande de tricycle.',
      'en': 'The buyer cancelled their tricycle request.',
      'ar': 'ألغى المشتري طلب التريكيلو.',
    },
    'tricycle.rejected.title': {
      'fr': 'Demande Tricycle rejetée',
      'en': 'Tricycle request rejected',
      'ar': 'تم رفض طلب التريكيلو',
    },
    'tricycle.rejected.message': {
      'fr': 'Le chauffeur a rejeté votre demande de tricycle.',
      'en': 'The driver rejected your tricycle request.',
      'ar': 'رفض السائق طلب التريكيلو.',
    },
    'purchase.validated.title': {
      'fr': 'Achat validé',
      'en': 'Purchase confirmed',
      'ar': 'تم تأكيد الشراء',
    },
    'purchase.validated.message': {
      'fr': 'Un achat a été validé',
      'en': 'A purchase has been confirmed',
      'ar': 'تم تأكيد عملية شراء',
    },
  };

  static String _normalizeLocale(String? locale) {
    final l = (locale ?? 'fr').toLowerCase().split('-').first;
    if (l == 'en' || l == 'ar') return l;
    return 'fr';
  }

  static String _articleTypeLabel(String? articleType, String locale) {
    final t = (articleType ?? 'vehicle').toLowerCase();
    if (t == 'piece') {
      return const {'fr': 'pièce', 'en': 'part', 'ar': 'قطعة'}[locale] ??
          'pièce';
    }
    if (t == 'moto') {
      return const {'fr': 'moto', 'en': 'motorcycle', 'ar': 'دراجة'}[locale] ??
          'moto';
    }
    return const {'fr': 'véhicule', 'en': 'vehicle', 'ar': 'مركبة'}[locale] ??
        'véhicule';
  }

  static Map<String, String> _expandParams(
    Map<String, dynamic> params,
    String locale,
  ) {
    final out = <String, String>{};
    params.forEach((key, value) {
      out[key] = value?.toString() ?? '';
    });
    if (params.containsKey('articleType') &&
        !out.containsKey('articleTypeLabel')) {
      out['articleTypeLabel'] =
          _articleTypeLabel(params['articleType']?.toString(), locale);
    }
    if (params.containsKey('action')) {
      final action = params['action']?.toString();
      if (action == 'approve') {
        out['actionLabel'] = const {
          'fr': 'a validé',
          'en': 'has approved',
          'ar': 'وافق على',
        }[locale]!;
        out['actionTitleLabel'] = const {
          'fr': 'validée',
          'en': 'approved',
          'ar': 'مقبولة',
        }[locale]!;
      } else if (action == 'reject') {
        out['actionLabel'] = const {
          'fr': 'a rejeté',
          'en': 'has rejected',
          'ar': 'رفض',
        }[locale]!;
        out['actionTitleLabel'] = const {
          'fr': 'rejetée',
          'en': 'rejected',
          'ar': 'مرفوضة',
        }[locale]!;
      }
    }
    if (out.containsKey('articleTitle') && !out.containsKey('articleSuffix')) {
      final title = out['articleTitle'] ?? '';
      out['articleSuffix'] = title.isNotEmpty ? ' — $title' : '';
    }
    return out;
  }

  static String format(String? key, String locale, Map<String, dynamic> params) {
    if (key == null || key.isEmpty) return '';
    final loc = _normalizeLocale(locale);
    final entry = _templates[key];
    if (entry == null) return key;
    var text = entry[loc] ?? entry['fr'] ?? key;
    final expanded = _expandParams(params, loc);
    text = text.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
      return expanded[match.group(1)] ?? '';
    });
    return text;
  }

  static Map<String, dynamic> _readParams(Map<String, dynamic> notif) {
    final raw = notif['i18nParams'];
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    final data = notif['data'];
    if (data is Map && data['i18nParams'] is Map) {
      return Map<String, dynamic>.from(data['i18nParams'] as Map);
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic> parseI18nParams(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic> fromFcmData(Map<String, String> data) {
    return {
      if (data['titleKey'] != null && data['titleKey']!.isNotEmpty)
        'titleKey': data['titleKey'],
      if (data['messageKey'] != null && data['messageKey']!.isNotEmpty)
        'messageKey': data['messageKey'],
      'i18nParams': parseI18nParams(data['i18nParams']),
      if (data['title'] != null) 'title': data['title'],
      if (data['message'] != null) 'message': data['message'],
    };
  }

  static ({String title, String body}) resolvePush(
    RemoteMessage message,
    String locale, {
    String defaultTitle = 'Tranoo',
  }) {
    final data = message.data.map(
      (k, v) => MapEntry(k, v?.toString() ?? ''),
    );
    return resolvePushFromData(
      notificationTitle: message.notification?.title,
      notificationBody: message.notification?.body,
      data: data,
      locale: locale,
      defaultTitle: defaultTitle,
    );
  }

  static ({String title, String body}) resolvePushFromData({
    String? notificationTitle,
    String? notificationBody,
    required Map<String, String> data,
    required String locale,
    String defaultTitle = 'Tranoo',
  }) {
    final notif = fromFcmData(data);
    final titleKey = notif['titleKey']?.toString();
    if (titleKey != null && titleKey.isNotEmpty) {
      return (
        title: resolveTitle(
          notif,
          locale: locale,
          fallback: defaultTitle,
        ),
        body: resolveMessage(
          notif,
          locale: locale,
          fallback: notificationBody ?? data['message'] ?? '',
        ),
      );
    }
    return (
      title: notificationTitle ?? data['title'] ?? defaultTitle,
      body: notificationBody ?? data['message'] ?? '',
    );
  }

  static String resolveTitle(
    Map<String, dynamic> notif, {
    required String locale,
    String fallback = '',
  }) {
    final key = notif['titleKey']?.toString();
    if (key != null && key.isNotEmpty) {
      return format(key, locale, _readParams(notif));
    }
    final title = notif['title']?.toString().trim();
    if (title != null && title.isNotEmpty) return title;
    return fallback;
  }

  static String resolveMessage(
    Map<String, dynamic> notif, {
    required String locale,
    String fallback = '',
  }) {
    final key = notif['messageKey']?.toString();
    if (key != null && key.isNotEmpty) {
      return format(key, locale, _readParams(notif));
    }
    final message = notif['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    return fallback;
  }
}
