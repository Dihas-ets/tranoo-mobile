import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/user_service.dart';
import '../../providers/counter_provider.dart';
import 'cars_info.dart';
import 'mastervacpage.dart';
import 'package:tranoo/data/screens/mes_achats_historique.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/widgets/notification_list_ui.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/utils/verification_notification_helpers.dart';
import 'package:tranoo/utils/order_status_l10n.dart';
import 'package:tranoo/utils/notification_i18n.dart';
import 'package:tranoo/utils/locale_helper.dart';

// --------- HELPERS SÉCURISÉS ----------
String stripHtmlDocumentWrapper(String html) {
  final t = html.trim();
  if (!t.toLowerCase().contains('<!doctype') &&
      !t.toLowerCase().startsWith('<html')) {
    return t;
  }
  final bodyMatch =
      RegExp(r'<body[^>]*>([\s\S]*)</body>', caseSensitive: false)
          .firstMatch(t);
  if (bodyMatch != null) return bodyMatch.group(1)!.trim();
  return t
      .replaceAll(RegExp(r'<!DOCTYPE[^>]*>', caseSensitive: false), '')
      .replaceAll(RegExp(r'</?html[^>]*>', caseSensitive: false), '')
      .replaceAll(
          RegExp(r'<head[\s\S]*?</head>', caseSensitive: false), '')
      .replaceAll(RegExp(r'</?body[^>]*>', caseSensitive: false), '')
      .trim();
}

String? resolveNotificationBodyHtml(Map notif) {
  try {
    String? raw;
    final data = notif['data'];
    if (data is Map && data['bodyHtml'] != null) {
      raw = data['bodyHtml'].toString();
    }
    raw ??= notif['bodyHtml']?.toString();
    final type = (notif['type'] ?? '').toString();
    if (raw == null || raw.isEmpty) {
      final msg = notif['message']?.toString();
      if (msg != null &&
          msg.isNotEmpty &&
          type == 'verification' &&
          (msg.contains('<!DOCTYPE') || msg.contains('<html'))) {
        raw = msg;
      } else if (type != 'verification') {
        raw = msg;
      } else {
        raw = msg;
      }
    }
    if (raw == null || raw.isEmpty) return null;
    return stripHtmlDocumentWrapper(raw);
  } catch (_) {
    return null;
  }
}

String? getVerificationPdfUrl(Map notif) {
  try {
    final data = notif['data'];
    if (data is Map && data['pdfUrl'] != null) {
      final url = data['pdfUrl'].toString();
      if (url.isNotEmpty) return url;
    }
    return null;
  } catch (_) {
    return null;
  }
}

