import 'package:flutter/material.dart';

enum NotificationVisualKind {
  systemApp,
  pieceAlert,
  vehicleAlert,
  proposalAlert,
  simple,
  verification,
}

NotificationVisualKind resolveNotificationVisualKind(Map<String, dynamic> notif) {
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
        child: Image.asset(
          appLogoAsset,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            iconForNotificationKind(kind),
            color: Colors.black87,
            size: 22,
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

String notificationPreviewText(Map<String, dynamic> notif) {
  final data = notif['data'] is Map
      ? Map<String, dynamic>.from(notif['data'])
      : <String, dynamic>{};
  final message = (notif['message'] ?? '').toString().trim();
  final articleTitle = (data['articleTitle'] ?? '').toString().trim();
  if (articleTitle.isNotEmpty) return articleTitle;
  if (message.length > 90) return '${message.substring(0, 90)}...';
  return message.isNotEmpty ? message : 'Notification';
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

Widget buildNotificationThumbnail(String? url, NotificationVisualKind kind) {
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
    child: Image.network(
      url,
      width: w,
      height: h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    ),
  );
}
