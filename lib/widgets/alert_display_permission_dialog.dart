import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tranoo/services/alert_display_permission_service.dart';

/// Explique pourquoi activer les alertes plein écran et ouvre les paramètres système.
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
        child: FutureBuilder<AndroidBuildVersion>(
          future: _sdkInfo(),
          builder: (context, snap) {
            final sdk = snap.data?.sdkInt ?? 0;
            final needsFsi = sdk >= 34;
            return Column(
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
                        'Alertes urgentes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  needsFsi
                      ? 'Sur Android 14 et plus, Tranoo a besoin de l\'autorisation '
                          '« Afficher les notifications en plein écran » pour afficher '
                          'une proposition vendeur en plein écran (app fermée ou écran verrouillé).'
                      : 'Autorisez les notifications pour être alerté quand un vendeur '
                          'répond à votre alerte, même en arrière-plan.',
                  style: const TextStyle(height: 1.45),
                ),
                if (needsFsi) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Étape suivante : l\'écran Paramètres de votre téléphone s\'ouvrira. '
                    'Activez « Autoriser le plein écran » (ou formulation équivalente) pour Tranoo.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _onActivate(context, needsFsi),
                    icon: const Icon(Icons.settings),
                    label: Text(
                      needsFsi
                          ? 'Ouvrir les paramètres'
                          : 'Autoriser les notifications',
                    ),
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
            );
          },
        ),
      ),
    );
  }

  Future<AndroidBuildVersion> _sdkInfo() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version;
  }

  Future<void> _onActivate(BuildContext context, bool needsFsi) async {
    await AlertDisplayPermissionService.ensureNotificationPermission();
    if (needsFsi) {
      await AlertDisplayPermissionService.openFullScreenIntentSettings();
    } else {
      await openAppSettings();
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Revenez dans l\'app après avoir activé l\'option dans Paramètres.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
    if (await AlertDisplayPermissionService.canUseFullScreenIntent()) {
      await AlertDisplayPermissionService.markPromptSeen();
    }
  }

  Future<void> _onLater(BuildContext context) async {
    await AlertDisplayPermissionService.markPromptSeen();
    onDone?.call();
    if (context.mounted) Navigator.of(context).pop();
  }
}
