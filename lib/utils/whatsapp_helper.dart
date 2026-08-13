import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Normalise les numéros pour les liens `https://wa.me/...` (sans `+`).
class WhatsappHelper {
  WhatsappHelper._();

  static const String supportDigits = '22941839801';

  static String digitsOnly(String? phone) =>
      (phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');

  /// Chiffres internationaux pour wa.me (ex. Bénin 229XXXXXXXX).
  static String normalizeWaMeDigits(String? phone) {
    var d = digitsOnly(phone);
    if (d.isEmpty) return d;
    if (d.startsWith('00')) d = d.substring(2);
    if (d.startsWith('229')) {
      if (d.startsWith('22901') && d.length >= 12) {
        return '229${d.substring(5)}';
      }
      if (d.startsWith('2290') && d.length >= 12) {
        return '229${d.substring(4)}';
      }
      return d;
    }
    if (d.length == 8) return '229$d';
    if (d.startsWith('01') && d.length == 10) return '229${d.substring(1)}';
    if (d.startsWith('0') && d.length > 8) {
      return '229${d.replaceFirst(RegExp(r'^0+'), '')}';
    }
    return d;
  }

  static Uri? buildWaMeUri(String? phone, {String? message}) {
    final digits = normalizeWaMeDigits(phone);
    if (digits.isEmpty) return null;
    if (message != null && message.trim().isNotEmpty) {
      return Uri.parse(
        'https://wa.me/$digits?text=${Uri.encodeComponent(message.trim())}',
      );
    }
    return Uri.parse('https://wa.me/$digits');
  }

  static Uri? buildWhatsAppSchemeUri(String? phone, {String? message}) {
    final digits = normalizeWaMeDigits(phone);
    if (digits.isEmpty) return null;
    if (message != null && message.trim().isNotEmpty) {
      return Uri.parse(
        'whatsapp://send?phone=$digits&text=${Uri.encodeComponent(message.trim())}',
      );
    }
    return Uri.parse('whatsapp://send?phone=$digits');
  }

  static String? phoneFromMap(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in [
      'telephone',
      'telephoneCanonical',
      'phone',
      'whatsapp',
      'tel',
      'mobile',
    ]) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    final fp = data['fournisseurProfil'];
    if (fp is Map) {
      return phoneFromMap(Map<String, dynamic>.from(fp));
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

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return true;
    } catch (_) {}
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> launchChat({
    required String? phone,
    String? message,
  }) async {
    final waMe = buildWaMeUri(phone, message: message);
    if (waMe != null && await _tryLaunch(waMe)) return true;

    final scheme = buildWhatsAppSchemeUri(phone, message: message);
    if (scheme != null && await _tryLaunch(scheme)) return true;

    return false;
  }

  /// Libellé affiché dans le message WhatsApp (titre ou marque + modèle).
  static String articleListingLabel({
    String? titre,
    String? marque,
    String? modele,
    required String fallback,
  }) {
    final title = (titre ?? '').trim();
    if (title.isNotEmpty) return title;
    final built = [marque, modele]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(' ');
    if (built.isNotEmpty) return built;
    return fallback;
  }

  static Future<bool> openChat(
    BuildContext context, {
    required String? phone,
    String? message,
    required String unavailableMessage,
    required String cannotOpenMessage,
  }) async {
    final digits = normalizeWaMeDigits(phone);
    if (digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(unavailableMessage)),
      );
      return false;
    }

    final opened = await launchChat(phone: phone, message: message);
    if (opened) return true;

    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(cannotOpenMessage)),
    );
    return false;
  }
}
