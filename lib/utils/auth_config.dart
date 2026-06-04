import 'package:flutter/material.dart';

/// Règles auth partagées (inscription, mot de passe oublié, affichage).
class AuthConfig {
  AuthConfig._();

  static const String appDisplayName = 'Tranoo';

  /// Mot de passe : aligné sur l'inscription (min 8, pas de règles complexes).
  static const int passwordMinLength = 8;

  static bool isPasswordValid(String password) =>
      password.length >= passwordMinLength;

  /// OTP WhatsApp (6 chiffres, géré aussi côté API).
  static const int otpLength = 6;
  static final RegExp otpPattern = RegExp(r'^\d{6}$');
  static const int otpValiditySeconds = 600;

  /// Indicateur de force du mot de passe (aligné inscription).
  static ({double score, String label, Color color}) evaluatePasswordStrength(
    String value,
  ) {
    double score = 0;
    if (value.isNotEmpty) {
      if (value.length >= 6) score += 0.3;
      if (value.length >= 8) score += 0.2;
      if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.15;
      if (RegExp(r'[a-z]').hasMatch(value)) score += 0.15;
      if (RegExp(r'\d').hasMatch(value)) score += 0.1;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(value)) score += 0.1;
      if (score > 1) score = 1;
    }

    if (score == 0) {
      return (score: 0.0, label: '', color: Colors.transparent);
    }
    if (score < 0.4) {
      return (score: score, label: 'Faible', color: Colors.red);
    }
    if (score < 0.7) {
      return (score: score, label: 'Moyen', color: Colors.orange);
    }
    if (score < 0.9) {
      return (score: score, label: 'Fort', color: Colors.lightGreen);
    }
    return (score: score, label: 'Super fort', color: Colors.green);
  }

  /// Nom vendeur / entreprise affiché si non renseigné en base.
  static String displayEntreprise(String? entreprise) {
    final v = entreprise?.trim();
    if (v != null && v.isNotEmpty) return v;
    return appDisplayName;
  }

  /// Icône WhatsApp pour le champ numéro (inscription / MDP oublié).
  static Widget whatsAppPhonePrefixIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Image.asset(
        'assets/images/whatsapp_icon.png',
        width: 22,
        height: 22,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.chat,
          color: Color(0xFF25D366),
          size: 22,
        ),
      ),
    );
  }
}
