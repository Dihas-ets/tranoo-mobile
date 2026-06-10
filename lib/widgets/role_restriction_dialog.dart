import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import '../services/auth_service.dart';

/// Popup attractif pour les restrictions d'accès par rôle
class RoleRestrictionDialog extends StatelessWidget {
  final String currentApp;
  final String requiredRole;
  final String alternativeApp;
  final String playStoreUrl;
  final String appStoreUrl;

  const RoleRestrictionDialog({
    super.key,
    required this.currentApp,
    required this.requiredRole,
    required this.alternativeApp,
    required this.playStoreUrl,
    required this.appStoreUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
              ? [Colors.grey[800]!, Colors.grey[900]!]
              : [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône d'erreur avec animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.red[400]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.block_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Titre
            Text(
              l10n.restrictedAccess,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Message principal
            Text(
              l10n.roleNotAllowedOnApp(requiredRole, currentApp),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Message d'alternative
            Text(
              l10n.useAlternativeAppForRole(alternativeApp),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Boutons de téléchargement
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton Google Play
                _StoreButton(
                  icon: 'assets/images/google.png',
                  label: l10n.googlePlay,
                  onPressed: () => _launchURL(playStoreUrl),
                ),
                
                // Bouton App Store
                _StoreButton(
                  icon: 'assets/images/app.png',
                  label: l10n.appStore,
                  onPressed: () => _launchURL(appStoreUrl),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await AuthService.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  l10n.logout,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Widget pour les boutons des stores
class _StoreButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onPressed;

  const _StoreButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  label == 'Google Play' ? Icons.play_arrow : Icons.apple,
                  size: 40,
                  color: label == 'Google Play' ? Colors.green : Colors.black,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
