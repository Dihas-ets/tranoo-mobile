import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Compte Bloqué'),
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
              'Vous ne pouvez pas accéder à l\'application car l\'administrateur vous a temporairement bloqué.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Contactez l\'équipe support pour plus d\'informations.',
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
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  static Future<void> _handleLogout() async {
    try {
      // Déconnexion Firebase
      await FirebaseAuth.instance.signOut();
      
      // Nettoyage SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  static Future<void> checkAndHandleBlockedUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Cette vérification sera faite automatiquement par l'intercepteur
      // lors des appels API
    } catch (e) {
      print('Erreur lors de la vérification du statut: $e');
    }
  }
}