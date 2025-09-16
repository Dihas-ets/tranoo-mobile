import 'package:flutter/material.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:logging/logging.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

// import 'details_notifications.dart';

class NotificationProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications =>
      List.unmodifiable(_notifications);

  NotificationProvider() {
    _initFCMListener();
  }

  void addNotification(Map<String, dynamic> notif) {
    _notifications.insert(0, notif);
    notifyListeners();
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

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  String _getInitialFromTitle(String title) {
    if (title.isEmpty) return "N";
    return title[0].toUpperCase();
  }

  String _getNotificationColor(String type) {
    switch (type) {
      case 'paiement':
        return '#4CAF50'; // Vert
      case 'promotion':
        return '#FF9800'; // Orange
      case 'alerte':
        return '#F44336'; // Rouge
      case 'publicite':
        return '#2196F3'; // Bleu
      default:
        return '#9E9E9E'; // Gris
    }
  }

  String formatDate(DateTime date) {
    Duration difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return "Il y a  {difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
    } else if (difference.inHours > 0) {
      return "Il y a ${difference.inHours}h";
    } else {
      return "Il y a ${difference.inMinutes} min";
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().notifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body:
          notifications.isEmpty
              ? const Center(
                child: Text(
                  'Aucune notification',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {},
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final initial = _getInitialFromTitle(notification["title"]);
                    final color = _getNotificationColor(notification["type"]);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(
                          int.parse(color.replaceAll('#', '0xFF')),
                        ),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(notification["title"] ?? "-"),
                      subtitle: Text(notification["message"] ?? "-"),
                      trailing: Text(formatDate(notification["date"])),
                    );
                  },
                ),
              ),
    );
  }
}
