import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import '../services/user_service.dart';

enum UserRole { acheteur }

UserRole? stringToUserRole(String? role) {
  switch (role) {
    case 'acheteur':
      return UserRole.acheteur;
    default:
      return null;
  }
}

class RoleRedirect extends StatelessWidget {
  final Widget child;
  final UserRole requiredRole;

  const RoleRedirect({
    super.key,
    required this.child,
    required this.requiredRole,
  });

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final l10n = AppLocalizations.of(context)!;

    if (userService.currentRole != requiredRole) {
      return Center(child: Text(l10n.unauthorizedAccess));
    }

    return child;
  }
}
