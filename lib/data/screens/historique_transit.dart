import 'package:flutter/material.dart';
import 'formulaire_transit.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class HistoriqueTransitPage extends StatelessWidget {
  const HistoriqueTransitPage({super.key});

  List<Map<String, dynamic>> _transits(AppLocalizations l10n) => [
        {
          'voiture': 'Toyota Corolla 2018',
          'client': 'Marcel T.',
          'portDepart': 'Anvers, Belgique',
          'portArrivee': 'Cotonou, Bénin',
          'dateTransit': '10 avril 2025',
          'statut': l10n.deliveredSuccessfully,
          'statutCouleur': Colors.green,
          'documents': [
            l10n.billOfLading,
            l10n.proformaInvoice,
            l10n.transitCertificate,
          ],
          'couleurFond': Colors.yellow[100],
        },
        {
          'voiture': 'BMW X5 2020',
          'client': 'CarExpert Auto',
          'portDepart': 'Hambourg, Allemagne',
          'portArrivee': 'Lomé, Togo',
          'dateTransit': '25 mars 2025',
          'statut': l10n.inTransit,
          'statutCouleur': Colors.blue,
          'documents': [
            l10n.billOfLading,
            l10n.partialCustomsCertificate,
          ],
          'couleurFond': Colors.blue[100],
        },
        {
          'voiture': 'Kia Picanto 2016',
          'client': 'Aline K.',
          'portDepart': 'Le Havre, France',
          'portArrivee': 'Cotonou, Bénin',
          'dateTransit': '15 mars 2025',
          'statut': l10n.atCustoms,
          'statutCouleur': Colors.orange,
          'documents': [
            l10n.proformaInvoice,
            l10n.inspectionCertificate,
          ],
          'couleurFond': Colors.green[100],
        },
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transits = _transits(l10n);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.transitHistoryTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormulaireTransitPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transits.length,
        itemBuilder: (context, index) {
          final transit = transits[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transit['couleurFond'] as Color?,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transit['voiture'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.clientLabel(transit['client'] as String)),
                Text(l10n.departurePortLabel(transit['portDepart'] as String)),
                Text(l10n.arrivalPortLabel(transit['portArrivee'] as String)),
                Text(l10n.transitDateLabel(transit['dateTransit'] as String)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${l10n.status}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      transit['statut'] as String,
                      style: TextStyle(
                        color: transit['statutCouleur'] as Color?,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (transit['documents'] as List<String>)
                      .map<Widget>((doc) {
                    return GestureDetector(
                      onTap: () {},
                      child: Text(
                        doc,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
