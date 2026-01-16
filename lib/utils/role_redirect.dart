import 'package:flutter/material.dart';
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

    if (userService.currentRole != requiredRole) {
      return const Center(child: Text('Accès non autorisé'));
    }

    return child;
  }
}
