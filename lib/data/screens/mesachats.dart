import 'package:flutter/material.dart';

class MesAchatsPage extends StatelessWidget {
  final List<Map<String, String>> achats = [
    {
      "produit": "Toyota Corolla 2021",
      "date": "02 mars 2025",
      "statut": "Livré",
      "lieu": "Cotonou",
      "couleur": "Blanc",
      "carburant": "Essence",
    },
    {
      "produit": "Jantes alu 18 pouces",
      "date": "06 mars 2025",
      "statut": "En cours de livraison",
      "lieu": "Parakou",
      "couleur": "Noir Mat",
      "carburant": "-",
    },
    {
      "produit": "Autoradio écran tactile",
      "date": "10 mars 2025",
      "statut": "Livré",
      "lieu": "Porto-Novo",
      "couleur": "Gris",
      "carburant": "-",
    },
    {
      "produit": "Caméra de recul HD",
      "date": "15 mars 2025",
      "statut": "Annulé",
      "lieu": "Abomey",
      "couleur": "Noir",
      "carburant": "-",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13),
        title: const Text("Mes Achats"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achats.length,
        itemBuilder: (context, index) {
          final achat = achats[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achat['produit']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Statut : ${achat['statut']}"),
                  Text("Date de livraison : ${achat['date']}"),
                  Text("Lieu de livraison : ${achat['lieu']}"),
                  if (achat['carburant'] != "-")
                    Text("Type de carburant : ${achat['carburant']}"),
                  Text("Couleur : ${achat['couleur']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
