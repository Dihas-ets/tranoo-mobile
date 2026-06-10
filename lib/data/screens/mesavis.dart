import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class MesAvisPage extends StatelessWidget {
  const MesAvisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final produits = [
      'Toyota Corolla 2021',
      'Jantes alu',
      'Autoradio tactile',
      'Batterie 12V',
    ];

    final commentaires = [
      'Très bon véhicule, confortable et économique.',
      'Les jantes donnent un super look, je recommande.',
      'Interface fluide, son correct, facile à installer.',
      'Bonne autonomie et fiable même à basse tension.',
    ];

    final notes = [5, 4, 4, 5];

    final dates = [
      '21 avril 2025',
      '15 avril 2025',
      '10 avril 2025',
      '1er avril 2025',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13),
        title: Text(l10n.myReviews),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: produits.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produits[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.publishedOn(dates[index]),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    commentaires[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 18,
                          color: i < notes[index]
                              ? Colors.orange
                              : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.ratingOutOf(notes[index]),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
