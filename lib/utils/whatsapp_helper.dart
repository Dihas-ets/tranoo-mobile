import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Normalise les numéros pour les liens `https://wa.me/...` (sans `+`).
class WhatsappHelper {
  WhatsappHelper._();

  static const String supportDigits = '22941839801';

  static String digitsOnly(String? phone) =>
      (phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');

  static Uri? buildWaMeUri(String? phone, {String? message}) {
    final digits = digitsOnly(phone);
    if (digits.isEmpty) return null;
    if (message != null && message.trim().isNotEmpty) {
      return Uri.parse(
        'https://wa.me/$digits?text=${Uri.encodeComponent(message.trim())}',
      );
    }
    return Uri.parse('https://wa.me/$digits');
  }

  static String? phoneFromMap(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in [
      'telephone',
      'phone',
      'whatsapp',
      'tel',
      'mobile',
    ]) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? phoneFromArticleSupplier({
    Map<String, dynamic>? fournisseur,
    Map<String, dynamic>? vendeur,
  }) {
    return phoneFromMap(fournisseur) ?? phoneFromMap(vendeur);
  }

  static String? phoneFromArticle(Map<String, dynamic>? data) {
    if (data == null) return null;
    final fournisseur = data['fournisseur'];
    final vendeur = data['vendeur'];
    return phoneFromArticleSupplier(
      fournisseur: fournisseur is Map
          ? Map<String, dynamic>.from(fournisseur)
          : null,
      vendeur:
          vendeur is Map ? Map<String, dynamic>.from(vendeur) : null,
    );
  }

  static Future<bool> openChat(
    BuildContext context, {
    required String? phone,
    String? message,
    required String unavailableMessage,
    required String cannotOpenMessage,
  }) async {
    final uri = buildWaMeUri(phone, message: message);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(unavailableMessage)),
      );
      return false;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(cannotOpenMessage)),
    );
    return false;
  }
}
