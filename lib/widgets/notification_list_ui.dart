import 'package:flutter/material.dart';
import 'package:tranoo/utils/notification_i18n.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';

enum NotificationVisualKind {
  systemApp,
  pieceAlert,
  vehicleAlert,
  proposalAlert,
  simple,
  verification,
}

NotificationVisualKind resolveNotificationVisualKind(
    Map<String, dynamic> notif) {
  final type = (notif['type'] ?? '').toString();
  final data = notif['data'] is Map
      ? Map<String, dynamic>.from(notif['data'])
      : <String, dynamic>{};
  final requestType = (data['requestType'] ?? '').toString();
  final sender = (notif['sender'] ?? '').toString();

  if (type == 'verification') return NotificationVisualKind.verification;
  if (type == 'proposition_alerte') {
    return NotificationVisualKind.proposalAlert;
  }
  if (type == 'alerte' ||
      requestType == 'piece_search' ||
      requestType == 'vehicle_search') {
    return requestType == 'piece_search'
        ? NotificationVisualKind.pieceAlert
        : NotificationVisualKind.vehicleAlert;
  }
  if (sender == 'system' ||
      type == 'new_article' ||
      type == 'delivery' ||
      type == 'paiement') {
    return NotificationVisualKind.systemApp;
  }
  return NotificationVisualKind.simple;
}

IconData iconForNotificationKind(NotificationVisualKind kind) {
  switch (kind) {
    case NotificationVisualKind.pieceAlert:
      return Icons.build_outlined;
    case NotificationVisualKind.vehicleAlert:
      return Icons.directions_car_outlined;
    case NotificationVisualKind.proposalAlert:
      return Icons.reply_outlined;
    case NotificationVisualKind.verification:
      return Icons.verified_outlined;
    case NotificationVisualKind.simple:
      return Icons.notifications_none_outlined;
    case NotificationVisualKind.systemApp:
      return Icons.storefront_outlined;
  }
}

Widget buildNotificationLeadingAvatar({
  required NotificationVisualKind kind,
  String? appLogoAsset,
}) {
  if (kind == NotificationVisualKind.systemApp &&
      appLogoAsset != null &&
      appLogoAsset.isNotEmpty) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: SizedBox(
          width: 36,
          height: 36,
          child: Padding(
            // évite le crop sur les logos "carrés" ou avec marges
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              appLogoAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                iconForNotificationKind(kind),
                color: Colors.black87,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
  return CircleAvatar(
    radius: 22,
    backgroundColor: Colors.grey[200],
    child: Icon(
      iconForNotificationKind(kind),
      color: Colors.black87,
      size: 22,
    ),
  );
}

String resolveNotificationTitle(
  Map<String, dynamic> notif,
  String locale, {
  String fallback = '',
}) =>
    NotificationI18n.resolveTitle(notif, locale: locale, fallback: fallback);

String resolveNotificationMessage(
  Map<String, dynamic> notif,
  String locale, {
  String fallback = '',
}) =>
    NotificationI18n.resolveMessage(notif, locale: locale, fallback: fallback);

String notificationPreviewText(
  Map<String, dynamic> notif, {
  required String defaultLabel,
  String? locale,
}) {
  final data = notif['data'] is Map
      ? Map<String, dynamic>.from(notif['data'])
      : <String, dynamic>{};
  final message = locale != null
      ? NotificationI18n.resolveMessage(
          notif,
          locale: locale,
          fallback: defaultLabel,
        ).trim()
      : (notif['message'] ?? '').toString().trim();
  final articleTitle = (data['articleTitle'] ?? '').toString().trim();
  if (articleTitle.isNotEmpty) return articleTitle;
  if (message.length > 90) return '${message.substring(0, 90)}...';
  return message.isNotEmpty ? message : defaultLabel;
}

String? notificationThumbUrl(Map<String, dynamic> notif) {
  final data = notif['data'] is Map
      ? Map<String, dynamic>.from(notif['data'])
      : <String, dynamic>{};
  final thumb = (data['thumbnailUrl'] ?? '').toString();
  if (thumb.isNotEmpty) return thumb;
  final att = notif['attachments'];
  if (att is Map) {
    final imgs = att['images'];
    if (imgs is List && imgs.isNotEmpty) return imgs.first.toString();
  }
  final photos = data['photos'];
  if (photos is List && photos.isNotEmpty) return photos.first.toString();
  return null;
}

Widget buildNotificationThumbnail(
  BuildContext context,
  String? url,
  NotificationVisualKind kind,
) {
  const w = 112.0;
  const h = 63.0;
  final placeholder = Container(
    width: w,
    height: h,
    color: Colors.grey[200],
    alignment: Alignment.center,
    child: Icon(
      iconForNotificationKind(kind),
      color: Colors.grey[500],
      size: 32,
    ),
  );
  if (url == null || url.isEmpty) return placeholder;
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: TranooNetworkImage(
      url: url,
      width: w,
      height: h,
      fit: BoxFit.cover,
      cloudinaryWidthPx: cloudinaryWidthPx(context, logicalWidth: w),
    ),
  );
}

Widget wrapNotificationDetailDialog(BuildContext context, Widget child) {
  return Dialog(
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Fermer',
              icon: const Icon(Icons.close, size: 22, color: Colors.black87),
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildMonochromeNotificationDetail({
  required String title,
  String? dateStr,
  required Widget body,
  Widget? action,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.black,
          letterSpacing: -0.3,
        ),
      ),
      if (dateStr != null && dateStr.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
      const SizedBox(height: 12),
      body,
      if (action != null) ...[
        const SizedBox(height: 20),
        action,
      ],
    ],
  );
}

ButtonStyle monochromeNotificationButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
