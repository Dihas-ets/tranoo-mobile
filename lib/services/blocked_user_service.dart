import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import '../data/screens/second_page.dart';

class BlockedUserService {
  static final BlockedUserService _instance = BlockedUserService._internal();
  factory BlockedUserService() => _instance;
  BlockedUserService._internal();

  static BuildContext? _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static void showBlockedDialog(String message) {
    if (_context == null) return;

    final l10n = AppLocalizations.of(_context!)!;

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.block, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(l10n.accountBlockedTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.accountBlockedDialogMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.contactSupportTeam,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _handleLogout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SecondPage()),
                (route) => false,
              );
            },
            child: Text(l10n.understood),
          ),
        ],
      ),
    );
  }

  static Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // debug only
      print('Erreur lors de la déconnexion: $e');
    }
  }

  static Future<void> checkAndHandleBlockedUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
    } catch (e) {
      print('Erreur lors de la vérification du statut: $e');
    }
  }
}
