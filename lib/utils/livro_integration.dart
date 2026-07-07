import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:livro_delivery_sdk/livro_delivery_sdk.dart';
import 'package:livro_delivery_sdk/models/course_draft.dart';

/// Pont Tranoo ↔ Livro (identité client externe + ouverture du SDK).
class LivroIntegration {
  LivroIntegration._();

  /// Lie l'utilisateur Tranoo connecté au SDK Livro (mode app externe).
  static void bindCurrentUser(Map<String, dynamic>? user) {
    if (user == null) return;

    final id = user['_id']?.toString().trim() ??
        user['uid']?.toString().trim();
    final prenom =
        user['prenoms']?.toString().trim() ?? user['prenom']?.toString().trim();
    final nom = user['nom']?.toString().trim();
    final name = [prenom, nom]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .join(' ')
        .trim();

    if (id != null && id.isNotEmpty) {
      LivroSDK.externalClientId = id;
    }
    if (name.isNotEmpty) {
      LivroSDK.externalClientName = name;
    }
  }

  /// Construit un brouillon de course Livro (fournisseur + infos article).
  static CourseDraft buildCourseDraft({
    required String supplierAddress,
    required String supplierName,
    required String supplierPhone,
    double? supplierLat,
    double? supplierLng,
    String? courseTitle,
    String? category,
    String? receiverName,
    String? receiverPhone,
  }) {
    final draft = CourseDraft(
      courseTitle: courseTitle,
      category: category,
    );

    final address = supplierAddress.trim();
    final name = supplierName.trim();
    final phone = supplierPhone.trim();

    if (supplierLat != null &&
        supplierLng != null &&
        address.isNotEmpty &&
        name.isNotEmpty &&
        phone.isNotEmpty) {
      draft.setSupplier(
        LatLng(supplierLat, supplierLng),
        address,
        name,
        phone,
      );
    } else {
      if (address.isNotEmpty) draft.supplierAddress = address;
      if (name.isNotEmpty) draft.supplierName = name;
      if (phone.isNotEmpty) draft.supplierPhone = phone;
      if (supplierLat != null) draft.supplierLat = supplierLat;
      if (supplierLng != null) draft.supplierLon = supplierLng;
    }

    final buyerName = receiverName?.trim();
    final buyerPhone = receiverPhone?.trim();
    if (buyerName != null && buyerName.isNotEmpty) {
      draft.receiverName = buyerName;
    }
    if (buyerPhone != null && buyerPhone.isNotEmpty) {
      draft.receiverPhone = buyerPhone;
    }

    return draft;
  }

  /// Ouvre la création de course Livro (app externe).
  static void openDelivery(
    BuildContext context, {
    required CourseDraft draft,
  }) {
    LivroSDK.openCoursesHome(context, draft: draft);
  }
}
