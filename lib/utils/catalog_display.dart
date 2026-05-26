import 'package:flutter/material.dart';

/// Prix avec séparateurs de milliers (aligné accueil Tranoo Pro).
String formatCatalogPrice(dynamic price) {
  if (price == null) return '0';
  try {
    final priceNum = double.tryParse(price.toString()) ?? 0;
    final priceStr = priceNum.toStringAsFixed(0);
    final reversed = priceStr.split('').reversed.join('');
    final withDots = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (Match m) => '${m[0]}.',
    );
    return withDots.split('').reversed.join('');
  } catch (_) {
    return price.toString();
  }
}

String vehicleTitleFromMap(Map<String, dynamic> v) {
  final t = (v['titre'] ?? '').toString().trim();
  if (t.isNotEmpty) return t;
  final mm =
      '${v['marque'] ?? ''} ${v['modele'] ?? ''}'.trim();
  return mm.isNotEmpty ? mm : 'Véhicule';
}

/// Bloc titre + prix sous l’image (grille voitures).
Widget catalogVehicleInfoFooter({
  required String title,
  required dynamic prix,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Text(
        '${formatCatalogPrice(prix)} FCFA',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ],
  );
}

/// Pastille prix (grille pièces).
Widget catalogPiecePricePill(dynamic prix) {
  final hasPrice = prix != null && prix.toString().trim().isNotEmpty;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5E5),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      hasPrice ? '${formatCatalogPrice(prix)} FCFA' : 'Prix non communiqué',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFFB45309),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );
}
