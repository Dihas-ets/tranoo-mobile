import 'package:flutter/material.dart';
import '../services/user_service.dart';

enum UserRole { acheteur, vendeur, transitaire, chauffeur }

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