List<String> getNotifImages(Map notif) {
  try {
    final att = notif['attachments'];
    if (att == null || att is! Map) return [];

    final imgs = att['images'];
    if (imgs == null) return [];

    if (imgs is List) {
      return imgs.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (imgs is String) return [imgs];
    return [];
  } catch (e) {
    print('Erreur getNotifImages: $e');
    return [];
  }
}

List<String> getNotifDocuments(Map notif) {
  try {
    final att = notif['attachments'];
    if (att == null || att is! Map) return [];

    final docs = att['documents'];
    if (docs == null) return [];

    if (docs is List) {
      return docs.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (docs is String) return [docs];
    return [];
  } catch (e) {
    print('Erreur getNotifDocuments: $e');
    return [];
  }
}

String? getStampUrl(Map notif) {
  try {
    final att = notif['attachments'];
    if (att == null || att is! Map) return null;

    final val = att['stampUrl'];
    if (val is String && val.isNotEmpty) return val;
    return null;
  } catch (e) {
    print('Erreur getStampUrl: $e');
    return null;
  }
}

String? getSignatureUrl(Map notif) {
  try {
    final att = notif['attachments'];
    if (att == null || att is! Map) return null;

    final val = att['signatureUrl'];
    if (val is String && val.isNotEmpty) return val;
    return null;
  } catch (e) {
    print('Erreur getSignatureUrl: $e');
    return null;
  }
}

// ------------- PAGE DÉTAIL VÉRIFICATION ------------------
class VerificationDetailPage extends StatelessWidget {
  final Map<String, dynamic> notification;
  const VerificationDetailPage({Key? key, required this.notification})
      : super(key: key);

  static Future<void> _handleVerificationApprove(
    BuildContext context,
    Map<String, dynamic> notification,
  ) async {
    await _postVerificationActionStatic(context, notification, 'approve');
    final l10n = AppLocalizations.of(context)!;
    final title = _safeGetStringLocal(notification, 'title') ?? l10n.vehicleSingular;
    final articleId = _safeGetStringLocal(
            notification['verificationData'], 'articleId') ??
        _safeGetStringLocal(notification['relatedId'], '_id') ??
        _safeGetStringLocal(notification, 'relatedId');
    final waText = articleId != null && articleId.isNotEmpty
        ? l10n.whatsappInterestWithRef(title, articleId)
        : l10n.whatsappInterestNoRef(title);
    await openTranooWhatsApp(text: waText);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.requestValidatedWhatsApp)),
    );
    Navigator.pop(context);
  }

  static Future<void> _handleVerificationReject(
    BuildContext context,
    Map<String, dynamic> notification,
  ) async {
    await _postVerificationActionStatic(context, notification, 'reject');
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.requestRejected)),
    );
    final articleId = _safeGetStringLocal(
          notification['verificationData'], 'articleId') ??
        _safeGetStringLocal(notification, 'relatedId');
    Navigator.pop(context);
    if (articleId != null && articleId.isNotEmpty) {
      openPurchaseHistory(context, articleId: articleId);
    }
  }

  static Future<void> _postVerificationActionStatic(
    BuildContext context,
    Map<String, dynamic> notification,
    String action,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final notificationId = _safeGetStringLocal(notification, '_id');
      if (token == null || notificationId == null) return;
      final resp = await http.post(
        Uri.parse(
            '${getBaseUrl()}/notifications/$notificationId/verification-action'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'action': action}),
      );
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        if (!context.mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorActionStatus(resp.statusCode))),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric('$e'))),
      );
    }
  }

  static String? _safeGetStringLocal(dynamic obj, String key) {
    try {
      if (obj is Map && obj.containsKey(key)) {
        final val = obj[key];
        if (val is String) return val;
        if (val != null) return val.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = getNotifImages(notification);
    final documents = getNotifDocuments(notification);
    final stampUrl = getStampUrl(notification);
    final signatureUrl = getSignatureUrl(notification);
    final pdfUrl = getVerificationPdfUrl(notification);
    final bodyHtml = resolveNotificationBodyHtml(notification) ??
        _safeGetStringLocal(notification, 'message') ??
        '-';

    return Scaffold(
      backgroundColor: kVerifyYellowSoft,
      appBar: buildVerificationAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: buildVerificationNotificationContent(
          context: context,
          notification: Map<String, dynamic>.from(notification),
          bodyHtml: bodyHtml,
          images: images,
          documents: documents,
          stampUrl: stampUrl,
          signatureUrl: signatureUrl,
          pdfUrl: pdfUrl,
          showLogo: true,
          formatDate: (d) =>
              formatRelativeTime(AppLocalizations.of(context)!, d),
          onApprove: (_safeGetStringLocal(notification, 'status') ?? 'pending') ==
                  'pending'
              ? () => _handleVerificationApprove(context, notification)
              : null,
          onReject: (_safeGetStringLocal(notification, 'status') ?? 'pending') ==
                  'pending'
              ? () => _handleVerificationReject(context, notification)
              : null,
        ),
      ),
    );
  }

  // Méthode helper sécurisée pour récupérer les strings
  static String? _safeGetString(dynamic obj, String key) {
    try {
      if (obj is Map && obj.containsKey(key)) {
        final value = obj[key];
        if (value is String) return value;
        if (value != null) return value.toString();
      }
      return null;
    } catch (e) {
      print('Erreur _safeGetString: $e');
      return null;
    }
  }

  static List<Widget> _safeMapImages(BuildContext context, List<String> images) {
    try {
      return images
          .map((img) => GestureDetector(
                onTap: () => openRemoteAttachment(context, img,
                    label: img.split('/').last.split('?').first),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.network(
                        img,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 90,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.download_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ))
          .toList();
    } catch (e) {
      print('Erreur _safeMapImages: $e');
      return [];
    }
  }
}

class NotificationProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications =>
      List.unmodifiable(_notifications);
  bool loading = true;

  NotificationProvider() {
    _initFCMListener();
  }

  void addNotification(Map<String, dynamic> notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }

  Future<void> loadNotificationsFromAPI(String token) async {
    loading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/notifications/'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _notifications.clear();

        // Vérifier que data['notifications'] est une liste
        final notificationsList = data['notifications'];
        if (notificationsList is List) {
          for (var notif in notificationsList) {
            if (notif is Map) {
              _notifications.add({
                ...notif,
                'date': notif['createdAt'] != null
                    ? DateTime.tryParse(notif['createdAt'].toString()) ??
                        DateTime.now()
                    : DateTime.now(),
              });
            }
          }
        }
        notifyListeners();
      } else {
        print(
            'Erreur lors du chargement des notifications: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors du chargement des notifications: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String id, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${getBaseUrl()}/notifications/$id/read'),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        for (final notif in _notifications) {
          if (notif['_id'] == id) {
            notif['isRead'] = true;
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print('Erreur marquage notification lue: $e');
    }
  }

  Future<void> markNotificationAsUnread(String id, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${getBaseUrl()}/notifications/$id/unread'),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        for (final notif in _notifications) {
          if (notif['_id'] == id) {
            notif['isRead'] = false;
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print('Erreur marquage notification non lue: $e');
    }
  }

  Future<void> handleVerificationAction(
    String id,
    String action,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/notifications/$id/verification-action'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"action": action}),
      );
      print("Verification action response: ${response.statusCode}");
    } catch (e) {
      print('Erreur action vérif: $e');
    }
  }

  Future<bool> deleteNotification(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${getBaseUrl()}/notifications/$id'),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        _notifications.removeWhere((n) => (n['_id'] ?? '').toString() == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur suppression notification: $e');
      return false;
    }
  }

  void _initFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final locale = await LocaleHelper.storedLanguageCode();
      final push = NotificationI18n.resolvePush(message, locale);
      final data = message.data;
      final notif = {
        'id': message.messageId ?? DateTime.now().toIso8601String(),
        'title': push.title,
        'message': push.body,
        if (data['titleKey'] != null) 'titleKey': data['titleKey'],
        if (data['messageKey'] != null) 'messageKey': data['messageKey'],
        if (data['i18nParams'] != null)
          'i18nParams': NotificationI18n.parseI18nParams(data['i18nParams']),
        'date': DateTime.now(),
        'isRead': false,
        'type': data['type'] ?? 'general',
        'actions': data['actions'] ?? [],
        'status': data['status'] ?? 'pending',
        'verificationData': data['verificationData'] ?? {},
        'data': Map<String, dynamic>.from(data),
      };
      addNotification(notif);
    });
  }
}

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: const NotificationsBody(),
    );
  }
}

