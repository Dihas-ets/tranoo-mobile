import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/user_service.dart';
import 'payement.dart' show PayementScreen;

// --------- HELPERS SÉCURISÉS ----------
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

  Future<void> _postVerificationAction(
      BuildContext context, String action) async {
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
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // OK
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur action: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
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
    final stampUrl = getStampUrl(notification);
    final signatureUrl = getSignatureUrl(notification);
    final bodyHtml = _safeGetStringLocal(notification, 'bodyHtml') ??
        _safeGetStringLocal(notification, 'message') ??
        '-';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[100],
        foregroundColor: Colors.black,
        title: const Text('Détail de la vérification',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0.7,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/images/logo_tramoo.svg', height: 54),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Destinataire',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    Text(
                        _safeGetStringLocal(notification['recipient'], 'nom') ??
                            '-',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      _safeGetStringLocal(notification['recipient'], 'email') ??
                          _safeGetStringLocal(
                              notification['recipient'], 'telephone') ??
                          '-',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        notification['date'] is DateTime
                            ? _formatDateStatic(notification['date'])
                            : '',
                        style: const TextStyle(fontSize: 13))
                  ],
                ),
              ],
            ),
            const Divider(height: 36),
            Text(_safeGetStringLocal(notification, 'title') ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Colors.amber[900])),
            if (_safeGetStringLocal(notification, 'details') != null) ...[
              const SizedBox(height: 6),
              Text(_safeGetStringLocal(notification, 'details')!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
            const SizedBox(height: 10),
            Html(data: bodyHtml),
            if (images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 11,
                  crossAxisSpacing: 11,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _safeMapImages(images),
                ),
              ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (stampUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Image.network(stampUrl,
                      height: 53,
                      width: 53,
                      fit: BoxFit.contain,
                      opacity: const AlwaysStoppedAnimation(0.9),
                      errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 53,
                      width: 53,
                      color: Colors.grey[300],
                      child: const Icon(Icons.verified, color: Colors.amber),
                    );
                  }),
                ),
              if (signatureUrl != null)
                Image.network(signatureUrl, height: 39, fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 39,
                    width: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.edit, color: Colors.blueGrey),
                  );
                }),
            ]),
            const SizedBox(height: 16),
            if ((_safeGetStringLocal(notification, 'status') ?? 'pending') ==
                'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _postVerificationAction(context, 'approve');
                      // Extraire articleId et aller vers paiement
                      String? articleId = _safeGetStringLocal(
                          notification['verificationData'], 'articleId');
                      articleId ??= _safeGetStringLocal(
                              notification['relatedId'], '_id') ??
                          _safeGetStringLocal(notification, 'relatedId');
                      if (articleId != null && articleId.isNotEmpty) {
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                PayementScreen(article: {'_id': articleId}),
                          ),
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Article introuvable')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: const Text('Valider',
                        style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _postVerificationAction(context, 'reject');
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demande rejetée')),
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[300]),
                    child: const Text('Rejeter',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDateStatic(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays} jours';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inMinutes} minutes';
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

  // Méthode helper sécurisée pour mapper les images
  static List<Widget> _safeMapImages(List<String> images) {
    try {
      return images
          .map((img) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  img,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
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

  void _initFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = {
        'id': message.messageId ?? DateTime.now().toIso8601String(),
        'title': message.notification?.title ?? 'Notification',
        'message': message.notification?.body ?? '',
        'date': DateTime.now(),
        'isRead': false,
        'type': message.data['type'] ?? 'general',
        'actions': message.data['actions'] ?? [],
        'status': message.data['status'] ?? 'pending',
        'verificationData': message.data['verificationData'] ?? {},
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
          provider.loadNotificationsFromAPI(token);
        }
      });
    } else {
      print(
          'Aucun utilisateur connecté. Impossible de charger les notifications.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune notification',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final token = await user.getIdToken();
                      if (token != null) {
                        await provider.loadNotificationsFromAPI(token);
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
          final isUnread = !(notif['isRead'] ?? false);

          return GestureDetector(
            onTap: () async {
              if (isVerification) {
                final token = await user?.getIdToken();
                final notificationId = _safeGetString(notif, '_id');
                if (token != null && notificationId != null) {
                  await provider.markNotificationAsRead(notificationId, token);
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
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isVerification ? Colors.amber[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  backgroundColor: isVerification ? Colors.amber : Colors.blue,
                  child: Icon(
                      isVerification ? Icons.verified : Icons.notifications,
                      color: Colors.white),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _safeGetString(notif, 'title') ?? '-',
                        style: TextStyle(
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.normal,
                          color: isVerification
                              ? Colors.amber[800]
                              : Colors.blue[800],
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Nouveau',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                subtitle: Text(
                  _safeGetString(notif, 'message') != null
                      ? (_safeGetString(notif, 'message')!.length > 52
                          ? _safeGetString(notif, 'message')!.substring(0, 52) +
                              '...'
                          : _safeGetString(notif, 'message')!)
                      : '-',
                  maxLines: 2,
                ),
                trailing: Text(
                  notif['date'] is DateTime ? _formatDate(notif['date']) : '',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Erreur _buildNotificationsList: $e');
      return const Center(
        child: Text('Erreur lors du chargement des notifications'),
      );
    }
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays} jours';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inMinutes} minutes';
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
        }
      }

      showDialog(
        context: context,
        builder: (context) {
          final isVerification =
              _safeGetString(notification, 'type') == 'verification';
          final isPromo = _safeGetString(notification, 'type') == 'promotion';
          final isAlert = _safeGetString(notification, 'type') == 'alerte';
          final images = getNotifImages(notification);
          final stampUrl = getStampUrl(notification);
          final signatureUrl = getSignatureUrl(notification);
          final bodyHtml = _safeGetString(notification, 'bodyHtml') ??
              _safeGetString(notification, 'message') ??
              '-';

          Widget detailContent;

          if (isVerification) {
            detailContent = _buildVerificationContent(context, notification,
                provider, token, images, stampUrl, signatureUrl, bodyHtml);
          } else if (isAlert) {
            detailContent = _buildAlertContent(notification, bodyHtml);
          } else if (isPromo) {
            detailContent = _buildPromoContent(notification, images, bodyHtml);
          } else {
            detailContent = _buildStandardContent(notification, bodyHtml);
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
    NotificationProvider provider,
    String token,
    List<String> images,
    String? stampUrl,
    String? signatureUrl,
    String bodyHtml,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _safeGetString(notification, 'title') ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber[900],
                fontSize: 18,
              ),
            ),
            Text(
              notification['date'] is DateTime
                  ? _formatDate(notification['date'])
                  : "",
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_safeGetString(notification, 'details') != null) ...[
          Text(
            _safeGetString(notification, 'details')!,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 12),
        ],
        Html(data: bodyHtml),
        if (images.isNotEmpty)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: VerificationDetailPage._safeMapImages(images),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (stampUrl != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Image.network(
                  stampUrl,
                  height: 47,
                  width: 47,
                  fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.9),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 47,
                      width: 47,
                      color: Colors.grey[300],
                      child: const Icon(Icons.verified, color: Colors.amber),
                    );
                  },
                ),
              ),
            if (signatureUrl != null)
              Image.network(
                signatureUrl,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 34,
                    width: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.edit, color: Colors.blueGrey),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 18),
        if ((_safeGetString(notification, 'status') ?? 'pending') == 'pending')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final notificationId = _safeGetString(notification, '_id');
                  if (notificationId != null) {
                    await provider.handleVerificationAction(
                      notificationId,
                      'approve',
                      token,
                    );
                  }
                  // Récupérer l'articleId depuis la notif
                  String? articleId = _safeGetString(
                      notification['verificationData'], 'articleId');
                  if (articleId == null) {
                    articleId =
                        _safeGetString(notification['relatedId'], '_id') ??
                            _safeGetString(notification, 'relatedId');
                  }
                  if (articleId != null && articleId.isNotEmpty) {
                    // Aller vers l'écran de paiement avec l'article minimal
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) =>
                            PayementScreen(article: {'_id': articleId}),
                      ),
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Article introuvable pour la vérification')),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                child: const Text(
                  "Valider",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final notificationId = _safeGetString(notification, '_id');
                  if (notificationId != null) {
                    await provider.handleVerificationAction(
                      notificationId,
                      'reject',
                      token,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300],
                ),
                child: const Text(
                  "Rejeter",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAlertContent(
      Map<String, dynamic> notification, String bodyHtml) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[600],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 46),
          const SizedBox(height: 10),
          Text(
            _safeGetString(notification, 'title') ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 15),
          Html(
            data: bodyHtml,
            style: {
              '.': Style(color: Colors.white, fontSize: FontSize(16)),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoContent(
      Map<String, dynamic> notification, List<String> images, String bodyHtml) {
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
            '🎉 Promotion spéciale',
            style: TextStyle(
              color: Colors.yellow[900],
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _safeGetString(notification, 'title') ?? '',
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
                children: VerificationDetailPage._safeMapImages(images),
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

  Widget _buildStandardContent(
      Map<String, dynamic> notification, String bodyHtml) {
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
            _safeGetString(notification, 'title') ?? '',
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
        ],
      ),
    );
  }
}
