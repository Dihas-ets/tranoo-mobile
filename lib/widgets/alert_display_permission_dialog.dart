import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tranoo/services/alert_display_permission_service.dart';

/// Demande l'autorisation notifications pour les réponses vendeur aux alertes.
class AlertDisplayPermissionDialog extends StatelessWidget {
  final VoidCallback? onDone;

  const AlertDisplayPermissionDialog({super.key, this.onDone});

  static Future<void> showIfNeeded(BuildContext context) async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (!await AlertDisplayPermissionService.shouldShowPrompt()) return;
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDisplayPermissionDialog(
        onDone: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.deepOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Notifications d\'alertes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Autorisez les notifications pour être alerté quand un vendeur '
              'répond à votre alerte, même lorsque l\'application est en arrière-plan.',
              style: TextStyle(height: 1.45),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _onActivate(context),
                icon: const Icon(Icons.notifications),
                label: const Text('Autoriser les notifications'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _onLater(context),
                child: const Text('Plus tard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onActivate(BuildContext context) async {
    await AlertDisplayPermissionService.ensureNotificationPermission();
    await AlertDisplayPermissionService.markPromptSeen();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    onDone?.call();
  }

  Future<void> _onLater(BuildContext context) async {
    await AlertDisplayPermissionService.markPromptSeen();
    onDone?.call();
    if (context.mounted) Navigator.of(context).pop();
  }
}
