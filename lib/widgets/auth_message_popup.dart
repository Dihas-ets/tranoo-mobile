import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Popup coloré et non agressif pour les messages d'authentification.
/// Types: success, error, warning, info, support.
class AuthMessagePopup {
  static const String _supportPhone = '+2290141839801';

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      type: _PopupType.success,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      type: _PopupType.error,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      type: _PopupType.warning,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return _show(
      context,
      type: _PopupType.info,
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Popup spéciale "Contacter l'assistance" avec bouton WhatsApp
  static Future<void> showSupportContact(
    BuildContext context, {
    required String message,
    String? subtitle,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 44,
                color: Color(0xFF25D366),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _openSupportWhatsApp(dialogContext);
                },
                icon: const Icon(Icons.chat, size: 22),
                label: Text(l10n.connectSupport),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
      },
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required _PopupType type,
    required String title,
    String? subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    final theme = _popupTheme(type);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.bgColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                theme.icon,
                size: 44,
                color: theme.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
            if (buttonText != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPressed?.call();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.color,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.bgColor.withOpacity(0.2),
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _openSupportWhatsApp(BuildContext context) async {
    final phone = _supportPhone.replaceAll(RegExp(r'[\s+]'), '');
    final candidates = <Uri>[
      Uri.parse('whatsapp://send?phone=$phone'),
      Uri.parse('https://wa.me/$phone'),
      Uri.parse('https://api.whatsapp.com/send?phone=$phone'),
    ];

    for (final uri in candidates) {
      try {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (ok) return;
      } catch (_) {
        // continuer sur le fallback suivant
      }
    }

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showError(
      context,
      title: l10n.cannotOpenWhatsApp,
      subtitle: l10n.installWhatsAppRetry,
      buttonText: l10n.ok,
    );
  }

  static _PopupTheme _popupTheme(_PopupType type) {
    switch (type) {
      case _PopupType.success:
        return _PopupTheme(
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
      case _PopupType.error:
        return _PopupTheme(
          color: const Color(0xFFE57373),
          bgColor: const Color(0xFFEF5350),
          icon: Icons.error_outline_rounded,
        );
      case _PopupType.warning:
        return _PopupTheme(
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFBBF24),
          icon: Icons.warning_amber_rounded,
        );
      case _PopupType.info:
        return _PopupTheme(
          color: const Color(0xFF3B82F6),
          bgColor: const Color(0xFF60A5FA),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

enum _PopupType { success, error, warning, info }

class _PopupTheme {
  final Color color;
  final Color bgColor;
  final IconData icon;
  _PopupTheme({required this.color, required this.bgColor, required this.icon});
}
