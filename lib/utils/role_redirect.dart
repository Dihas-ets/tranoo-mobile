import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import '../services/user_service.dart';

enum UserRole {
  acheteur,
  vendeur,
  vendeurVehicules,
  vendeurPieces,
  vendeurMotos,
  transitaire,
  chauffeur,
  agentCommercial,
  livreur,
}

UserRole? stringToUserRole(String? role) {
  switch (role) {
    case 'acheteur':
      return UserRole.acheteur;
    case 'vendeur':
      return UserRole.vendeur;
    case 'vendeurVehicules':
      return UserRole.vendeurVehicules;
    case 'vendeurPieces':
      return UserRole.vendeurPieces;
    case 'vendeurMotos':
      return UserRole.vendeurMotos;
    case 'transitaire':
      return UserRole.transitaire;
    case 'chauffeur':
      return UserRole.chauffeur;
    case 'agentCommercial':
      return UserRole.agentCommercial;
    case 'livreur':
      return UserRole.livreur;
    default:
      return null;
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.acheteur:
      return 'acheteur';
    case UserRole.vendeur:
      return 'vendeur';
    case UserRole.vendeurVehicules:
      return 'vendeurVehicules';
    case UserRole.vendeurPieces:
      return 'vendeurPieces';
    case UserRole.vendeurMotos:
      return 'vendeurMotos';
    case UserRole.transitaire:
      return 'transitaire';
    case UserRole.chauffeur:
      return 'chauffeur';
    case UserRole.agentCommercial:
      return 'agentCommercial';
    case UserRole.livreur:
      return 'livreur';
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
