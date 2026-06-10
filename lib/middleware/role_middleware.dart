import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/user_role_service.dart';
import '../widgets/role_restriction_dialog.dart';

/// Middleware pour vérifier les restrictions d'accès par rôle
class RoleMiddleware {
  
  /// URLs des stores (à configurer selon vos besoins)
  static const String tranooProPlayStore = 'https://play.google.com/store/apps/details?id=com.tranoo.pro';
  static const String tranooProAppStore = 'https://apps.apple.com/app/tranoo-pro/id123456789';
  
  /// Vérifier si l'utilisateur peut accéder à Tranoo app (acheteur uniquement)
  static Future<bool> checkTranooAccess(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Si non connecté, rediriger vers login
    if (user == null) {
      _redirectToLogin(context);
      return false;
    }

    // Vérifier le rôle
    final canAccess = await AuthService.canAccessTranooApp();
    
    if (!canAccess) {
      _showRoleRestrictionDialog(
        context,
        currentApp: 'Tranoo',
        userRole: await UserRoleService.getUserRoleWithFallback(),
        alternativeApp: 'Tranoo Pro',
        playStoreUrl: tranooProPlayStore,
        appStoreUrl: tranooProAppStore,
      );
      return false;
    }

    return true;
  }

  /// Vérifier si l'utilisateur peut accéder à Tranoo Pro (sauf acheteurs)
  static Future<bool> checkTranooProAccess(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Si non connecté, rediriger vers login
    if (user == null) {
      _redirectToLogin(context);
      return false;
    }

    // Vérifier le rôle
    final canAccess = await AuthService.canAccessTranooPro();
    
    if (!canAccess) {
      _showRoleRestrictionDialog(
        context,
        currentApp: 'Tranoo Pro',
        userRole: await UserRoleService.getUserRoleWithFallback(),
        alternativeApp: 'Tranoo',
        playStoreUrl: tranooProPlayStore, // URL pour Tranoo normal
        appStoreUrl: tranooProAppStore, // URL pour Tranoo normal
      );
      return false;
    }

    return true;
  }

  /// Rediriger vers la page de login
  static void _redirectToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const _LoginScreen()),
      (route) => false,
    );
  }

  /// Afficher le popup attractif de restriction d'accès
  static void _showRoleRestrictionDialog(
    BuildContext context, {
    required String currentApp,
    required String? userRole,
    required String alternativeApp,
    required String playStoreUrl,
    required String appStoreUrl,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoleRestrictionDialog(
        currentApp: currentApp,
        requiredRole: UserRoleService.getRoleDisplayName(userRole ?? 'inconnu'),
        alternativeApp: alternativeApp,
        playStoreUrl: playStoreUrl,
        appStoreUrl: appStoreUrl,
      ),
    );
  }

  static Widget _accessDeniedPlaceholder(BuildContext context, Color iconColor) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              l10n.checkingPermissions,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.redirectingIfNeeded,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget wrapper pour protéger les routes
  static Widget TranooRouteGuard({required Widget child}) {
    return FutureBuilder<bool>(
      future: AuthService.canAccessTranooApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return _accessDeniedPlaceholder(context, Colors.red);
      },
    );
  }

  /// Widget wrapper pour protéger les routes Pro
  static Widget TranooProRouteGuard({required Widget child}) {
    return FutureBuilder<bool>(
      future: AuthService.canAccessTranooPro(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return _accessDeniedPlaceholder(context, Colors.orange);
      },
    );
  }
}

// Widget de login temporaire
class _LoginScreen extends StatelessWidget {
  const _LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 64),
            const SizedBox(height: 16),
            Text(l10n.pleaseSignIn),
            const SizedBox(height: 8),
            Text(
              l10n.redirecting,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
