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
        // Ajouter les données spécifiques aux notifications de vérification
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

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  String _getInitialFromTitle(String title) {
    if (title.isEmpty) return "N";
    return title[0].toUpperCase();
  }

  String _getNotificationColor(String type) {
    switch (type) {
      case 'verification':
        return '#FF9800'; // Orange pour les vérifications
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
      return "Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
    } else if (difference.inHours > 0) {
      return "Il y a ${difference.inHours}h";
    } else {
      return "Il y a ${difference.inMinutes} min";
    }
  }

  // Construire une carte de notification standard
  Widget _buildStandardNotificationCard(
    Map<String, dynamic> notification,
    String color,
  ) {
    final initial = _getInitialFromTitle(notification["title"] ?? "");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(int.parse(color.replaceAll('#', '0xFF'))),
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          notification["title"] ?? "-",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification["message"] ?? "-"),
        trailing: Text(
          formatDate(notification["date"]),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  // Construire une carte de notification de vérification avec actions
  Widget _buildVerificationNotificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
    String color,
  ) {
    final initial = _getInitialFromTitle(notification["title"] ?? "");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Column(
        children: [
          // En-tête avec icônes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône principale
                CircleAvatar(
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
                const SizedBox(width: 12),
                // Icônes supplémentaires pour la vérification
                const Icon(Icons.verified, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Icon(Icons.shopping_cart, color: Colors.blue, size: 20),
                const Spacer(),
                // Date
                Text(
                  formatDate(notification["date"]),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Contenu de la notification
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification["title"] ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification["message"] ?? "-",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Boutons d'action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _handleVerificationAction(
                          context,
                          notification,
                          'approve',
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Valider l\'achat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _handleVerificationAction(
                          context,
                          notification,
                          'reject',
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Rejeter l\'achat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gérer les actions de vérification
  void _handleVerificationAction(
    BuildContext context,
    Map<String, dynamic> notification,
    String action,
  ) {
    // TODO: Implémenter l'appel API pour traiter l'action
    print(
      'Action de vérification: $action pour la notification: ${notification["id"]}',
    );

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == 'approve'
              ? 'Achat validé avec succès !'
              : 'Achat rejeté avec succès !',
        ),
        backgroundColor: action == 'approve' ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    // TODO: Appeler l'API pour traiter l'action
    // await notificationService.handleVerificationAction(notification["id"], action);
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
                    final color = _getNotificationColor(
                      notification["type"] ?? "general",
                    );

                    // Affichage différencié selon le type
                    if (notification["type"] == 'verification') {
                      return _buildVerificationNotificationCard(
                        context,
                        notification,
                        color,
                      );
                    } else {
                      return _buildStandardNotificationCard(
                        notification,
                        color,
                      );
                    }
                  },
                ),
              ),
    );
  }
}
