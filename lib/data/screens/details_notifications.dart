import 'package:flutter/material.dart';

class DetailsNotifications extends StatelessWidget {
  final String title;
  final String message;
  final DateTime date;

  const DetailsNotifications({
    super.key,
    required this.title,
    required this.message,
    required this.date,
  });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ), // Titre dynamique
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(formatDate(date), style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}