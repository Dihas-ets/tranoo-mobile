import 'package:flutter/material.dart';

/// Carte caractéristique catalogue (voiture / pièce) — évite l'overflow grille.
class SpecInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Widget? valueTrailing;

  const SpecInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.valueTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: valueTrailing != null
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.2,
                          ),
                        ),
                      ),
                      valueTrailing!,
                    ],
                  )
                : Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.2,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
