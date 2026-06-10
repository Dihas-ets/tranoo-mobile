import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';

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

  String formatDate(AppLocalizations l10n, DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return l10n.timeAgoDays(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.timeAgoHours(difference.inHours);
    } else {
      return l10n.timeAgoMinutes(difference.inMinutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
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
            Text(formatDate(l10n, date),
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
