import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'details_notifications.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final List<Map<String, dynamic>> notifications = [
    {
      "initial": "P",
      "title": "Paiement confirmé",
      "message": "Vous avez réussi votre paiement.",
      "date": DateTime.now().subtract(const Duration(minutes: 10)),
      "isRead": true,
    },
    {
      "initial": "J",
      "title": "Promotion de juillet",
      "message":
          "Cher client, nous aimerions vous informez que ce mois de juillet beaucoup de surprise vous attendent.",
      "date": DateTime.now().subtract(const Duration(hours: 3)),
      "isRead": false,
    },
    {
      "initial": "U",
      "title": "Alerte",
      "message":
          "Cher client nous vous informons que toute la soirée du vendredi les transactions sur MTN MoMo ne seront pas accessibles.",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "isRead": true,
    },
    {
      "initial": "H",
      "title": "Bonne journée indépendante",
      "message":
          "Agréable journée de la fête d'indépendance à toute les compatriotes béninois et béninoise.",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "isRead": false,
    },
    {
      "initial": "P",
      "title": "Paiement confirmé",
      "message": "Votre transaction à été effectué.",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "isRead": false,
    },
    {
      "initial": "F",
      "title": "Paiement écchoué",
      "message":
          "Votre paiement à échouer en quelques sortes veillez reprendre la même action un peu plus tard.",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "isRead": true,
    },
  ];

  String formatDate(DateTime date) {
    Duration difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return "Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
    } else if (difference.inHours > 0) {
      return "Il y a ${difference.inHours}h";
    } else {
      final DateFormat formatter = DateFormat('HH:mm');
      return "Il y a ${difference.inMinutes} min (${formatter.format(date)})";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon compte', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune notification pour le moment',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        var notification = notifications[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7DD),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                notification["initial"],
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            title: Text(notification["title"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification["message"],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatDate(notification["date"]),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              notification["isRead"] ? Icons.star : Icons.star,
                              color: notification["isRead"]
                                  ? Colors.grey
                                  : const Color(0xFFFCC21B),
                            ),
                            onTap: () {
                              setState(() {
                                notifications[index]["isRead"] = true;
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsNotifications(
                                    title: notification["title"],
                                    message: notification["message"],
                                    date: notification["date"],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