class NotificationsBody extends StatefulWidget {
  const NotificationsBody({super.key});

  @override
  State<NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<NotificationsBody> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  String get _localeCode => Localizations.localeOf(context).languageCode;

  final Set<String> _selectedNotificationIds = <String>{};

  bool get _selectionMode => _selectedNotificationIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedNotificationIds.contains(id)) {
        _selectedNotificationIds.remove(id);
      } else {
        _selectedNotificationIds.add(id);
      }
    });
  }

  void _clearSelection() {
    if (!_selectionMode) return;
    setState(() => _selectedNotificationIds.clear());
  }

  Future<void> _deleteSelected(NotificationProvider provider) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null) return;
    final ids = _selectedNotificationIds.toList();
    for (final id in ids) {
      await provider.deleteNotification(id, token);
    }
    if (!mounted) return;
    _clearSelection();
    _syncUnreadCountWithHeader(provider);
  }

  void _syncUnreadCountWithHeader(NotificationProvider provider) {
    final unreadCount =
        provider.notifications.where((n) => !(n['isRead'] ?? false)).length;
    Provider.of<CounterProvider>(
      context,
      listen: false,
    ).updateNotificationsCount(unreadCount);
  }

  Future<void> _trackDemoEventFromNotification(Map<String, dynamic> notif) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) return;
      await http.post(
        Uri.parse('${getBaseUrl()}/demo-events/track'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'eventType': 'notification_clicked',
          'page': 'notifications.dart',
          'meta': {
            'notificationId': (_safeGetString(notif, '_id') ?? ''),
            'notificationType': (_safeGetString(notif, 'type') ?? 'general'),
          },
        }),
      );
    } catch (_) {
      // best effort tracking
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.getIdToken().then((token) {
        if (token != null) {
          provider.loadNotificationsFromAPI(token).then((_) {
            if (!mounted) return;
            _syncUnreadCountWithHeader(provider);
          });
        }
      });
    } else {
      print(
          'Aucun utilisateur connecté. Impossible de charger les notifications.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<NotificationProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: _selectionMode
            ? IconButton(
                tooltip: l10n.cancel,
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        title: Text(
          _selectionMode
              ? l10n.notificationsSelectedCount(_selectedNotificationIds.length)
              : l10n.notifications,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
        actions: [
          if (_selectionMode)
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.delete),
                    content: Text(
                      l10n.confirmDeleteNotificationsCount(
                          _selectedNotificationIds.length),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await _deleteSelected(provider);
                }
              },
            ),
        ],
      ),
      body: provider.loading
          ? SkeletonPresets.notificationList()
          : provider.notifications.isEmpty
              ? Center(
                  child: Text(
                    l10n.noNotifications,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final token = await user.getIdToken();
                      if (token != null) {
                        await provider.loadNotificationsFromAPI(token);
                        if (mounted) {
                          _syncUnreadCountWithHeader(provider);
                        }
                      }
                    }
                  },
                  child: _buildNotificationsList(provider, user),
                ),
    );
  }

  Widget _buildNotificationsList(NotificationProvider provider, User? user) {
    try {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        itemCount: provider.notifications.length,
        itemBuilder: (ctx, index) {
          // Vérification de sécurité pour l'index
          if (index < 0 || index >= provider.notifications.length) {
            return const SizedBox.shrink();
          }

          final notif = provider.notifications[index];
          final isVerification =
              _safeGetString(notif, 'type') == 'verification';
          final notifData = (notif['data'] is Map)
              ? Map<String, dynamic>.from(notif['data'])
              : <String, dynamic>{};
          final requestType = (notifData['requestType'] ?? '').toString();
          final isAlert = _safeGetString(notif, 'type') == 'alerte' ||
              requestType == 'vehicle_search' ||
              requestType == 'piece_search';
          final isUnread = !(notif['isRead'] ?? false);
          final notifId = (_safeGetString(notif, '_id') ?? '').toString();
          final isSelected =
              notifId.isNotEmpty && _selectedNotificationIds.contains(notifId);

          Future<void> handleTap() async {
            if (_selectionMode) {
              if (notifId.isNotEmpty) _toggleSelection(notifId);
              return;
            }
            await _trackDemoEventFromNotification(notif);
            if (isVerification) {
              final token = await user?.getIdToken();
              final notificationId = _safeGetString(notif, '_id');
              if (token != null && notificationId != null) {
                await provider.markNotificationAsRead(notificationId, token);
                if (mounted) {
                  _syncUnreadCountWithHeader(provider);
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) =>
                      VerificationDetailPage(notification: notif),
                ),
              );
            } else {
              final token = await user?.getIdToken();
              if (token != null) {
                _showNotificationDetail(context, notif, provider, token);
                if (mounted) {
                  _syncUnreadCountWithHeader(provider);
                }
              }
            }
          }

          return _buildUnifiedNotificationListItem(
            notif: Map<String, dynamic>.from(notif),
            isUnread: isUnread,
            isSelected: isSelected,
            onTap: () async {
              await _trackDemoEventFromNotification(notif);
              await handleTap();
            },
            onLongPress: () {
              if (notifId.isEmpty) return;
              _toggleSelection(notifId);
            },
            provider: provider,
          );
        },
      );
    } catch (e) {
      print('Erreur _buildNotificationsList: $e');
      return Center(
        child: Text(AppLocalizations.of(context)!.notificationsLoadError),
      );
    }
  }

  String _formatDate(DateTime d) {
    return formatRelativeTime(AppLocalizations.of(context)!, d);
  }

  Map<String, dynamic> _notifDataMap(Map<String, dynamic> notif) {
    if (notif['data'] is Map) {
      return Map<String, dynamic>.from(notif['data']);
    }
    return <String, dynamic>{};
  }

  String? _alertImageUrl(Map<String, dynamic> notif) {
    final data = _notifDataMap(notif);
    final thumb = (data['thumbnailUrl'] ?? '').toString();
    if (thumb.isNotEmpty) return thumb;
    final photos = data['photos'];
    if (photos is List && photos.isNotEmpty) {
      return photos.first.toString();
    }
    return null;
  }

  String _alertPreviewText(Map<String, dynamic> notif) {
    final l10n = AppLocalizations.of(context)!;
    final data = _notifDataMap(notif);
    final requestType = (data['requestType'] ?? '').toString();
    final isPiece = requestType == 'piece_search';
    final parts = <String>[];
    final marque = (data['marque'] ?? '').toString().trim();
    final modele = (data['modele'] ?? '').toString().trim();
    if (marque.isNotEmpty) parts.add(marque);
    if (modele.isNotEmpty) parts.add(modele);
    if (isPiece) {
      final piece = (data['pieceName'] ?? '').toString().trim();
      if (piece.isNotEmpty) parts.add(piece);
    } else {
      final budget = (data['budget'] ?? data['budgetMax'] ?? '').toString().trim();
      if (budget.isNotEmpty) parts.add(l10n.budgetAmountFcfa(budget));
    }
    if (parts.isNotEmpty) return parts.join(' · ');
    final msg = (_safeGetString(notif, 'message') ?? '').trim();
    if (msg.length > 90) return '${msg.substring(0, 90)}...';
    return msg.isNotEmpty ? msg : l10n.newRequest;
  }

  Widget _alertThumbnail(String? url, {bool isPiece = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              width: 112,
              height: 63,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _alertThumbnailPlaceholder(isPiece),
            )
          : _alertThumbnailPlaceholder(isPiece),
    );
  }

  Widget _alertThumbnailPlaceholder(bool isPiece) {
    return Container(
      width: 112,
      height: 63,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(
        isPiece ? Icons.build_outlined : Icons.directions_car_outlined,
        color: Colors.grey[500],
        size: 32,
      ),
    );
  }

  Future<void> _handleAlertMenuAction({
    required String action,
    required Map<String, dynamic> notif,
    required NotificationProvider provider,
  }) async {
    final notifId = (_safeGetString(notif, '_id') ?? '').toString();
    if (notifId.isEmpty) return;
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    if (action == 'delete') {
      final ok = await provider.deleteNotification(notifId, token);
      if (!mounted) return;
      if (ok) {
        _syncUnreadCountWithHeader(provider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.notificationDeleted)),
        );
      }
      return;
    }

    if (action == 'unread') {
      await provider.markNotificationAsUnread(notifId, token);
      if (!mounted) return;
      _syncUnreadCountWithHeader(provider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.markedAsUnread)),
      );
    }
  }

  void _showImageFullscreen(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isProposalNotification(Map<String, dynamic> notif) {
    return _safeGetString(notif, 'type') == 'proposition_alerte';
  }

  bool _isAlertNotification(Map<String, dynamic> notif) {
    final data = _notifDataMap(notif);
    final requestType = (data['requestType'] ?? '').toString();
    return _isProposalNotification(notif) ||
        _safeGetString(notif, 'type') == 'alerte' ||
        requestType == 'vehicle_search' ||
        requestType == 'piece_search';
  }

  Widget _buildUnifiedNotificationListItem({
    required Map<String, dynamic> notif,
    required bool isUnread,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
    required NotificationProvider provider,
  }) {
    final kind = resolveNotificationVisualKind(notif);
    final imageUrl = notificationThumbUrl(notif) ?? _alertImageUrl(notif);
    final l10n = AppLocalizations.of(context)!;
    final title = resolveNotificationTitle(
      notif,
      _localeCode,
      fallback: l10n.notificationDefault,
    );
    final preview = _isProposalNotification(notif)
        ? resolveNotificationMessage(
            notif,
            _localeCode,
            fallback: l10n.alertProposalForYourAlert,
          )
        : _isAlertNotification(notif)
            ? _alertPreviewText(notif)
            : notificationPreviewText(
                notif,
                defaultLabel: l10n.notificationDefault,
                locale: _localeCode,
              );
    final dateStr =
        notif['date'] is DateTime ? _formatDate(notif['date'] as DateTime) : '';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
            left: isSelected
                ? const BorderSide(color: Colors.black, width: 3)
                : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 22, right: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF065FD4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            buildNotificationLeadingAvatar(
              kind: kind,
              appLogoAsset: 'assets/images/logo_tramoo.png',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  if (dateStr.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            buildNotificationThumbnail(imageUrl, kind),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[700], size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onSelected: (action) => _handleAlertMenuAction(
                action: action,
                notif: notif,
                provider: provider,
              ),
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'unread',
                  child: Text(l10n.markAsUnread),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode helper sécurisée pour récupérer les strings
  String? _safeGetString(dynamic obj, String key) {
    try {
      if (obj is Map && obj.containsKey(key)) {
        final value = obj[key];
        if (value is String) return value;
        if (value != null) return value.toString();
      }
      return null;
    } catch (e) {
      print('Erreur _safeGetString: $e');
      return null;
    }
  }

  Future<void> _openProposalArticle(
    BuildContext context, {
    required String articleId,
    String? typeHint,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/articles/$articleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) return;
      final article = jsonDecode(response.body);
      final articleType = (article['type'] ?? typeHint ?? '').toString().toLowerCase();

      if (!mounted) return;
      if (articleType == 'piece') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MastervacPage(
              id: article['_id']?.toString(),
              isAcheteur: true,
              title: (article['titre'] ?? '').toString(),
              year: (article['annee'] ?? '').toString(),
              description: (article['description'] ?? '').toString(),
              company: (article['entreprise'] ?? '').toString(),
              location: (article['lieu'] ?? article['localisation'] ?? '').toString(),
              price: (article['prix'] ?? '').toString(),
              fuelType: article['typeMoteur']?.toString(),
              model: article['modele']?.toString(),
              pieceType: (article['pieceType'] ?? article['condition'])?.toString(),
              images: (article['photos'] is List)
                  ? (article['photos'] as List).map((e) => e?.toString()).toList()
                  : const [],
              video: article['video']?.toString(),
            ),
          ),
        );
      } else {
        final photos = (article['photos'] is List)
            ? (article['photos'] as List)
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarsInfo(
              id: article['_id']?.toString(),
              titre: article['titre']?.toString(),
              description: article['description']?.toString(),
              marque: article['marque']?.toString(),
              modele: article['modele']?.toString(),
              annee: article['annee']?.toString(),
              prix: article['prix']?.toString(),
              condition: article['condition']?.toString(),
              boiteVitesse: article['boiteVitesse']?.toString(),
              carburant: article['carburant']?.toString(),
              climatiseur: article['climatiseur']?.toString(),
              distance: article['distance']?.toString(),
              sieges: article['sieges']?.toString(),
              portes: article['portes']?.toString(),
              cylindre: article['cylindre']?.toString(),
              couleur: article['couleur']?.toString(),
              dedouanement: article['dedouanement'] == true,
              lieu: (article['lieu'] ?? article['localisation'])?.toString(),
              images: photos,
              videos: const [],
              video: article['video']?.toString(),
              entreprise: article['entreprise']?.toString(),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorOpening('$e'))),
      );
    }
  }

  void _showNotificationDetail(
    BuildContext context,
    Map<String, dynamic> notification,
    NotificationProvider provider,
    String token,
  ) async {
    try {
      // Marquer comme lu dès l'ouverture
      if (!(notification['isRead'] ?? false)) {
        final notificationId = _safeGetString(notification, '_id');
        if (notificationId != null) {
          await provider.markNotificationAsRead(notificationId, token);
          if (mounted) {
            _syncUnreadCountWithHeader(provider);
          }
        }
      }

      showDialog(
        context: context,
        builder: (context) {
          final isVerification =
              _safeGetString(notification, 'type') == 'verification';
          final isTransitRejected =
              _safeGetString(notification, 'type') == 'transit_rejected';
          final isPromo = _safeGetString(notification, 'type') == 'promotion';
          final dataMap = (notification['data'] is Map)
              ? Map<String, dynamic>.from(notification['data'])
              : <String, dynamic>{};
          final requestType = (dataMap['requestType'] ?? '').toString();
          final isProposal =
              _safeGetString(notification, 'type') == 'proposition_alerte';
          final isAlert = !isProposal &&
              (_safeGetString(notification, 'type') == 'alerte' ||
                  requestType == 'vehicle_search' ||
                  requestType == 'piece_search');
          final images = getNotifImages(notification);
          final documents = getNotifDocuments(notification);
          final stampUrl = getStampUrl(notification);
          final signatureUrl = getSignatureUrl(notification);
          final pdfUrl = getVerificationPdfUrl(notification);
          final bodyHtml = resolveNotificationBodyHtml(notification) ??
              resolveNotificationMessage(
                notification,
                _localeCode,
                fallback: _safeGetString(notification, 'message') ?? '-',
              );

          Widget detailContent;

          if (isVerification) {
            detailContent = _buildVerificationContent(
              context,
              notification,
              images,
              documents,
              stampUrl,
              signatureUrl,
              bodyHtml,
              pdfUrl: pdfUrl,
            );
          } else if (isTransitRejected) {
            detailContent = _buildTransitRejectedContent(
              context,
              notification,
              bodyHtml,
            );
          } else if (isAlert) {
            detailContent = _buildAlertContent(notification, bodyHtml);
          } else if (isPromo) {
            detailContent =
                _buildPromoContent(context, notification, images, bodyHtml);
          } else {
            detailContent = _buildStandardContent(notification, bodyHtml);
          }

          return Dialog(
            backgroundColor: kVerifyYellowSoft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isVerification ? 12 : 20),
              child: detailContent,
            ),
          );
        },
      );
    } catch (e) {
      print('Erreur _showNotificationDetail: $e');
    }
  }

  Widget _buildVerificationContent(
    BuildContext context,
    Map<String, dynamic> notification,
    List<String> images,
    List<String> documents,
    String? stampUrl,
    String? signatureUrl,
    String bodyHtml, {
    String? pdfUrl,
  }) {
    final pending =
        (_safeGetString(notification, 'status') ?? 'pending') == 'pending';
    return buildVerificationNotificationContent(
      context: context,
      notification: notification,
      bodyHtml: bodyHtml,
      images: images,
      documents: documents,
      stampUrl: stampUrl,
      signatureUrl: signatureUrl,
      pdfUrl: pdfUrl,
      formatDate: _formatDate,
      onApprove: pending
          ? () => VerificationDetailPage._handleVerificationApprove(
              context, notification)
          : null,
      onReject: pending
          ? () => VerificationDetailPage._handleVerificationReject(
              context, notification)
          : null,
    );
  }

  String? _alertAnneeValue(Map<String, dynamic> dataMap, bool isPiece) {
    final annee = (dataMap['annee'] ?? '').toString().trim();
    if (annee.isNotEmpty) return annee;
    if (!isPiece) {
      final min = (dataMap['anneeMin'] ?? '').toString().trim();
      if (min.isNotEmpty) return min;
    }
    return null;
  }

  String? _alertBudgetValue(Map<String, dynamic> dataMap) {
    final budget = (dataMap['budget'] ?? dataMap['budgetMax'] ?? '')
        .toString()
        .trim();
    return budget.isNotEmpty ? budget : null;
  }

  Widget _buildAlertContent(
      Map<String, dynamic> notification, String bodyHtml) {
    final l10n = AppLocalizations.of(context)!;
    final dataMap = _notifDataMap(notification);
    final requestType = (dataMap['requestType'] ?? '').toString();
    final isPiece = requestType == 'piece_search';
    final imageUrl = _alertImageUrl(notification);
    final title = resolveNotificationTitle(
      notification,
      _localeCode,
      fallback: l10n.newAlertDefault,
    );
    final preview = _alertPreviewText(notification);
    final description = (dataMap['description'] ?? '').toString();
    final anneeVal = _alertAnneeValue(dataMap, isPiece);
    final budgetVal = _alertBudgetValue(dataMap);
    final dateStr = notification['date'] is DateTime
        ? _formatDate(notification['date'] as DateTime)
        : '';

    final details = <MapEntry<String, String>>[
      if ((dataMap['marque'] ?? '').toString().trim().isNotEmpty)
        MapEntry(l10n.brand, (dataMap['marque'] ?? '').toString().trim()),
      if ((dataMap['modele'] ?? '').toString().trim().isNotEmpty)
        MapEntry(l10n.model, (dataMap['modele'] ?? '').toString().trim()),
      if (isPiece && (dataMap['pieceName'] ?? '').toString().trim().isNotEmpty)
        MapEntry(l10n.partSingular, (dataMap['pieceName'] ?? '').toString().trim()),
      if (anneeVal != null) MapEntry(l10n.year, anneeVal),
      if (budgetVal != null) MapEntry(l10n.budgetLabel, '$budgetVal FCFA'),
      if ((dataMap['urgence'] ?? '').toString().trim().isNotEmpty)
        MapEntry(l10n.urgencyLabel, (dataMap['urgence'] ?? '').toString().trim()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty) ...[
          GestureDetector(
            onTap: () => _showImageFullscreen(context, imageUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Icon(
                        isPiece
                            ? Icons.build_outlined
                            : Icons.directions_car_outlined,
                        size: 48,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.enlarge,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        if (dateStr.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          preview,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Text(
            l10n.searchDetails,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...details.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPromoContent(
    BuildContext context,
    Map<String, dynamic> notification,
    List<String> images,
    String bodyHtml,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.yellow[400]!,
            Colors.orange[400]!,
            Colors.yellow[300]!,
          ],
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      padding: const EdgeInsets.all(17),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '🎉 ${AppLocalizations.of(context)!.specialPromotion}',
            style: TextStyle(
              color: Colors.yellow[900],
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            resolveNotificationTitle(
              notification,
              _localeCode,
              fallback: _safeGetString(notification, 'title') ?? '',
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
              color: Colors.orange[900],
            ),
          ),
          const SizedBox(height: 8),
          Html(
            data: bodyHtml,
            style: {
              '.': Style(
                color: Colors.orange[900],
                fontSize: FontSize(15),
              ),
            },
          ),
          if (images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    VerificationDetailPage._safeMapImages(context, images),
              ),
            ),
          if (_safeGetString(notification, 'ctaLabel') != null &&
              _safeGetString(notification, 'ctaUrl') != null)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                ),
                onPressed: () {
                  // Ouvrir le lien promo
                },
                child: Text(
                  _safeGetString(notification, 'ctaLabel')!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransitRejectedContent(
    BuildContext context,
    Map<String, dynamic> notification,
    String bodyHtml,
  ) {
    final dataMap = (notification['data'] is Map)
        ? Map<String, dynamic>.from(notification['data'])
        : <String, dynamic>{};
    final articleId = (dataMap['articleId'] ??
            _safeGetString(notification, 'relatedId') ??
            '')
        .toString();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF8BF13).withOpacity(0.45)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            resolveNotificationTitle(
              notification,
              _localeCode,
              fallback: _safeGetString(notification, 'title') ?? '',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B2B4B),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(bodyHtml, style: const TextStyle(height: 1.4)),
          if (articleId.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openPurchaseHistory(
                    context,
                    articleId: articleId.isNotEmpty ? articleId : null,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2B4B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(AppLocalizations.of(context)!.purchaseHistoryTitle),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStandardContent(
      Map<String, dynamic> notification, String bodyHtml) {
    final dataMap = (notification['data'] is Map)
        ? Map<String, dynamic>.from(notification['data'])
        : <String, dynamic>{};
    final action = (dataMap['action'] ?? '').toString();
    final targetArticleId =
        (dataMap['targetArticleId'] ?? _safeGetString(notification, 'relatedId') ?? '')
            .toString();
    final targetType = (dataMap['targetType'] ?? '').toString();
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resolveNotificationTitle(
              notification,
              _localeCode,
              fallback: _safeGetString(notification, 'title') ?? '',
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Html(
            data: bodyHtml,
            style: {
              '.': Style(color: Colors.blue[900], fontSize: FontSize(15)),
            },
          ),
          if ((action == 'view_proposal' || action == 'view_article') &&
              targetArticleId.isNotEmpty) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openProposalArticle(
                  context,
                  articleId: targetArticleId,
                  typeHint: targetType,
                );
              },
              icon: const Icon(Icons.visibility),
              label: Text(
                action == 'view_article'
                    ? AppLocalizations.of(context)!.viewListing
                    : AppLocalizations.of(context)!.viewProposal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
